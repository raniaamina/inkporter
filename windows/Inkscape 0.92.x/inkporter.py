#!/usr/bin/env python

import tempfile
import re
from lxml import etree
import sys
import shutil
import os
import inkex
from time import sleep
inkex.localize()

def atoi(text):
    return int(text) if text.isdigit() else text


class Inkporter(inkex.Effect):
    def __init__(self, *args, **kwargs):
        inkex.Effect.__init__(self, *args, **kwargs)
        try:
            self.tty = open("/dev/tty", 'w')
        except:
            # '/dev/null' for POSIX, 'nul' for Windows.
            self.tty = open(os.devnull, 'w')
            # print >>self.tty, "gears-dev " + __version__
        self.OptionParser.add_option('--tab')
        self.OptionParser.add_option("-f", "--format",
                                     type="string", action="store", dest="format",
                                     help="Preferred output format", default="png")
        self.OptionParser.add_option("--id-pattern",
                                     action="store", type="string", dest="id_pattern",
                                     help="IDs to export")
        self.OptionParser.add_option("--with-cmyk",
                                     action="store", type="inkbool", dest="with_cmyk",
                                     help="Use CMYK instead of RGB (for JPG/PDF)")
        self.OptionParser.add_option("", "--dpi",
                                     type="int", action="store", dest="dpi",
                                     help="DPI for bitmap image output format", default=96)
        self.OptionParser.add_option("-D", "--output-dir",
                                     type="string", action="store", dest="output_dir",
                                     help="Destination folder for saving your exports", default=os.path.expanduser("~"))
        self.OptionParser.add_option("", "--bg-color",
                                     type="string", action="store", dest="bg_color",
                                     help="Background color for JPG Export", default="white")
        self.OptionParser.add_option("-q", "--quality",
                                     type="int", action="store", dest="quality",
                                     help="Quality of image export, 0-100, higher better but slower",  default=100)
        # temporary svg out file
        self.id_to_process = None
        self.tmpdir = tempfile.mkdtemp(prefix="inkporter")
        self.tmplog_fd, self.tmplog_path = tempfile.mkstemp(prefix="inkporter", suffix=".log")
        self.tmpout = []
    
    def do_png(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter png {0} {1} {2} {3} {4}".format(
            self.svg_file, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color)
        os.system(command)
        
    def do_bundle(self):
        if not self.has_7z():
            inkex.debug("Please install and add 7z directory to Environment Variables to do PDF export")
            return
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter bundle {0} {1} {2} {3} {4}".format(
            self.svg_file, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color)
        os.system(command)

    def do_jpg(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_imagemagick():
            inkex.debug("Please install and add ImageMagick directory to Environment Variables to do PDF export")
            return
        if self.options.with_cmyk:
            options = "CMYK"
            command = "start inkporter jpeg_cmyk {0} {1} {2} {3} {4} {5} {6}".format(
                self.svg_file, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color, self.options.quality, options)
        else:
            options = " RGB"
            command = "start inkporter jpeg {0} {1} {2} {3} {4} {5} {6}".format(
                self.svg_file, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color, self.options.quality, options)
        os.system(command)

    def do_pdf(self):
        file_export = '"' + self.options.output_dir + '"'
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.debug("Please install and add Ghostscript 32bit directory to Environment Variables to do PDF export")
                return
            command = "start inkporter pdf_cmyk {0} {1} {2}".format(
                self.svg_file, self.options.id_pattern, file_export)
            os.system(command)
        else:
            command = "start inkporter pdf {0} {1} {2}".format(
                self.svg_file, self.options.id_pattern, file_export)
            os.system(command)
        os.close(self.tmplog_fd)

    def do_svg(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter svg {0} {1} {2}".format(
            self.svg_file, self.options.id_pattern, file_export)
        os.system(command)
        os.close(self.tmplog_fd)

    def do_eps(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter eps {0} {1} {2}".format(
            self.svg_file, self.options.id_pattern, file_export)
        os.system(command)
        os.close(self.tmplog_fd)

    def do_booklet(self):
        if not self.has_ghostscript():
            inkex.debug("Please install and add Ghostscript 32bit directory to Environment Variables to do PDF export")
            return
        if self.options.with_cmyk:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter booklet_cmyk {0} {1} {2}".format(
                self.svg_file, self.options.id_pattern, file_export)
            os.system(command)
            os.close(self.tmplog_fd)
        else:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter booklet {0} {1} {2}".format(
                self.svg_file, self.options.id_pattern, file_export)
            os.system(command)
            os.close(self.tmplog_fd)
    
    def do_webp(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_webp():
            inkex.debug("Please download and add libwebp directory to Environment Variables to do webp export")
            return
        command = "start inkporter webp {0} {1} {2} {3}".format(
            self.svg_file, self.options.id_pattern, file_export, self.options.dpi)
        os.system(command)
        os.close(self.tmplog_fd)

    def has_ghostscript(self):
        status, output = self.get_cmd_output('gswin32c --help')
        return status == 0 and 'Ghostscript' in output

    def has_imagemagick(self):
        status, output = self.get_cmd_output('convert --version')
        return status == 0 and 'ImageMagick' in output
    
    def has_webp(self):
        status, output = self.get_cmd_output('cwebp -help')
        return status == 0 and 'output.webp' in output
        
    def has_7z(self):
        status, output = self.get_cmd_output('7z --help')
        return status == 0 and '7-Zip' in output
    
    def has_inkporter(self):
        status, output = self.get_cmd_output('inkporter --help')
        return status == 0 and 'inkporter' in output

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
        if not self.has_inkporter():
            inkex.debug(
                "Please copy inkporter.bat to Inkscape extensions directory!")
            return
        if not self.options.id_pattern:
            inkex.debug(
                "Please fill ID Pattern to use this extension!")
            return
            
        try:
            if not os.path.isdir(os.path.expandvars(self.options.output_dir)):
                os.mkdir(os.path.expandvars(self.options.output_dir))
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
            elif self.options.format == "bundle":
                self.do_bundle()
            self.do_cleanup()
        except Exception as e:
            inkex.debug(e)
            import traceback
            inkex.debug(traceback.print_exc())


if __name__ == '__main__':
    e = Inkporter()
    e.affect()
