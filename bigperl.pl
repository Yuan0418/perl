
open(in1,"dict_num.txt");
while(<in1>)
{
	#print out $_;
	if(/(.+)\s+(.+)/){
	#print out "1";
	$hash{$1}=$2;
	}
}
open(in2,"idiom.txt");
while(<in2>)
{
	if(/(.+)\s+.+/){
	 if( defined $hash{$1} ){
	    $hash_n{$1}=$hash{$1};
	 }
	 else{
		$hash_n{$1}=1;
	 }
	}
}
open(out1,">idiom_num.txt");
foreach $idiom(sort {$hash{$b}<=>$hash{$a}} keys %hash_n){
	print out1 "$idiom $hash_n{$idiom}\n";
}
#hash里面是所有的 idiom num
#DIR *.* /S /b 列出盘里所有的文件和路径
#置空 @list = () ;%hash = () ;$str=""
=pod
$lc=int(rand(2));
#$lc表示横或竖的放置成语 0横1竖
for($l=1;$l<8;;){
  for($c=1;$c<8;;){
	if( int(rand(2)) == 0 ){
		if( not defined $hash1{$l}{$c} and not defined $hash1{$l}{$c+1} and not defined $hash1{$l}{$c+2} and not defined $hash1{$l}{$c+3} ){
			$idiom
			($hash1{$l}{$c},$hash1{$l}{$c+1},$hash1{$l}{$c+2},$hash1{$l}{$c+3})=$idiom~=/[^\s+]/g;
			}
	}
  }
}
=cut