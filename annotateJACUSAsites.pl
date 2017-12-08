#!/usr/bin/env perl

#input prefix
#condition1
#condition2

my $input = shift @ARGV;
my $condition1 = shift @ARGV;
my $condition2 = shift @ARGV;

my $col=7+$condition1+$condition2;


open(IN,$input) || die "Could not read from $input";

open(OUT,">".$input."_processed_sense.txt") || die "Could not write ";

#gene 
while(<IN>){
  #processed_sense.txt
  next unless /gene\_id\s\"(\S+)\"/;
  my $gid = $1; /transcript\_id\s\"(\S+)\"/; 
  @tmp=split(/\t+/,$_);
  print OUT join("\t",@tmp[0..$col]);

  print OUT "\t",$tmp[$col+3],"\t";
  print OUT "\t",$gid,"\t",$1,"\n";

  }

close(IN);
close(OUT);

open(IN, $input."_processed_sense.txt") || die "Could not open again";
open(OUT,">".$input."_one_site_processed_sense.txt") || die "Could not write ";
open(OUT2,">".$input."_one_gene_processed_sense.txt") || die "Could not write ";

my %hash;
my %hash2;
 
while(<IN>){
  chomp;
  @tmp=split(/\t+/,$_);

  $hash{$tmp[0]."_".$tmp[1].":".join("/",@tmp[($col+1)..($col+2)])} =join("\t",@tmp[0..$col]);

  	$hash2{$tmp[$col+2]}{$tmp[0]."_".$tmp[1]} = $tmp[4]."\t".join("\t",@tmp[5..$col]);

  }
  foreach my $key (sort keys %hash){
    print OUT $key,"\t",$hash{$key},"\n";
  }

	
  foreach my $key (sort keys %hash2){
    foreach my $key2 (sort keys %{$hash2{$key}}){
	 print OUT2 $key."\t".$key2."\t".$hash2{$key}{$key2},"\n";}
	 }

#site
#gene


close(OUT2);
close(OUT);
close(IN);

#cast into code
#cat ${PREFIX}"_sense.txt"|perl -e 'my $col=12; while(<>){next unless /gene\_id\s\"(\S+)\"/; my $gid = $1; /transcript\_id\s\"(\S+)\"/; @tmp=split(/\t+/,$_); print join("\t",@tmp[0..$col]); print "\t",$tmp[$col+3],"\t"; print "\t",$gid,"\t",$1,"\n";}' > ${PREFIX}"_processed_sense.txt"

#condense to one site dump
#cat ${PREFIX}"_processed_sense.txt" |perl -e 'my $col=12; my %hash; while(<>){chomp; @tmp=split(/\t+/,$_); $hash{$tmp[0]."_".$tmp[1].":".join("/",@tmp[($col+1)..($col+2)])} =join("\t",@tmp[0..$col]);} foreach my $key (sort keys %hash){print $key,"\t",$hash{$key},"\n";}'  > ${PREFIX}"_one_site_processed_sense.txt"

#gene-wise
#cat ${PREFIX}"_processed_sense.txt" |perl ~/scripts/test.pl > ${PREFIX}"_one_gene_processed_sense.txt"

#sense.txt_one_site_processed_sense.txt
