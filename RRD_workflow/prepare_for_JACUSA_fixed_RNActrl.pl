#!/usr/bin/env perl
use File::Basename;

my $file = shift @ARGV;
my $genome = shift @ARGV;

my %hash;
my %hash_rmdup;
my @CollectJIDs;

open(IN,$file) || die "Could not";
while(my $line = <IN>)
{
	chomp $line;
	my @step1 = split(/\t+/,$line);
	my ($name,$path,$suffix) = fileparse($step1[0],"");


	my @tmp = split("\/",$path);

	unless($hash{$step1[1]}){
	$hash{$step1[1]}=$tmp[$#tmp].".bam";
	$hash_rmdup{$step1[1]}=$tmp[$#tmp]."_uniq_rmdup.bam";
      }
	else
	  {
	    $hash{$step1[1]}.=",".$tmp[$#tmp].".bam";
	    $hash_rmdup{$step1[1]}.=",".$tmp[$#tmp]."_uniq_rmdup.bam";
	  }

	system("ln -s ".$path."Aligned.out.bam ".$tmp[$#tmp].".bam") unless (-e $tmp[$#tmp].".bam");
	system("ln -s ".$path."Aligned.out.bam.bai ".$tmp[$#tmp].".bam.bai") unless (-e $tmp[$#tmp].".bam.bai");

	$command = "~/scripts/MapQAndMarkDuplicates.sh ".$tmp[$#tmp].".bam\n";
	unless(-e $tmp[$#tmp]."_uniq_rmdup.bam")
	  {
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;

	$ret=~/(\d+)/;
	my $jid= $1;
	push(@CollectJIDs,$jid);
      }

}
close(IN);
#exit(0);

my @k= sort (keys %hash);

foreach my $key (@k)
  {
    next if ($key eq "RNA");

	if(@CollectJIDs==0)
	  {
	$command ="~/scripts/JACUSA_stranded_cDNA_univers.sh ".$hash_rmdup{"RNA"}." ".$hash_rmdup{$key}." call2_RNA_".$key."\n";
      }
	else
	  {
	$command ="~/scripts/JACUSA_stranded_cDNA_univers.sh ".$hash_rmdup{"RNA"}." ".$hash_rmdup{$key}." call2_RNA_".$key."\n";
      }
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;



  }
