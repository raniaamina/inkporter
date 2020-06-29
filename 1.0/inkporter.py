#!/usr/bin/env python

import tempfile
import re
from lxml import etree
import sys
import shutil
import os
import inkex
from time import sleep

__version__ = '1.1.0'

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
        # temporary svg out file
        self.id_to_process = None
        self.tmpdir = tempfile.mkdtemp(prefix="inkporter")
        self.tmplog_fd, self.tmplog_path = tempfile.mkstemp(prefix="inkporter", suffix=".log")
        self.tmpout = []
    
    def do_png(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter_ext png {0} {1} {2} {3} {4}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color)
        os.system(command)
        
    def do_bundle(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_7z():
            inkex.utils.errormsg("Please install and add 7-Zip directory to Environment Variable to do Booklet (PDF) export")
            return
        command = "start inkporter_ext bundle {0} {1} {2} {3} {4}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color)
        os.system(command)
        
    def do_jpg(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_imagemagick():
            inkex.utils.errormsg("Please install and add ImageMagick directory to Environment Variable")
            return
        options = " RGB"
        if self.options.with_cmyk:
            options = "CMYK"
            
        command = "start inkporter_ext jpeg {0} {1} {2} {3} {4} {5} {6}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi, self.options.bg_color, self.options.quality, options)
        os.system(command)

    def do_pdf(self):
        file_export = '"' + self.options.output_dir + '"'
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.utils.errormsg("Please install and add Ghostscript 32bit directory to Environment Variable to export PDF with CMYK color space")
                return
            command = "start inkporter_ext pdf_cmyk {0} {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
        else:
            command = "start inkporter_ext pdf {0} {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
        os.close(self.tmplog_fd)

    def do_svg(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter_ext svg {0} {1} {2}".format(
            self.myfile, self.options.id_pattern, file_export)
        os.system(command)
        os.close(self.tmplog_fd)

    def do_eps(self):
        file_export = '"' + self.options.output_dir + '"'
        command = "start inkporter_ext eps {0} {1} {2}".format(
            self.myfile, self.options.id_pattern, file_export)
        os.system(command)
        os.close(self.tmplog_fd)

    def do_booklet(self):
        if not self.has_ghostscript():
            inkex.utils.errormsg("Please install and add Ghostscript 32bit directory to Environment Variable to do Booklet (PDF) export")
            return
        if self.options.with_cmyk:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter_ext booklet_cmyk {0} {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
            os.close(self.tmplog_fd)
        else:
            file_export = '"' + self.options.output_dir + '"'
            command = "start inkporter_ext booklet {0} {1} {2}".format(
                self.myfile, self.options.id_pattern, file_export)
            os.system(command)
            os.close(self.tmplog_fd)
    
    def do_webp(self):
        file_export = '"' + self.options.output_dir + '"'
        if not self.has_webp():
            inkex.utils.errormsg("Please download and add libwebp directory to Environment Variable to do webp export")
            return
        command = "start inkporter_ext webp {0} {1} {2} {3}".format(
            self.myfile, self.options.id_pattern, file_export, self.options.dpi)
        os.system(command)
        os.close(self.tmplog_fd)

    def has_ghostscript(self):
        status, output = self.get_cmd_output('gswin32c --help')
        return status == 0 and 'Ghostscript' in output
        
    def has_7z(self):
        status, output = self.get_cmd_output('7z --help')
        return status == 0 and '7-Zip' in output

    def has_imagemagick(self):
        status, output = self.get_cmd_output('magick --version')
        return status == 0 and 'ImageMagick' in output

    def has_webp(self):
        status, output = self.get_cmd_output('cwebp -help')
        return status == 0 and 'output.webp' in output
    
    def make_tmp_file(self, file_format):
        handler, self.myfile = tempfile.mkstemp(suffix=".svg",prefix="inkporter-%s-"%file_format)
        with open(handler, "w") as f:
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

    def do_cleanup(self):
        # for item in self.tmpout:
            # if os.path.exists(os.path.abspath(item)):
                # os.remove(os.path.abspath(item))
        # if os.path.isdir(self.tmpdir):
            # os.rmdir(self.tmpdir)
        print("hai")

    # called when extension is running
    def effect(self):
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
            elif self.options.format == "bundle":
                self.do_bundle()
            self.do_cleanup()
        except Exception as e:
            inkex.utils.errormsg(e)
            import traceback
            inkex.utils.errormsg(traceback.print_exc())
            print("hai")
            


if __name__ == '__main__':
    e = Inkporter()
    e.run ()
