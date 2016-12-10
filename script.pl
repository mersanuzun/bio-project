require "sci2tax.pl";
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $splitter = $ARGV[0];
foreach my $arg (@ARGV) {
  if ($arg eq "-o"){
    $splitter = "-o";
    next;
  } elsif ($arg eq "-s"){
    $splitter = "-s";
    next;
  }
  if ($splitter eq "-o"){
    if ($arg =~ /^[^0-9]*$/){
      $arg = $sci2tax{$arg};
    }
    push(@organisms, $arg);
  }elsif ($splitter eq "-s"){
    $search_term = $arg;
  }
}


foreach my $organism (@organisms) {
  $url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$organism\"$search_term\"&fil=&format=txt&force=yes";  
  my $response = $ua->get($url);
  if ($response->is_success) {
    $content = $response->decoded_content;
    my @lines = split /\n/, $content;
    print "$organism\n";
    foreach my $line (@lines) {
      if ($line =~ /(IPR.*);\s(.*)\./){
        print "$1\n";
      }
    }
  }else{
    print "$organism could not be fetched";
    die $response->status_line;
  }
}
