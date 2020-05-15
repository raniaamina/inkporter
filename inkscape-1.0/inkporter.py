#!/usr/bin/env python

import tempfile
import re
from lxml import etree
import sys
import shutil
import os
import inkex
import signal
import subprocess
from time import sleep

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

__version__ = '1.2.0'

def atoi(text):
    return int(text) if text.isdigit() else text

def run_command(commands, log_path):
    try:
        outputs = subprocess.check_output(commands, stderr=subprocess.STDOUT, universal_newlines=True)
        with open(log_path, "a") as log:
            for line in outputs:
                log.write(line)
    except subprocess.CalledProcessError as error:
        inkex.utils.errormsg(error.output)

class ProgressBar():
    def __init__(self, export_format, id_pattern, num_objects):
        self.__text = "Exporting Object with ID Pattern '{1}' to {0}".format(export_format.upper(), id_pattern)
        self.__num_objects = num_objects
        self.__active = False
    
    @property
    def is_active(self):
        if self.__active and self.__process.poll() is not None:
            self.__close()
        return self.__active

    def __enter__(self):
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
    
    def update_progress(self, progress):
        if self.is_active:
            current_progress = str(int(progress * 100 / self.__num_objects))
            self.__process.stdin.write("{0}\n".format(current_progress).encode("utf-8"))
            self.__process.stdin.write("# {0} ({1}/{2} done)\n".format(self.__text,progress,self.__num_objects).encode("utf-8"))
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
        try:
            self.tty = open("/dev/tty", 'w')
        except:
            # '/dev/null' for POSIX, 'nul' for Windows.
            self.tty = open(os.devnull, 'w')
            # print >>self.tty, "gears-dev " + __version__
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
                                     type=str, dest="bg_color",
                                     help="Background color for JPG Export", default="white")
        self.arg_parser.add_argument("-q", "--quality",
                                     type=int, dest="quality",
                                     help="Quality of image export, 0-100, higher better but slower",  default=100)
        self.id_to_process = None
        self.tmpout = []
    
    def do_png(self):
        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            for idx,item in enumerate(self.svg.selected):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".png"
                command = [
                    "inkscape",
                    "-j","-i", item,
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install Imagemagick to do JPG/Booklet export")
            return

        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            colorspace = "RGB"
            if self.options.with_cmyk:
                colorspace = "CMYK"
            for idx,item in enumerate(self.svg.selected):
                tmp_export_path = self.tmpdir + "/" + item + ".png"
                # first, export to PNG
                run_command([
                    "inkscape",
                    "-j","-i", item,
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)

                # while not os.path.exists(tmp_export_path):
                #     sleep(1)
                self.tmpout.append(tmp_export_path)

                # then, convert it to JPG using ImageMagick
                real_export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".jpg"
                run_command([
                    "convert",
                    "{0}".format(tmp_export_path),
                    "-background", "{0}".format(self.options.bg_color),
                    "-flatten",
                    "-quality", "{0}".format(self.options.quality),
                    "-colorspace", "{0}".format(colorspace),
                    "{0}".format(real_export_path)
                ], self.tmplog_path)

                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

    def do_pdf(self):
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.utils.errormsg("Please install Ghostscript to do PDF export")
                return
            with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
                for idx,item in enumerate(self.svg.selected):
                    # first, export to PDF using inkscape
                    tmp_export_path = self.tmpdir + "/" + item + ".pdf"
                    run_command([
                        "inkscape",
                        "--export-area-drawing",
                        "-d", "{0}".format(self.options.dpi),
                        "-j","-i", item,
                        "-o", "{0}".format(tmp_export_path),
                        self.myfile
                    ], self.tmplog_path)
                    self.tmpout.append(tmp_export_path)

                    # then, convert it to PDF CMYK using Ghostscript
                    real_export_path = os.path.expandvars(self.options.output_dir) + "/CMYK-" + item + ".pdf"
                    run_command([
                        "gs","-dSAFER", "-dBATCH", "-dNOPAUSE", "-dNOCACHE", "-sDEVICE=pdfwrite", "-dAutoRotatePages=/None",
                        "-sColorConversionStrategy=CMYK", "-dProcessColorModel=/DeviceCMYK", "-dAutoFilterColorImages=false",
                        "-dAutoFilterGrayImages=false", "-dColorImageFilter=/FlateEncode", "-dGrayImageFilter=/FlateEncode",
                        "-dDownsampleMonoImages=false", "-dDownsampleGrayImages=false",
                        "-sOutputFile={0}".format(real_export_path),
                        "{0}".format(tmp_export_path)
                    ], self.tmplog_path)

                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1)
        else:
            with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
                for idx,item in enumerate(self.svg.selected):
                    export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".pdf"
                    command = [
                        "inkscape",
                        "--export-area-drawing",
                        "-d", "{0}".format(self.options.dpi),
                        "-j","-i", item,
                        "-o", "{0}".format(export_path),
                        self.myfile
                    ]
                    run_command(command, self.tmplog_path)
                    if not progressbar.is_active:
                        break
                    progressbar.update_progress(idx + 1)

    def do_svg(self):
        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            for idx,item in enumerate(self.svg.selected):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".svg"
                command = [
                    "inkscape",
                    "-j","-i", item,
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

    def do_eps(self):
        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            for idx,item in enumerate(self.svg.selected):
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".eps"
                command = [
                    "inkscape",
                    "--export-area-drawing",
                    "--export-ignore-filters",
                    "--export-text-to-path",
                    "--export-ps-level=3",
                    "-j","-i", item,
                    "-o", "{0}".format(export_path),
                    self.myfile
                ]
                run_command(command, self.tmplog_path)
                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

    def do_booklet(self):
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install Imagemagick to do JPG/Booklet export")
            return
        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            for idx,item in enumerate(self.svg.selected):
                # first, export to PDF using inkscape
                tmp_export_path = self.tmpdir + "/" + item + ".pdf"
                run_command([
                    "inkscape",
                    "--export-area-drawing",
                    "-d", "{0}".format(self.options.dpi),
                    "-j","-i", item,
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)
                self.tmpout.append(tmp_export_path)

                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

            # then, convert it to PDF CMYK using Ghostscript
            real_export_path = "-sOutputFile=" + os.path.expandvars(self.options.output_dir) + "/BOOKLET-" + item + ".pdf"
            command = [
                "gs","-dSAFER", "-dBATCH", "-dNOPAUSE", "-dNOCACHE", "-sDEVICE=pdfwrite"
            ]
            if self.options.with_cmyk:
                real_export_path = "-sOutputFile=" + os.path.expandvars(self.options.output_dir) + "/CMYK-BOOKLET-" + item + ".pdf"
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
        with ProgressBar(self.options.format, self.options.id_pattern, len(self.svg.selected)) as progressbar:
            for idx,item in enumerate(self.svg.selected):
                tmp_export_path = self.tmpdir + "/" + item + ".png"
                # first, export to PNG
                run_command([
                    "inkscape",
                    "-j","-i", item,
                    "-d", str(self.options.dpi),
                    "-o", "{0}".format(tmp_export_path),
                    self.myfile
                ], self.tmplog_path)

                self.tmpout.append(tmp_export_path)

                # then, convert it to WEBP using cwebp
                real_export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".webp"
                run_command([
                    "cwebp",
                    "-quiet",
                    "-o","{0}".format(real_export_path),
                    "{0}".format(tmp_export_path),
                ], self.tmplog_path)

                if not progressbar.is_active:
                    break
                progressbar.update_progress(idx + 1)

    def has_ghostscript(self):
        status, output = self.get_cmd_output('gs --help')
        return status == 0 and 'Ghostscript' in output

    def has_imagemagick(self):
        status, output = self.get_cmd_output('convert --version')
        return status == 0 and 'ImageMagick' in output

    def has_rsvg(self):
        status, output = self.get_cmd_output('rsvg-convert --version')
        return status == 0 and 'rsvg-convert' in output
    
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
        if not self.has_rsvg():
            inkex.utils.errormsg(
                "This extension requires rsvg-convert (from librsvg/librsvg-bin) to run, please install it before start exporting")
            exit()
        if len(self.options.id_pattern) > 0:
            new_nss = inkex.utils.NSS
            new_nss[u're'] = u'http://exslt.org/regular-expressions'
            path_to_compile = "//*[re:match(@id,'(%s)','g')]" % self.options.id_pattern
            self.id_to_process = self.document.xpath(path_to_compile, namespaces=new_nss)
            self.svg.selected = {}
            for item in self.id_to_process:
                self.svg.selected[item.attrib['id']] = item
        if len(self.svg.selected) < 1:
            inkex.utils.errormsg(
                "Please select at least 1 object or fill ID Pattern to use this extension!")
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
