#!/usr/bin/env python

import inkex
inkex.localize()

import os
import shutil
import sys
import simplestyle
import tempfile


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
        self.tmpdir = tempfile.mkdtemp(prefix="inkporter")
        self.tmpout = []

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.debug("Please install Imagemagick to do JPG/Booklet export")
            return
        for item in self.selected:
            tmpfile_export = self.tmpdir + "/" + item + ".png"
            command = "inkscape -z -j -i '%s' -e %s -d %d -f %s @>/dev/null" % (item, tmpfile_export, self.options.dpi, os.path.abspath(self.svg_file))
            os.system(command)
            self.tmpout.append(tmpfile_export)
            command2 = "convert '%s' -background '%s' -flatten -quality %d -colorspace CMYK '%s'" % (tmpfile_export, 
                        self.options.bg_color, 
                        self.options.quality, 
                        os.path.expandvars(self.options.output_dir) + "/" + item + ".jpg")
            os.system(command2)

    def do_pdf(self):
        # TODO
        if not self.has_ghostscript():
            inkex.debug("Please install Ghostscript to do PDF export")
            return
        command = ""

    def do_svg(self):
        for item in self.selected:
            file_export = os.path.expandvars(self.options.output_dir) + "/" + item + ".svg"
            command = "inkscape -z -j -i '%s' -l '%s' -f %s @>/dev/null" % (item, file_export, os.path.abspath(self.svg_file))
            os.system(command)

    def do_eps(self):
        # TODO
        command = ""

    def do_booklet(self):
        # TODO
        if not self.has_imagemagick():
            inkex.debug("Please install Imagemagick to do JPG/Booklet export")
            return
        command = ""

    def has_ghostscript(self):
        status, output = self.get_cmd_output('gs --help')
        return status == 0 and 'Ghostscript' in output

    def has_imagemagick(self):
        status, output = self.get_cmd_output('convert --version')
        return status == 0 and 'ImageMagick' in output
    
    def has_rsvg(self):
        status, output = self.get_cmd_output('rsvg-convert --version')
        return status == 0 and 'rsvg-convert' in output

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
        if len(self.selected) < 1:
            inkex.errmsg("Please select at least 1 object or id to use this extension!")
            return
        try:
            if not os.path.isdir(self.options.output_dir):
                os.mkdir(os.path.expandvars(self.options.output_dir))
            if self.options.format == "jpg":
                self.do_jpg()
            elif self.options.format == "pdf":
                self.do_pdf()
            elif self.options.format == "svg":
                self.do_svg()
            elif self.options.format == "eps":
                self.do_eps()
            elif self.options.format == "booklet":
                self.do_booklet()
            self.do_cleanup()
        except Exception as e:
            import traceback
            inkex.debug(traceback.print_exc())
            inkex.debug(e)

if __name__ == '__main__':
    e = Inkporter()
    e.affect()
