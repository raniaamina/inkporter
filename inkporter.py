#!/usr/bin/env python

import inkex
inkex.localize()

import os
import sys
import simplestyle


class Inkporter(inkex.Effect):
    def __init__(self, *args, **kwargs):
        inkex.Effect.__init__(self, *args, **kwargs)
        try:
            self.tty = open("/dev/tty", 'w')
        except:
            self.tty = open(os.devnull, 'w')  # '/dev/null' for POSIX, 'nul' for Windows.
            # print >>self.tty, "gears-dev " + __version__
        self.OptionParser.add_option('--tab')
        self.OptionParser.add_option("-f", "--format", 
                                    type="string", action="store", dest="format",
                                    help="Preferred output format", default="png")
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
        self.format_options = {
            "jpg": self.do_jpg,
            "pdf": self.do_pdf,
            "svg": self.do_svg,
            "eps": self.do_eps,
            "booklet": self.do_booklet,
        }
        self.svgout = {}

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.errmsg("Please install Imagemagick to do JPG/Booklet export")
            return
        pass

    def do_pdf(self):
        if not self.has_ghostscript():
            inkex.errmsg("Please install Ghostscript to do PDF export")
            return
        pass

    def do_svg(self):
        pass

    def do_eps(self):
        pass

    def do_booklet(self):
        if not self.has_imagemagick():
            inkex.errmsg("Please install Imagemagick to do JPG/Booklet export")
            return
        pass

    def has_ghostscript(self):
        status, output = self.get_cmd_output('gs --help')
        return status == 0 and 'Ghostscript' in output

    def has_imagemagick(self):
        status, output = self.get_cmd_output('convert --version')
        return status == 0 and 'ImageMagick' in output

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

    # called when extension is running
    def effect(self):
        inkex.debug(self.options)

if __name__ == '__main__':
    e = Inkporter()
    e.affect()
