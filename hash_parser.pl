use LWP::UserAgent;
my $ua = LWP::UserAgent->new;

$url = "http://www.uniprot.org/docs/speclist.txt";

my $response = $ua->get($url);
if ($response->is_success) {
    $content = $response->decoded_content;
    print "successfully Loaded.. \n";
}else{
    print "Not successfull try again..\n";
    die $response->status_line;

}

my $write_file = "sci2tax.pl";

open(my $out, ">", $write_file)
or die "Could not open file $write_file";

$all_tax = "%name_to_id = (\n";


my @lines = split /\n/, $content;
foreach my $line (@lines) {

    if ($line =~ /(\d+)\:\sN=(.*)/){
        $all_tax .= "\"$2\" => $1, \n";
    }
}

substr($all_tax, -3) = "";
$all_tax .= ");";
print $out $all_tax
