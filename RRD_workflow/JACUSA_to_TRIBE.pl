#!/usr/bin/perl

my $cond1 = shift @ARGV; #no of samples in cond1
my $cond2 = shift @ARGV; #no of samples in cond2

while(<>)
  {
    chomp;

    @tmp = split(/\t+/,$_);
    my $flag =0;
    my ($a,$c,$g,$t);
    my $strand = $tmp[5];

#designed to work on firststrand data
#check for validity

#run through cond1 + cond2 
for(my $x=6; $x<(6+$cond1+$cond2); $x++)
  {
    $tmp[$x]= TRIBE($tmp[$x]);
  }

my $flag = 0;

for(my $x=6; $x<(6+$cond1+$cond2); $x++)
  {
    $flag=1 if ($tmp[$x] eq 'FALSE');
  }

#
    if($flag == 0)
    {
      
      my $label = compareA2GBaseFreq(\@tmp,$cond1,$cond2);

      print join("\t",@tmp);
      print "\t",$label;
      print "\n";
    }
  }
#
sub compareA2GBaseFreq {
  my $tmpRef = shift;
  my $cond1 = shift;
  my $cond2 = shift;

  my @tmp = @{$tmpRef};

  my @cond1AG=(0,0);
  my @cond2AG=(0,0);

  for(my $x=6; $x<(6+$cond1); $x++)
  {
    my @inp= split(/\,/,$tmp[$x]);
    $cond1AG[0]+=$inp[0];
    $cond1AG[1]+=$inp[2];
  }

  for(my $x=6+$cond1; $x<(6+$cond1+$cond2); $x++)
  {
    my @inp= split(/\,/,$tmp[$x]);
    $cond2AG[0]+=$inp[0];
    $cond2AG[1]+=$inp[2];
  }

  #print $cond1AG[1],"\n";
  if($cond1AG[1]/($cond1AG[0]+1)>$cond2AG[1]/($cond2AG[0]+1)){return("COND1");}else{return("COND2");}
}

sub TRIBE {
  my $query = shift;
  my @inp= split(/\,/,$query);

#NO NEED - reverse complement

  #my @res = ($inp[3],$inp[2],$inp[1],$inp[0]);

  if(($inp[1]+$inp[3])<1){return(join(",",@inp));}
  else{return("FALSE");}
}
