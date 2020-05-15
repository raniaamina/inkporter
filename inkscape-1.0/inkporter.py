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

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

__version__ = '1.1.0'

my_progressbar = None

def atoi(text):
    return int(text) if text.isdigit() else text

def run_command(commands, log_path):
    process = subprocess.Popen(commands, stdout=subprocess.STDOUT, stderr=subprocess.STDOUT, universal_newlines=True)
    with open(log_path, "a") as log:
        for line in process.stdout:
            log.write(line)

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
        for item in self.svg.selected:
            export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".png"
            command = [
                "inkscape",
                "-j","-i", item,
                "-d", self.options.dpi,
                "-o", "'%s'" % export_path,
                self.myfile
            ]
            run_command(command, self.tmplog_path)
        os.close(self.tmplog_fd)

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install Imagemagick to do JPG/Booklet export")
            return
        options = "-colorspace RGB"
        if self.options.with_cmyk:
            options = "-colorspace CMYK"
        for item in self.svg.selected:
            tmpfile_export = self.tmpdir + "/" + item + ".png"
            command = "inkscape -j -i {0} -o '{1}' -d {2} '{3}' 1>>{4} 2>>{4}".format(
                item, tmpfile_export, self.options.dpi, self.myfile, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmpfile_export)
            while not os.path.exists(tmpfile_export):
                sleep(1)
            file_export = os.path.expandvars(self.options.output_dir) + "/" + item + ".jpg"
            command2 = "convert '{0}' -background '{1}' -flatten -quality {2} {3} '{4}'".format(
                tmpfile_export, self.options.bg_color, self.options.quality, options, file_export)
            os.system(command2)
        os.close(self.tmplog_fd)

    def do_pdf(self):
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.utils.errormsg("Please install Ghostscript to do PDF export")
                return
            for item in self.svg.selected:
                tmpsvg_export = self.tmpdir + "/" + item + ".pdf"
                command = "inkscape -i {0} -j -C -d {1} -o '{2}' '{3}' 1>>{4} 2>>{4}".format(
                    item, self.options.dpi, tmpsvg_export, self.myfile, self.tmplog_path)
                os.system(command)
                self.tmpout.append(tmpsvg_export)
                while not os.path.exists(tmpsvg_export):
                    sleep(1)
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item + "-CMYK.pdf"
                command2 = "gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK " \
                    + "-dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode " \
                    + "-dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile='{0}' '{1}' 1>>{2} 2>>{2}".format(
                        export_path, tmpsvg_export, self.tmplog_path)
                os.system(command2)
        else:
            for item in self.svg.selected:
                tmpsvg_export = self.options.output_dir + "/" + item + ".pdf"
                command = "inkscape -i {0} -j -C -d {1} -o '{2}' '{3}' 1>>{4} 2>>{4}".format(
                    item, self.options.dpi, tmpsvg_export, self.myfile, self.tmplog_path)
                os.system(command)
        os.close(self.tmplog_fd)

    def do_svg(self):
        for item in self.svg.selected:
            file_export = os.path.expandvars(
                self.options.output_dir) + "/" + item + ".svg"
            command = "inkscape -j -i {0} -l -o '{1}' '{2}' 1>>{3} 2>>{3}".format(
                item, file_export, self.myfile, self.tmplog_path)
            os.system(command)
        os.close(self.tmplog_fd)

    def do_eps(self):
        for item in self.svg.selected:
            tmpsvg_export = self.tmpdir + "/" + item + ".svg"
            command = "inkscape -i {0} -l -o '{1}' '{2}' 1>>{3} 2>>{3}".format(
                item, tmpsvg_export, self.myfile, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmpsvg_export)
            while not os.path.exists(tmpsvg_export):
                sleep(1)
            export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".eps"
            command2 = "inkscape -o '{0}' '{1}' --export-area-page --export-ignore-filters --export-text-to-path --export-ps-level=3 1>>{2} 2>>{2}".format(
                export_path, tmpsvg_export, self.tmplog_path)
            os.system(command2)
        os.close(self.tmplog_fd)

    def do_booklet(self):
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install Imagemagick to do JPG/Booklet export")
            return
        for idx,item in enumerate(self.svg.selected):
            tmpsvg_export = self.tmpdir + "/" + item + ".pdf"
            command = "inkscape -i {0} -j -D -d {1} -o '{2}' '{3}' 1>>{4} 2>>{4}".format(
                item, self.options.dpi, tmpsvg_export, self.myfile, self.tmplog_path)
            os.system(command)
            inkex.utils.debug(command)
            self.tmpout.append(tmpsvg_export)
            # while not os.path.exists(tmpsvg_export):
            #     sleep(1)
        # export_path = os.path.expandvars(self.options.output_dir) + "/" + self.options.id_pattern + "-booklet.pdf"
        # export_mode = "\\"
        # self.tmpout.sort(key=lambda s: [atoi(u) for u in re.split(r'(\d+)', s)])
        # command = "rsvg-convert -f pdf -o '{0}' {1} 1>>{2} 2>>{2}".format(
        #     export_path, "".join(f + " " for f in self.tmpout), self.tmplog_path)
        # os.system(command)CMYK
        # if self.options.with_cmyk:
        #     export_path = os.path.expandvars(self.options.output_dir) + "/" + "CMYK-" + self.options.id_pattern + "-booklet.pdf"
        #     export_mode = "-sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK"
        # self.tmpout.remove(self.myfile)
        # command = "gs -q -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite {0} -sOutputFile='{1}' {2} 1>>{3} 2>>{3}".format(
        #     export_mode, export_path, ' '.join(x for x in self.tmpout), self.tmplog_path)
        # os.system(command)
        # os.close(self.tmplog_fd)
        # self.tmpout.append(self.myfile)
        # inkex.utils.debug(command)
    
    def do_webp(self):
        if not self.has_webp():
            inkex.utils.errormsg("Please install libwebp to do webp export")
            return
        for item in self.svg.selected:
            tmppng_export = self.tmpdir + "/" + item + ".png"
            command = "inkscape -j -i {0} -o '{1}' -d {2} '{3}' 1>>{4} 2>>{4}".format(
                item, tmppng_export, self.options.dpi, self.myfile, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmppng_export)
            while not os.path.exists(tmppng_export):
                sleep(1)
            export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".webp"
            command = "cwebp '{0}' -quiet -o '{1}' 1>>{2} 2>>{2}".format(
                tmppng_export, export_path, self.tmplog_path)
            os.system(command)
        os.close(self.tmplog_fd)

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
        self.tmplog_fd, self.tmplog_path = tempfile.mkstemp(prefix="inkporter-%s-%s-"%(file_format,self.options.id_pattern), suffix=".log")

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
            # self.do_cleanup()
        except Exception as e:
            inkex.utils.errormsg(e)
            import traceback
            inkex.utils.errormsg(traceback.print_exc())


if __name__ == '__main__':
    e = Inkporter()
    e.run ()
