use Encode;
print "Input py:(spilt with space)";
$py=<stdin>;
$Ret=Ime($py);
print "\n$Ret\n";
sub Ime
{
	my($py)=@_;
	ReadyHash();
	BuildLattice($py,\@Lattice);#三维数组
	#Comput(\@Lattice);
	#return Backward(\@Lattice); 
}
#=pod
for(my $i=0;$i<@Lattice;$i++){
	for(my $j=0;$j<@{$Lattice[$i]};$j++){
		for(my $k=0;$k<4;$k++){
			if($k!=1){
			print "${${$Lattice[$i]}[$j]}[$k] ";
		}
		}
		
	}
	print "\n";
	#getc();
}
#=cut
sub ReadyHash
{
	open(in,"Py2Word.txt");
	while(<in>){
		chomp;
		if(/(.+):(.+)/){
			$py1=$1;
			$ci=$2;
		}
		my @array=$ci=~/[^ ]+/g;
		for(my $i=0;$i<@array;$i++){
			#print "here:$array[$i] ";
			push(@{$hashPy{$py1}},$array[$i]);
		}
	}
	close(in);
	
	open(in1,"uni.txt");
	while(<in1>){
		chomp;
		if(/(.+):(.+)/){
			$hashOne{$1}=$2;
			$totalHz+=$2;
			
		}
	}
	close(in1);
	
	open(in2,"bi.txt");
	while(<in2>){
		chomp;
		if(/(.+):(.+)/){
			$hashTwo{$1}=$2;
			$totalThz+=$2;
			#print "$1 $2\n";
			#getc();
		}
	}
	close(in2);
	$twoBone=$totalThz/$totalHz;
	print "here:$totalHz $totalThz\n";
}
sub BuildLattice
{
	my($py1,$RefLattice)=@_;
	my @pys=$py1=~/\S+/g;
	unshift(@pys,"Begin");
	push(@pys,"End");
	#在GetHzs中加入 Begin beg End end
	for(my $i=0;$i<@pys;$i++){
		#print "py:$onepy";
		my @cloum=();
		my $py="";
		for(my $j=$i;$j>=0;$j--){ 
			if($j==$i){
				$py=$pys[$j];
			}
			else{
				$py.=" "$pys[$j];
			}
			my @ci=$hashPy{$py};
			foreach (@ci){
				my @unit=();
				push(@unit,0);
				push(@unit,0);
				push(@unit,$_);
				push(@unit,$py)
				push(@cloum,\@unit);
			}
		}
		push(@{$RefLattice},\@cloum);
	}
}
=pod
sub Comput
{
	my($RefLattice)=@_;
	${${${$RefLattice}[0]}[0]}[0]=0.0001;
	for(my $i=1;$i<@{$RefLattice};$i++){#第i列
		for(my $j=0;$j<@{${$RefLattice}[$i]};$j++){#第i列每一个汉字
			my $valu=-100000;
			my $pointer=0;
			for(my $k=0;$k<@{${$RefLattice}[$i-1]};$k++){#第i-1列每一个汉字
				my $Utf8word=decode("gbk",${${${$RefLattice}[$i]}[$k]}[2]);
				my $forewardLook=length($Utf8word);
				my $rate=BinY(${${${$RefLattice}[$i-$forewardLook]}[$k]}[2],${${${$RefLattice}[$i]}[$j]}[2])+${${${$RefLattice}[$i-$forewardLook]}[$k]}[0];
				#print "${${${$RefLattice}[$i-1]}[$k]}[2],${${${$RefLattice}[$i]}[$j]}[2]:$rate\n";
				#getc();
				if($rate>$valu){
					$valu=$rate;
					$pointer=${${$RefLattice}[$i-$forewardLook]}[$k];
				}
			}
			${${${$RefLattice}[$i]}[$j]}[0]=$valu;
			#print "here:$valu\n";
			#getc();
			${${${$RefLattice}[$i]}[$j]}[1]=$pointer;
		}
	}
}
sub BinY#局部最优推全局最优 条件概率
{
	my($firHz,$secHz)=@_;
	my $twoHz=$firHz."_".$secHz;
	#print "222:$twoHz\n";
	my $freqOne=0.8;
	my $freqTwo=0.01;	
	if(defined $hashOne{$firHz}){
		$freqOne=$hashOne{$firHz};
	#	print "yes!dan:$firHz $freqOne\n";
	}
	my $res=log($freqOne/$freqTwo)/log(10);
	if(defined $hashTwo{$twoHz}){
		$freqTwo=$hashTwo{$twoHz}/$twoBone;
		$ret=log($freqTwo/$freqOne)/log(10);
	}
	
	#print "ret$twoHz:$ret";
	return $ret;
}

sub Backward
{
	my($RefLattice)=@_;
	$RefUnit=${${${$RefLattice}[@{$RefLattice}-1]}[0]}[1];
	my @RetArray=();
	while(${$RefUnit}[1] != 0){
		unshift(@RetArray,${$RefUnit}[2]);
		$RefUnit=${$RefUnit}[1];
	}
	my $Ret=join("",@RetArray);
	return $Ret;
}
=cut
