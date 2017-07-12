#!/gsc/bin/perl

use warnings;
use strict;
use IO::File;

# takes in CBS output (sorted!) and merges adjacent segments with identical
# scores into a single segment



sub fuzzyMatch{
    my ($x,$y) = @_;
    #if the numbers are within a small distance from each other
    #print STDERR join("\t",($x,$y,abs($x-$y))) . "\n";
    if(abs($x-$y) < 0.2){
        return 1;
    }
    return 0;
}

sub log2abs{
    my ($x) = @_;
    return((2**$x)*2);
}

my $inFh = IO::File->new( $ARGV[0] ) || die "can't open file\n";

#read in first line: header
my $line = $inFh->getline;
chomp($line);
my @fields = split("\t",$line);

die ("expected first line to be header") if $fields[0] !~ /^chrom/;

my $chr = $fields[0];
my $st = $fields[1];
my $sp = $fields[2];
my $probes = $fields[3];
#my $score = log2abs($fields[4]);
my $score = $fields[4];


while( my $line = $inFh->getline )
{
    chomp($line);
    my @fields = split("\t",$line);

    my $match=0;
    if ($fields[0] eq $chr){
        if(fuzzyMatch(log2abs($fields[4]),$score)){
            $match=1;
        }
    }

    if ($match){
        # print STDERR "merged:\n";
        # print STDERR join("\t",($chr,$st,$sp,$probes,$score)) . "\n";
        # print STDERR join("\t",@fields[0..4]) . "\n";

        $sp = $fields[2];
        #average score across both segs
        $score = (($score*$probes)+(log2abs($fields[4])*$fields[3]))/($probes+$fields[3]);
        $probes = $probes + $fields[3];
    } else {
        print join("\t",($chr,$st,$sp,$probes,$score)) . "\n";
        $chr = $fields[0];
        $st = $fields[1];
        $sp = $fields[2];
        $probes = $fields[3];
        $score = log2abs($fields[4])
    }
}
#clear out the end
print join("\t",($chr,$st,$sp,$probes,$score)) . "\n";
