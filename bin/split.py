#!/usr/bin/env python

import sys

def usage():
    print 'usage: %s in_file out_file_prefix' % sys.argv[0]


chrs = [
"chr1",
"chr2",
"chr3",
"chr4",
"chr5",
"chr6",
"chr7",
"chr8",
"chr9",
"chr10",
"chr11",
"chr12",
"chr13",
"chr14",
"chr15",
"chr16",
"chr17",
"chr18",
"chr19",
"chr20",
"chr21",
"chr22",
"chrX",
"chrY",
"chrM",
"*",
]


if __name__ == '__main__':

    if len(sys.argv) != 3:
        usage()
        sys.exit(1)

    in_file = sys.argv[1]
    out_prefix = sys.argv[2]

    out_files = dict([[c, open('%s.%d' % (out_prefix, i), 'w')]
                            for i, c in enumerate(chrs)])

    f = open(in_file)
    for line in f:
        name, flag, seq, loc, rest = line.split('\t', 4) 
        out_files[seq].write(line)

