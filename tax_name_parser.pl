my $filename = 'speclist.txt';
my $write_file = "parsed_tax_name.txt";
open(IN, '<', $filename)
  or die "Could not open file '$filename' $!";
open(my $out, ">", $write_file)
  or die "Could not open file $write_file";

while(<IN>){
   if ($_ =~ /(\d+)\:\sN=(.*)/){
      print $out "$1|$2\n";
   }
}
