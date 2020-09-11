#!/usr/bin/env python

import tempfile
import re
from lxml import etree
import sys
import shutil
import os
import inkex
from time import sleep
import warnings
import io

__version__ = '1.7.0'

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
        self.arg_parser.add_argument('--tab')
        
        
        self.arg_parser.add_argument("--id-pattern",
                                     type=str, dest="id_pattern",
                                     help="IDs to export")
                                     
                                     
        self.arg_parser.add_argument("--with-cmyk",
                                     type=inkex.Boolean, dest="with_cmyk",
                                     help="Use CMYK instead of RGB (for JPG/PDF)")
                                     
        self.arg_parser.add_argument("--pack-export",
                                     type=inkex.Boolean, dest="pack",
                                     help="Pack each IDs into ZIP")

#       Export Options

        self.arg_parser.add_argument("--png",
                                     type=inkex.Boolean, dest="png",
                                     help="Export to PNG")
                                     
        self.arg_parser.add_argument("--jpg",
                                     type=inkex.Boolean, dest="jpg",
                                     help="Export to JPG")
        
        self.arg_parser.add_argument("--pdf",
                                     type=inkex.Boolean, dest="pdf",
                                     help="Export to PDF")
        
        self.arg_parser.add_argument("--svg",
                                     type=inkex.Boolean, dest="svg",
                                     help="Export to SVG")
        
        self.arg_parser.add_argument("--eps",
                                     type=inkex.Boolean, dest="eps",
                                     help="Export to EPS")
        
        self.arg_parser.add_argument("--booklet",
                                     type=inkex.Boolean, dest="booklet",
                                     help="Export to Booklet-PDF")
        
        self.arg_parser.add_argument("--webp",
                                     type=inkex.Boolean, dest="webp",
                                     help="Export to WEBP")

        
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
        # temporary svg out file
        self.id_to_process = None
        self.tmpdir = tempfile.mkdtemp(prefix="inkporter")
        self.tmplog_fd, self.tmplog_path = tempfile.mkstemp(prefix="inkporter", suffix=".log")
        self.tmpout = []
    
    def do_png(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter {0} png {1} {2} {3}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi)
        os.system(command)
        
    def do_bundle(self):
        if not self.has_7zip():
            inkex.utils.errormsg("Please install and add 7-Zip directory to Environment Variable")
            return
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter {0} bundle {1} {2} {3} {4}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi)
        os.system(command)
        
    def do_jpg(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install and add ImageMagick directory to PATH Environment Variable")
            return
        if self.options.with_cmyk:
            options = "cmyk"            
            command = "start inkporter {0} jpeg {1} {2} {3} {4} {5} {6}".format(
                self.myfile, self.options.id_pattern, file_export, self.options.dpi,  options, self.options.bg_color, self.options.quality)
            os.system(command)
        else:
            options = "rgb"
            command = "start inkporter {0} jpeg {1} {2} {3} {4} {5} {6}".format(
                self.myfile, self.options.id_pattern, file_export, self.options.dpi, options, self.options.bg_color, self.options.quality)
            os.system(command)

    def do_pdf(self):
        file_export = '"' + self.options.output_dir + '"'
        if self.options.with_cmyk:
            if not self.has_gs32():
                inkex.utils.errormsg("Please Install and add Ghostscript 32 bit directory to PATH environment variable to export PDF-CMYK")
                return
            command = "start inkporter {0} pdf-cmyk {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
        else:   
            command = "start inkporter {0} pdf {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)

    def do_svg(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter {0} svg {1} {2}".format(
            self.myfile, self.options.id_pattern, file_export)
        os.system(command)

    def do_eps(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter {0} eps {1} {2}".format(
            self.myfile, self.options.id_pattern, file_export)
        os.system(command)

    def do_booklet(self):
        if not self.has_gs32():
            inkex.utils.errormsg("Please Install and add Ghostscript 32 bit directory to PATH environment variable to export Booklet (PDF)")
            return
            
        if self.options.with_cmyk:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter {0} book-cmyk {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
            os.close(self.tmplog_fd)
        else:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter {0} book {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
    
    def do_webp(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_webp():
            inkex.utils.errormsg("Please Download and add libwebp directory to PATH environment variable to export WEBP")
            return
        command = "start inkporter {0} webp {1} {2} {3}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi)
        os.system(command)
        
    def pack(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_7zip():
            inkex.utils.errormsg("Please Download and add 7-ZIP directory to PATH environment variable to pack each IDs into ZIP")
            return
        command = "start inkporter {0} webp {1} {2} {3}".format(
            self.myfile, self.options.id_pattern, file_export)
        os.system(command)

    def has_imagemagick(self):
        status, output = self.get_cmd_output('magick --version')
        return status == 0 and 'ImageMagick' in output
        
    def has_gs32(self):
        status, output = self.get_cmd_output('gswin32c --help')
        return status == 0 and 'Ghostscript' in output
        
    def has_webp(self):
        status, output = self.get_cmd_output('cwebp')
        return status == 0 and 'cwebp' in output
    
    def has_7zip(self):
        status, output = self.get_cmd_output('7z')
        return status == 0 and '7-Zip' in output
        
    
    def make_tmp_file(self):
        handler, self.myfile = tempfile.mkstemp(suffix=".svg",prefix="inkporter-")
        with io.open(handler, "w", encoding="utf-8") as f:
            f.write(etree.tostring(self.document, encoding="utf-8",xml_declaration=True).decode("utf-8"))
        self.tmpout.append(self.myfile)

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

    def quit_inkporter(self):
        warnings.filterwarnings("ignore")
        exit()

    # called when extension is running
    def effect(self):
        if not self.options.id_pattern:
            inkex.utils.errormsg(
                "Please fill ID Pattern to use this extension!")
            self.quit_inkporter()
        try:
            if not os.path.isdir(os.path.expandvars(self.options.output_dir)):
                os.mkdir(os.path.expandvars(self.options.output_dir))
            self.make_tmp_file()
            
            if self.options.png:
                self.do_png()
            if self.options.jpg:
                self.do_jpg()
            if self.options.pdf:
                self.do_pdf()
            if self.options.svg:
                self.do_svg()
            if self.options.eps:
                self.do_eps()
            if self.options.booklet:
                self.do_booklet()
            if self.options.webp:
                self.do_webp()
        except Exception as e:
            inkex.utils.errormsg(e)
            import traceback
            inkex.utils.errormsg(traceback.print_exc())
        
        if self.options.pack:
            self.pack()
        
        self.quit_inkporter()


if __name__ == '__main__':
    e = Inkporter()
    e.run ()
