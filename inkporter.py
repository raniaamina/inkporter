#!/usr/bin/env python3

import inkex
inkex.localize()

import os
import simplestyle

class Inkporter(inkex.Effect):
    def __init__(self):
        inkex.Effect.__init__(self)
        try:
            self.tty = open("/dev/tty", 'w')
        except:
            self.tty = open(os.devnull, 'w')  # '/dev/null' for POSIX, 'nul' for Windows.
            # print >>self.tty, "gears-dev " + __version__
        self.arg_parser.add_argument("-f", "--format", 
                                    type=str, dest="format",
                                    help="Preferred output format", default="png")
        self.arg_parser.add_argument("", "--dpi",
                                    type=int, dest="dpi",
                                    help="DPI for bitmap image output format", default=96)
        self.arg_parser.add_argument("-D", "--output-dir",
                                    type=str, dest="output_dir",
                                    help="Destination folder for saving your exports", default=os.path.expanduser("~"))
        self.arg_parser.add_argument("", "--bg-color",
                                    type=str, dest="bg_color",
                                    help="Background color for JPG Export", default="white")
        self.arg_parser.add_argument("-q", "--quality",
                                    type=int, dest="quality",
                                    help="Quality of image export, 0-100, higher better but slower",  default=100)

    def get_cmd_output(self, cmd):
        # Adapted from webslicer extension (extensions > web > slicer)
        # This solution comes from Andrew Reedick <jr9445 at ATT.COM>
        # http://mail.python.org/pipermail/python-win32/2008-January/006606.html
        # This method replaces the commands.getstatusoutput() usage, with the
        # hope to correct the windows exporting bug:
        # https://bugs.launchpad.net/inkscape/+bug/563722
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
        pass
    pass

if __name__ == '__main__':
    e = Inkporter()
    e.affect()
