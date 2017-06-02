#!/usr/bin/perl
use File::Basename;

my $file = shift @ARGV;

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
	
	system("ln -s ".$path."Aligned.out.bam ".$tmp[$#tmp].".bam");
	system("ln -s ".$path."Aligned.out.bam.bai ".$tmp[$#tmp].".bam.bai");

	$command = "sbatch --output=MapQAndMarkDup".$tmp[$#tmp]." -J MapQAndMarkDup".$tmp[$#tmp]." ~/scripts/MapQAndMarkDuplicates.sh ".$tmp[$#tmp].".bam\n";
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;

	$ret=~/(\d+)/;
	my $jid= $1;
	push(@CollectJIDs,$jid);
#call-1 original
	$command = "sbatch -J JAC_Call1".$tmp[$#tmp]." ~/scripts/JACUSA_stranded_call1_cDNA_univers.sh ".$tmp[$#tmp].".bam call1_".$tmp[$#tmp]."\n";
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;

#call-1
	$command ="sbatch --dependency=afterok:".$jid." --output=JAC_Call1_MapQAndMarkDup".$tmp[$#tmp]." -J JAC_Call1_MapQAndMarkDup".$tmp[$#tmp]." ~/scripts/JACUSA_stranded_call1_cDNA_univers.sh ".$tmp[$#tmp]."_uniq_rmdup.bam call1_MapQAndMarkDup_".$tmp[$#tmp]."\n";
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;
	
}
close(IN);
#exit(0);

my @k= sort (keys %hash); 

for(my $t=0;$t<$#k;$t++)
  {
    for(my $v=$t+1;$v<@k;$v++)
      {
	
	$command ="sbatch --dependency=afterok:".join(",",@CollectJIDs)." -J JAC_Call2_MapQAndMarkDup ~/scripts/JACUSA_stranded_cDNA_univers.sh ".$hash_rmdup{$k[$t]}." ".$hash_rmdup{$k[$v]}." call2_".$k[$t]."_".$k[$v]."\n";
	print $command,"\n";
	$ret = `$command 2>&1`;
	chomp $ret;

	
      }
  }
