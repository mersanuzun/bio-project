use LWP::UserAgent;
my ($type, $search_term) = @ARGV;
$file = 'parsed_tax_name.txt';
my $ua = LWP::UserAgent->new;

sub get_tax_id_or_name{
    open(FILE, "<$file") or
     die("Could not open log file. $!\n");
    while(<FILE>) {
    	if ($type eq "-t" and $_ =~ /$search_term\|(.*)/){
        	return $1;
      	}elsif ($type eq "-n" and $_ =~ /(\d*)\|$search_term.*/){
      		return $1;
      	}
   	}
}

$taxonomy = get_tax_id_or_name();
$url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$taxonomy&fil=&format=txt&force=yes";
my $response = $ua->get($url);
if ($response->is_success) {
     print $response->decoded_content;
}else{
     die $response->status_line;
}

