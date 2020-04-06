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

    def do_jpg(self):
        if not self.has_imagemagick():
            inkex.debug("Please install Imagemagick to do JPG/Booklet export")
            return
        options = "-colorspace RGB"
        if self.options.with_cmyk:
            options = "-colorspace CMYK"
        for item in self.selected:
            tmpfile_export = self.tmpdir + "/" + item + ".png"
            command = "inkscape -z -j -i {0} -e '{1}' -d {2} -f '{3}' &>>{4}".format(
                item, tmpfile_export, self.options.dpi, self.svg_file, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmpfile_export)
            sleep(1)
            file_export = os.path.expandvars(self.options.output_dir) + "/" + item + ".jpg"
            command2 = "convert '{0}' -background '{1}' -flatten -quality {2} {3} '{4}'".format(
                tmpfile_export, self.options.bg_color, self.options.quality, options, file_export)
            os.system(command2)
        os.close(self.tmplog_fd)

    def do_pdf(self):
        if self.options.with_cmyk:
            if not self.has_ghostscript():
                inkex.debug("Please install Ghostscript to do PDF export")
                return
            for item in self.selected:
                tmpsvg_export = self.tmpdir + "/" + item + ".svg"
                command = "inkscape -z -i {0} -l '{1}' -f '{2}' &>>{3}".format(
                    item, tmpsvg_export, self.svg_file, self.tmplog_path)
                os.system(command)
                self.tmpout.append(tmpsvg_export)
                tmppdf_export = self.tmpdir + "/" + item + ".pdf"
                command = "inkscape -z --export-area-page -A '{0}' -f '{1}' &>>{2}".format(
                    tmppdf_export, tmpsvg_export, self.tmplog_path)
                os.system(command)
                self.tmpout.append(tmppdf_export)
                sleep(1)
                export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".pdf"
                command2 = "gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK " \
                    + "-dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode " \
                    + "-dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile='{0}' '{1}' &>>{2}".format(
                        export_path, tmppdf_export, self.tmplog_path)
                os.system(command2)
        else:
            for item in self.selected:
                tmpsvg_export = self.tmpdir + "/" + item + ".svg"
                command = "inkscape -z -i {0} -l '{1}' -f '{2}' &>>{3}".format(
                    item, tmpsvg_export, self.svg_file, self.tmplog_path)
                os.system(command)
                self.tmpout.append(tmpsvg_export)
                sleep(1)
                export_path = os.path.expandvars(
                    self.options.output_dir) + "/" + item + ".pdf"
                command2 = "inkscape -z --export-area-page -A '{0}' -f '{1}' &>>{2}".format(
                    export_path, tmpsvg_export, self.tmplog_path)
                os.system(command2)
        os.close(self.tmplog_fd)

    def do_svg(self):
        for item in self.selected:
            file_export = os.path.expandvars(
                self.options.output_dir) + "/" + item + ".svg"
            command = "inkscape -z -j -i %s -l '%s' -f '%s' &>>%s" % (
                item, file_export, self.svg_file, self.tmplog_path)
            os.system(command)
        os.close(self.tmplog_fd)

    def do_eps(self):
        for item in self.selected:
            tmpsvg_export = self.tmpdir + "/" + item + ".svg"
            command = "inkscape -z -i {0} -l '{1}' -f '{2}' &>>{3}".format(
                item, tmpsvg_export, self.svg_file, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmpsvg_export)
            sleep(1)
            export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".eps"
            command2 = "inkscape -z -E '{0}' -f '{1}' --export-area-page --export-ignore-filters --export-text-to-path --export-ps-level=3 &>>{2}".format(
                export_path, tmpsvg_export, self.tmplog_path)
            os.system(command2)
        os.close(self.tmplog_fd)

    def do_booklet(self):
        if not self.has_imagemagick():
            inkex.debug("Please install Imagemagick to do JPG/Booklet export")
            return
        for item in self.selected:
            tmpsvg_export = self.tmpdir + "/" + item + ".svg"
            command = "inkscape -z -i {0} -l '{1}' -f '{2}' &>>{3}".format(
                item, tmpsvg_export, self.svg_file, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmpsvg_export)
            sleep(1)
        export_path = os.path.expandvars(self.options.output_dir) + "/" + self.options.id_pattern + ".pdf"
        self.tmpout.sort(key=lambda s: [atoi(u) for u in re.split(r'(\d+)', s)])
        command = "rsvg-convert -f pdf -o '{0}' {1}".format(
            export_path, "".join(f + " " for f in self.tmpout))
        os.system(command)
        os.close(self.tmplog_fd)
    
    def do_webp(self):
        if not self.has_webp():
            inkex.debug("Please install libwebp to do webp export")
            return
        for item in self.selected:
            tmppng_export = self.tmpdir + "/" + item + ".png"
            command = "inkscape -z -j -i {0} -e '{1}' -d {2} -f '{3}' &>>{4}".format(
                item, tmppng_export, self.options.dpi, self.svg_file, self.tmplog_path)
            os.system(command)
            self.tmpout.append(tmppng_export)
            sleep(1)
            export_path = os.path.expandvars(self.options.output_dir) + "/" + item + ".webp"
            command = "cwebp '{0}' -o '{1}'".format(
                tmppng_export, export_path)
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
            inkex.debug(
                "This extension requires rsvg-convert (from librsvg/librsvg-bin) to run, please install it before start exporting")
            return
        if len(self.options.id_pattern) > 0:
            new_nss = inkex.NSS
            new_nss[u're'] = u'http://exslt.org/regular-expressions'
            path_to_compile = "//*[re:match(@id,'(%s)','g')]" % self.options.id_pattern
            self.id_to_process = self.document.xpath(path_to_compile, namespaces=new_nss)
            self.selected = {}
            for item in self.id_to_process:
                self.selected[item.attrib['id']] = item
        if len(self.selected) < 1:
            inkex.debug(
                "Please select at least 1 object or fill ID Pattern to use this extension!")
            return
        try:
            if not os.path.isdir(os.path.expandvars(self.options.output_dir)):
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
            elif self.options.format == "webp":
                self.do_webp()
            self.do_cleanup()
        except Exception as e:
            inkex.debug(e)
            import traceback
            inkex.debug(traceback.print_exc())


if __name__ == '__main__':
    e = Inkporter()
    e.affect()
