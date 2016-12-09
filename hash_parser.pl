

my $filename = 'parsed_tax_name.txt';
my $write_file = "sci2tax.pl";
open(IN, '<', $filename)
  or die "Could not open file '$filename' $!";
open(my $out, ">", $write_file)
  or die "Could not open file $write_file";

$all_tax = "%name_to_id = (\n"; 
while(<IN>){
   if ($_ =~ /(\d+)\|(.*)/){
      $all_tax .= "\"$2\" => $1, \n";
   }
}
substr($all_tax, -3) = "";
$all_tax .= ");";
print $out $all_tax