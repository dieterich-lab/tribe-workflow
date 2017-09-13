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


    if($flag == 0)
    {
      #if(selectBase1gtBase2($tmp[6],$tmp[8]) && selectBase1gtBase2($tmp[7],$tmp[9]))
      print join("\t",@tmp);
      print "\n";
    }
  }

sub selectBase1gtBase2 {
  my $query1 = shift;
  my $query2 = shift;

  my @inp1= split(/\,/,$query1);
  my @inp2= split(/\,/,$query2);

  if($inp1[2]/($inp1[0]+1)>$inp2[2]/($inp2[0]+1)){return(1);}else{return(0);}
 
}

sub TRIBE {
  my $query = shift;
  my @inp= split(/\,/,$query);

#NO NEED - reverse complement

  #my @res = ($inp[3],$inp[2],$inp[1],$inp[0]);

  if(($inp[1]+$inp[3])<=2){return(join(",",@inp));}
  else{return("FALSE");}
}
