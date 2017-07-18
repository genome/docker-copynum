#clean up tsv output
cut -f 3-7 $1 | sed 's/"//g' > varscan.output.copynumber.called.recentered.segments.tsv.clean

#get rid of calls supported by only a few sites
#change number to adjust sensitivity/specificity 
#100 is specific, 10 is sensitive
perl -nae 'print $_ if $F[3] >= 50 || $F[0] eq '"chrom"'' varscan.output.copynumber.called.recentered.segments.tsv.clean > tmp