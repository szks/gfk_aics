#!/usr/bin/env python

import sys

header_lines = 5


def usage():
    print 'usage: %s num_threads file_prefix' % sys.argv[0]


if __name__ == '__main__':

    if len(sys.argv) != 3:
        usage()
        sys.exit(1)

    num_threads = int(sys.argv[1])
    file_prefix = sys.argv[2]

    index = open(file_prefix + '.index', 'r')
    in_files = [open('%s.%d' % (file_prefix, i), 'r')
                for i in range(num_threads)]
    out_file = open(file_prefix, 'w')

    # copy header
    for i in range(header_lines):
        header = in_files[0].readline()
        out_file.write(header)

    for line in index:
        t, n = map(int, line.split())
        for i in range(n):
            data = in_files[t].readline()
            out_file.write(data)
