#!/usr/bin/env perl

use strict;
use warnings;

my $nThreads = $ARGV[0];
my $index = $ARGV[1];
my $prefix = $ARGV[2];
my $inputFa = $ARGV[3];
my $readGroup = $ARGV[4];


my @samFiles = ();

for (my $t = 0; $t < $nThreads; $t++) {
    open (my $fh, $prefix . "." . $t) || die "cannot open $!";
    push @samFiles, $fh;
}

open(FA, $inputFa) || die "cannot open $!";

open(INDEX, $index) || die "cannot open $!";
while (<INDEX>) {
    chomp;
    my ($t, $n) = split / /;

    if ($n == 0) {

        my $line = <FA>;
        chomp $line;
        my @F = split("\\|", $line);
        $F[0] =~ s/^>//;
        $F[0] =~ s/^\@//;
        my @tempInfos = ($F[0], 4, "*", 0, 0, "*", "*", 0, 0, $F[1], $F[3]);
        if ($readGroup ne "") {
            push @tempInfos, "RG:Z:" . $readGroup; 
        }
        print join("\t", @tempInfos) . "\n";
        <FA>; # skip line

    } else {

        my $fh = $samFiles[$t];
        my $line = <$fh>;
        print $line;
        <FA>; # skip line
        <FA>; # skip line
    }
}
