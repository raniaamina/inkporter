#!/usr/bin/env python

import tempfile
import re
from lxml import etree
import sys
import shutil
import os
import inkex
import subprocess
from time import sleep
import platform

try:
    from inkex.elements._utils import NSS # 1.1.x
except ImportError:
    from inkex.utils import NSS # 1.0.x

if os.name != "nt":
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk

__version__ = '1.2.4'

def atoi(text):
    return int(text) if text.isdigit() else text

def run_command(command, log_path):
    try:
        # outputs = subprocess.check_output(commands, stderr=subprocess.STDOUT, universal_newlines=True)
        # CREATE_NO_WINDOW = 0x08000000
        if os.name == "nt":
            stinfo = subprocess.STARTUPINFO()
            stinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            subprocess.Popen(command, startupinfo=stinfo, stdout=sys.stdout, stderr=sys.stdout).wait()
            # subprocess.call(command)
        else:
            outputs = subprocess.check_output(command, stderr=subprocess.STDOUT, universal_newlines=True)
            with open(log_path, "a") as log:
                for line in outputs:
                    log.write(line)
                    
    except subprocess.CalledProcessError as error:
        inkex.utils.errormsg(error.output)

class ProgressBar():
    def __init__(self, export_format, num_objects, use_zenity):
        self.__text = "Exporting Object with ID 'objectid' to {0}".format(export_format.upper())
        self.__num_objects = num_objects
        self.__active = False
        if use_zenity:
            self.__progress_command = "start /w zenity"
        else:
            self.__progress_command = None
    
    @property
    def is_active(self):
        if self.__active and self.__process.poll() is not None:
            self.__close()
        return self.__active

    def __enter__(self):
        if self.__progress_command is None:
           return self 
        self.__devnull = open(os.devnull, 'w')
        self.__process = subprocess.Popen([
            "zenity",
            "--progress",
            "--title='Inkporter: Exporting...'",
            "--auto-close",
            "--width=400",
            "--no-cancel",
            "--percentage=0"
        ], stdin=subprocess.PIPE, stdout=self.__devnull, stderr=self.__devnull)
        self.__active = True
        return self
    
    def update_progress(self, progress, object_id):
        if self.is_active:
            current_progress = str(int(progress * 100 / self.__num_objects))
            self.__process.stdin.write("{0}\n".format(current_progress).encode("utf-8"))
            self.__process.stdin.write("# {0} ({1}/{2} done)\n".format(
                self.__text.replace('objectid', object_id), 
                progress, 
                self.__num_objects).encode("utf-8"))
            self.__process.stdin.flush()

    def __exit__(self, *args):
        if self.__active:
            self.__close()

    def __close(self):
        if not self.__process.stdin.closed:
            self.__process.stdin.close()
        if not self.__devnull.closed:
            self.__devnull.close()
        self.__process.wait()
        self.__active = False

class Inkporter(inkex.Effect):
    def __init__(self):
        inkex.Effect.__init__(self)
        self.arg_parser.add_argument('--tab')
        self.arg_parser.add_argument("-f", "--format",
                                     type=str, dest="format",
                                     help="Preferred output format", default="png")
        self.arg_parser.add_argument("--id-pattern",
                                     type=str, dest="id_pattern",
                                     help="IDs to export")
        self.arg_parser.add_argument("--with-cmyk",
                                     type=inkex.Boolean, dest="with_cmyk",
                                     help="Use CMYK instead of RGB (for JPG/PDF)")
        self.arg_parser.add_argument("--dpi",
                                     type=int, dest="dpi",
                                     help="DPI for bitmap image output format", default=96)
        self.arg_parser.add_argument("-D", "--output-dir",
                                     type=str, dest="output_dir",
                                     help="Destination folder for saving your exports", default=os.path.expanduser("~"))
        self.arg_parser.add_argument("--bg-color",
                                     type=inkex.Color, dest="bg_color",
                                     help="Background color for JPG Export", default="white")
        self.arg_parser.add_argument("-q", "--quality",
                                     type=int, dest="quality",
                                     help="Quality of image export, 0-100, higher better but slower",  default=100)
        self.id_to_process = None
        
        if platform.system() == "Windows":
            self.with_zenity = False
        else:
            self.with_zenity = True
        self.tmpout = []
    
    def do_png(self):
        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            for idx,item in enumerate(self.id_to_process):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + ".png"
                command = [
                    "inkscape",
                    "-j","-i", item.get('id'),
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install Imagemagick to do JPG export")
            return

        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            colorspace = "RGB"
            if self.options.with_cmyk:
                colorspace = "CMYK"
            for idx,item in enumerate(self.id_to_process):
                tmp_export_path = self.tmpdir + "/" + item.get('id') + ".png"
                # first, export to PNG
                run_command([
                    "inkscape",
                    "-j","-i", item.get('id'),
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)

                self.tmpout.append(tmp_export_path)

                # then, convert it to JPG using ImageMagick
                real_export_path = "{0}/{1}-{2}.jpg".format(os.path.expandvars(self.options.output_dir), item.get('id'), colorspace.lower())
                # order = f"{im} {tmp_export_path} -background {self.options.bg_color} -flatten -quality {self.options.quality} -colorspace {colorspace} {real_export_path}"
                if os.name == "nt":
                    this_is_order = f'magick convert {tmp_export_path} -background {self.options.bg_color} -flatten -colorspace {colorspace} -quality {self.options.quality} "{real_export_path}"'
    
                else:
                    this_is_order = ([
                    "convert",
                    "{0}".format(tmp_export_path),
                    "-background", "{0}".format(self.options.bg_color),
                    "-flatten",
                    "-quality", "{0}".format(self.options.quality),
                    "-colorspace", "{0}".format(colorspace),
                    "{0}".format(real_export_path)
                    ])
                
                run_command(this_is_order, self.tmplog_path)
                
                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

    def do_pdf(self):
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.utils.errormsg("Please install Ghostscript to do PDF export")
                return
            with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
                for idx,item in enumerate(self.id_to_process):
                    # first, export to PDF using inkscape
                    tmp_export_path = self.tmpdir + "/" + item.get('id') + ".pdf"
                    run_command([
                        "inkscape",
                        "--export-area-drawing",
                        "-d", "{0}".format(self.options.dpi),
                        "-j","-i", item.get('id'),
                        "-o", "{0}".format(tmp_export_path),
                        self.myfile
                    ], self.tmplog_path)
                    self.tmpout.append(tmp_export_path)

                    # then, convert it to PDF CMYK using Ghostscript
                    real_export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + "-cmyk.pdf"
                    
                    # os check for ghostscript
                    if platform.system() == "Windows":
                        gs = "gswin32c"
                    else:
                        gs = "gs"
                    
                    run_command([
                        "{0}".format(gs),
                        "-dSAFER", "-dBATCH", "-dNOPAUSE", "-dNOCACHE", "-sDEVICE=pdfwrite", "-dAutoRotatePages=/None",
                        "-sColorConversionStrategy=CMYK", "-dProcessColorModel=/DeviceCMYK", "-dAutoFilterColorImages=false",
                        "-dAutoFilterGrayImages=false", "-dColorImageFilter=/FlateEncode", "-dGrayImageFilter=/FlateEncode",
                        "-dDownsampleMonoImages=false", "-dDownsampleGrayImages=false",
                        "-sOutputFile={0}".format(real_export_path),
                        "{0}".format(tmp_export_path)
                    ], self.tmplog_path)

                    if self.with_zenity:
                        if not progressbar.is_active:
                            break
                        progressbar.update_progress(idx + 1, item.get('id'))
        else:
            with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
                for idx,item in enumerate(self.id_to_process):
                    export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + ".pdf"
                    command = [
                        "inkscape",
                        "--export-area-drawing",
                        "-d", "{0}".format(self.options.dpi),
                        "-j","-i", item.get('id'),
                        "-o", "{0}".format(export_path),
                        self.myfile
                    ]
                    run_command(command, self.tmplog_path)
                    if self.with_zenity:
                        if not progressbar.is_active:
                            break
                        progressbar.update_progress(idx + 1, item.get('id'))

    def do_svg(self):
        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            for idx,item in enumerate(self.id_to_process):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + ".svg"
                command = [
                    "inkscape",
                    "-j","-i", item.get('id'),
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

    def do_eps(self):
        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            for idx,item in enumerate(self.id_to_process):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + ".eps"
                command = [
                    "inkscape",
                    "--export-area-drawing",
                    "--export-ignore-filters",
                    "--export-text-to-path",
                    "--export-ps-level=3",
                    "-j","-i", item.get('id'),
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

    def do_booklet(self):
        if not self.has_ghostscript():
            inkex.utils.errormsg("Please install Ghostscript to do Booklet export")
            return
        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            for idx,item in enumerate(self.id_to_process):
                # first, export to PDF using inkscape
                tmp_export_path = self.tmpdir + "/" + item.get('id') + ".pdf"
                run_command([
                    "inkscape",
                    "--export-area-drawing",
                    "-d", "{0}".format(self.options.dpi),
                    "-j","-i", item.get('id'),
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)
                self.tmpout.append(tmp_export_path)

                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

            # os check for ghostscript
            if platform.system() == "Windows":
                gs = "gswin32c"
            else:
                gs = "gs"
            # then, convert it to PDF CMYK using Ghostscript
            real_export_path = "-sOutputFile=" + os.path.expandvars(self.options.output_dir) + "/Booklet-" + self.options.id_pattern + ".pdf"
            command = [
                "{0}".format(gs),"-dSAFER", "-dBATCH", "-dNOPAUSE", "-dNOCACHE", "-sDEVICE=pdfwrite"
            ]
            if self.options.with_cmyk:
                real_export_path = "-sOutputFile=" + os.path.expandvars(self.options.output_dir) + "/Booklet-" + self.options.id_pattern + "-cmyk" + ".pdf"
                command.append("-sColorConversionStrategy=CMYK")
                command.append("-dProcessColorModel=/DeviceCMYK")
            command.append(real_export_path)
            # sort by name first
            self.tmpout.sort(key=lambda s: [atoi(u) for u in re.split(r'(\d+)', s)])
            # removing inputfile temp
            self.tmpout.remove(self.myfile)
            command = command + self.tmpout
            run_command(command, self.tmplog_path)
            # re-append for cleanup later
            self.tmpout.append(self.myfile)
            # inkex.utils.debug(command)

    def do_webp(self):
        if not self.has_webp():
            inkex.utils.errormsg("Please install libwebp to do webp export")
            return
        with ProgressBar(self.options.format, len(self.id_to_process), self.with_zenity) as progressbar:
            for idx,item in enumerate(self.id_to_process):
                tmp_export_path = self.tmpdir + "/" + item.get('id') + ".png"
                # first, export to PNG
                run_command([
                    "inkscape",
                    "-j","-i", item.get('id'),
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)

                self.tmpout.append(tmp_export_path)

                # then, convert it to WEBP using cwebp
                real_export_path = os.path.expandvars(self.options.output_dir) + "/" + item.get('id') + ".webp"
                run_command([
                    "cwebp",
                    "-quiet",
                    "-o","{0}".format(real_export_path),
                    "{0}".format(tmp_export_path),
                ], self.tmplog_path)

                if self.with_zenity:
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1, item.get('id'))

    def has_ghostscript(self):
        if platform.system() == "Windows":
            gs = "gswin32c --help"
            status, output = self.get_cmd_output(gs)
        else:
            gs = "gs --help"
            status, output = self.get_cmd_output(gs)
        return status == 0 and 'Ghostscript' in output

    def has_imagemagick(self):
        command = 'convert --version'
        if platform.system() == 'Windows':
            command = 'magick convert --version'
        status, output = self.get_cmd_output(command)
        return status == 0 and 'ImageMagick' in output

    def has_zenity(self):
        status, output = self.get_cmd_output('zenity --help')
        return status == 0 and 'zenity' in output
    
    def has_webp(self):
        status, output = self.get_cmd_output('cwebp -help')
        return status == 0 and 'output.webp' in output
    
    def make_tmp_file(self, file_format):
        handler, self.myfile = tempfile.mkstemp(suffix=".svg",prefix="inkporter-%s-"%file_format)
        with open(handler, "w") as f:
            f.write(etree.tostring(self.document, encoding="utf-8",xml_declaration=True).decode("utf-8"))
        self.tmpout.append(self.myfile)
        self.tmpdir = tempfile.mkdtemp(prefix="inkporter")
        fd, self.tmplog_path = tempfile.mkstemp(prefix="inkporter-%s-%s-"%(file_format,self.options.id_pattern), suffix=".log")
        os.close(fd)

    def get_cmd_output(self, cmd):
        # Adapted from webslicer extension (extensions > web > slicer)
        if sys.platform != "win32":
            cmd = '{ ' + cmd + '; }'
        pipe = os.popen(cmd + ' 2>&1', 'r')
        text = pipe.read()
        sts = pipe.close()
        if sts is None:
            sts = 0
        if text[-1:] == '\n':
            text = text[:-1]
        return sts, text

    def do_cleanup(self):
        for item in self.tmpout:
            if os.path.exists(os.path.abspath(item)):
                os.remove(os.path.abspath(item))
        if os.path.isdir(self.tmpdir):
            os.rmdir(self.tmpdir)

    # called when extension is running
    def effect(self):
        if not self.has_zenity():
            if os.name != "nt":
                inkex.utils.debug(
                    "This extension requires 'zenity' to display progressbar,\n" 
                    "please install it if you want (optional).")
                self.with_zenity = False
            
        if len(self.options.id_pattern) > 0:
            new_nss = NSS
            new_nss[u're'] = u'http://exslt.org/regular-expressions'
            path_to_compile = "//*[re:match(@id,'(%s)','g')]" % self.options.id_pattern
            self.id_to_process = self.document.xpath(path_to_compile, namespaces=new_nss)
            
        if len(self.id_to_process) < 1:
            inkex.utils.errormsg(
                "Oops, Inkporter found nothing with %s pattern!" % self.options.id_pattern)
            exit()
        try:
            if not os.path.isdir(os.path.expandvars(self.options.output_dir)):
                os.mkdir(os.path.expandvars(self.options.output_dir))
            self.make_tmp_file(self.options.format)
            if self.options.format == "png":
                self.do_png()
            elif self.options.format == "jpg":
                self.do_jpg()
            elif self.options.format == "pdf":
                self.do_pdf()
            elif self.options.format == "svg":
                self.do_svg()
            elif self.options.format == "eps":
                self.do_eps()
            elif self.options.format == "booklet":
                self.do_booklet()
            elif self.options.format == "webp":
                self.do_webp()
            self.do_cleanup()
        except Exception as e:
            inkex.utils.errormsg(e)
            import traceback
            inkex.utils.errormsg(traceback.print_exc())


if __name__ == '__main__':
    e = Inkporter()
    e.run ()
