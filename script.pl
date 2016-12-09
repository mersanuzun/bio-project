require "sci2tax.pl";
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $s = $ARGV[0];
foreach my $arg (@ARGV) {
  if ($arg eq "-o"){
    $s = "-o";
    next;
  } elsif ($arg eq "-s"){
    $s = "-s";
    next;
  }
  if ($s eq "-o"){
    push(@organisms, $arg);
  }elsif ($s eq "-s"){
    $search_term = $arg;
  }
}



foreach my $organism (@organisms) {
  $url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$organism\"$search_term\"&fil=&format=txt&force=yes";  
  my $response = $ua->get($url);
  if ($response->is_success) {
    $content = $response->decoded_content;
     if ($content eq ""){
      print "YOK";
     }else {
      print $content;
     }
  }else{
     die $response->status_line;
  }
}