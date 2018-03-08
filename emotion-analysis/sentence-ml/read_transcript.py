import os
import re
import sys


def writef_without_timestamp(fn):

    # Filename
    fn_ = os.path.splitext(fn)[0]

    # Check timestamp
    pattern = re.compile("[0-9]*:[0-9]*:[0-9]*")

    with open(fn, 'r') as oldfile, open(fn_ + '_clipped.txt', 'w') as newfile:
        for line in oldfile:
            if not pattern.match(line):
                newfile.write(line)


if __name__ == '__main__':

    writef_without_timestamp(sys.argv[1])
