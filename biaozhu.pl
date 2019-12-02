use Encode;
#gb2312下
print "Input sentence:\n";
$sent=<stdin>;
chomp($sent);
Ime($sent);

sub Ime
{
	my($sent)=@_;
	$maxLength=0;
	ReadyHash(\$maxLength,\%hashWP,\%hashPP,\%hashWord);
	#print "max:$maxLength\n";
	BuildLattice($sent,\@arrayWord,\@Lattice);#三维数组
	Comput(\@Lattice);
	@RetArray=Backward(\@Lattice); 
	foreach (my $i=0;$i<@RetArray;$i++){
		print "$arrayWord[$i]\/$RetArray[$i] ";
	}
}
=pod我爱你中国
for(my $i=0;$i<@Lattice;$i++){
	for(my $j=0;$j<@{$Lattice[$i]};$j++){
		for(my $k=0;$k<4;$k++){		
			print "${${$Lattice[$i]}[$j]}[$k] ";
		}
	print "\n";
	getc();
	}
}
=cut
sub ReadyHash
{
	my($refMaxlen,$RefhashWP,$RefhashPP,$RedhashWord)=@_;
	open(sent,"send.txt");#w:world 词 p:property 词性
	while(<sent>){
		chomp;
		if(/(.+) (.+) (.+)/){
			my $Utf8Word=decode("gbk",$1);
			if( length($Utf8Word)>${$refMaxlen} ){
				${$refMaxlen}=length($Utf8Word);
			}
			${${$RefhashWP}{$1}}{$2}=$3;
			${$RedhashWord}{$1}=1;
		}
	}
	close(sent);
	
	open(trans,"trans.txt");#w:world 词 p:property 词性
	while(<trans>){
		chomp;
		if(/(.+) (.+)/){
			${$RefhashPP}{$1}=$2;
		}
	}
	close(trans);
}

sub BuildLattice
{
	my($sent,$RefArrayWord,$RefLattice)=@_;
	@{$RefArrayWord}=Segment($sent,$maxLength);
	@array=@{$RefArrayWord};
	unshift(@array,"Begin");
	push(@array,"End");
	#在GetHzs中加入 Begin beg End end
	for(my $i=0;$i<@array;$i++){
		my @cloum=();
		foreach (keys %{$hashWP{$array[$i]}}){
				my @unit=();
				push(@unit,0);
				push(@unit,0);
				push(@unit,$_);
				push(@unit,$array[$i]);
				push(@cloum,\@unit);
				#print "hh:$array[$i] $_\n";
			}
		push(@{$RefLattice},\@cloum);
	}
}

sub Segment
{
	my($sent,$MaxLen)=@_;
	my @array=();
	my $Utf8Line=decode("gbk",$sent);
	while( length($Utf8Line) ){
		if(length($Utf8Line)<$MaxLen){
		   $MaxLen=length($Utf8Line);
		}
		for(my $i=$MaxLen;$i>0;$i--){
			$tolookup=substr($Utf8Line,0,$i);
			$gb_tolookup=encode("gbk",$tolookup);
			if(defined $hashWord{$gb_tolookup}){
				last;
			}
			if($i==1){
				last;
			}
		}
		push(@array,$gb_tolookup);
		$Utf8Line=substr($Utf8Line,length($tolookup),length($Utf8Line)-length($tolookup));
		#print "seged:$gb_tolookup\n";
	}
	return @array;
}

sub Comput
{
	my($RefLattice)=@_;
	${${${$RefLattice}[0]}[0]}[0]=5;
	for(my $i=1;$i<@{$RefLattice};$i++){#第i列
		for(my $j=0;$j<@{${$RefLattice}[$i]};$j++){#第i列每一个汉字
			my $valu=100000;
			my $pointer=0;
			for(my $k=0;$k<@{${$RefLattice}[$i-1]};$k++){#第i-1列每一个汉字
				$previous=${${$RefLattice}[$i-1]}[$k];
				$current=${${$RefLattice}[$i]}[$j];
				$rate=Trans(${$previous}[2],${$current}[2])+Launch(${$current}[3],${$current}[2])+${$previous}[0];
				if($rate<$valu){#trans、launch都取了-log 所以取负值
					$valu=$rate;
					$pointer=$previous;
				}
			}
			${$current}[0]=$valu;
			${$current}[1]=$pointer;
		}
	}
}
sub Trans#局部最优推全局最优 条件概率
{
	my($pre,$cur)=@_;
	my $p2p=$pre."_".$cur;
	#print "pp:$twoHz\n";
	my $freq=10000;	
	if(defined $hashPP{$p2p}){
		$freq=$hashPP{$p2p};
	}
	return $freq;
}
sub Launch
{
	my($word,$prop)=@_;		
	my $freq=10000;	
	if(defined ${$hashWP{$word}}{$prop}){
		$freq=${$hashWP{$word}}{$prop};
	}
	return $freq;
}
sub Backward
{
	my($RefLattice)=@_;
	$RefUnit=${${${$RefLattice}[@{$RefLattice}-1]}[0]}[1];
	my @RetArray=();
	while(${$RefUnit}[1] != 0){
		unshift(@RetArray,${$RefUnit}[2]);
		#print "${$RefUnit}[3] ${$RefUnit}[2]\n";
		#getc();
		$RefUnit=${$RefUnit}[1];
	}
	return @RetArray;
}
=pod
=cut
