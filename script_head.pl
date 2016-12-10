#Script.pl in başına eklencek kodlar.
$base_path = "sci2tax.pl";
if (-e $base_path) {
	print "$base_path exists!\n";
}else{
	print "file not exist \n";
	require "hash_parser.pl";
}
