#训练词的unigram和bigram
#unigram词频文件T2Freq.txt $hashUni{$ci} 
#bigram左右都是最大长度匹配
use Encode;
use utf8;
GetAllCi("T2Freq.txt",\%hashUni,\$maxLength);#4
ComputUniBi("train",\%hashUni,\%hashBin,$maxLength);
ReadyFiles(\%hashUni,\%hashBin,"uni.txt","bin.txt");
#print "aa$maxLength";
sub ReadyFiles
{
	my($RefhashUni,$RefhashBin,$unifile,$binfile)=@_;
	open(Out,">$unifile");
	foreach (sort{ ${$RefhashUni}{$b}<=>${$RefhashUni}{$a} }  keys %{$RefhashUni}){
	   my $oneword=encode("gbk",$_);
	   print Out "$oneword:${$RefhashUni}{$_}\n";
	}
	close(Out);
	
	open(Out2,">$binfile");
	foreach (sort keys %{$RefhashBin}){
	   my $oneword=encode("gbk",$_);
	   print Out2 "$oneword:${$RefhashBin}{$_}\n";
	}
	close(Out2);
}
sub ComputUniBi
{
	my($file,$RefhashUni,$RefhashBin,$MaxLen)=@_;
	open(in,$file);
	while($line=<in>){
		chomp($line);
		my $Utf8Line=decode("gbk",$line);
		$ci_1=GetOneCi(\$Utf8Line,$MaxLen,$RefhashUni);
		#print "ci:$ci_1\n";
		#getc();		
		while( length($Utf8Line) ){
			$ci_2=GetOneCi(\$Utf8Line,$MaxLen,$RefhashUni);
			$twoCi=$ci_1."_".$ci_2;
			${$RefhashBin}{$twoCi}++;
			$ci_1=$ci_2;
		}
	}
	close(in);
}

sub GetOneCi
{
	my($RefUtf8Line,$MaxLen,$RefhashUni)=@_;
	if(length(${$RefUtf8Line})<$MaxLen){
	   $MaxLen=length(${$RefUtf8Line});
	}
	#print "${$RefUtf8Line}\n";
	for(my $i=$MaxLen;$i>0;$i--){
		$tolookup=substr(${$RefUtf8Line},0,$i);
		#print "here:$tolookup\n";
		#getc();
		if(defined ${$RefhashUni}{$tolookup}){
			last;
		}
		if($i==1){
			$tolookup=substr(${$RefUtf8Line},0,1);
			${$RefhashUni}{$tolookup}++;
			last;
		}
	}
	${$RefUtf8Line}=substr(${$RefUtf8Line},length($tolookup),length(${$RefUtf8Line})-length($tolookup));
	return $tolookup;
}

sub GetAllCi
{
	my($file,$RefhashUni,$RefmaxLength)=@_;
	${$RefmaxLength}=0;
	open(in,$file);
	while(<in>){
		chomp;
		if(/(.+):(.+)/){	
			my $Utf8word=decode("gbk",$1);
			${$RefhashUni}{$Utf8word}=$2;
		    #print "length($Utf8word)\n";
		    #getc();
			if(length($Utf8word)>${$RefmaxLength}){
				${$RefmaxLength}=length($Utf8word);
			}
		}
	}
	close(in);
}