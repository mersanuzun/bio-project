use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $splitter = $ARGV[0];
$base_path = "sci2tax.pl";
if (-e $base_path) {
  print "$base_path exists!\n";
}else{
  print "File not exist, please wait while downloading...\n";
  require "hash_parser.pl";
}

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
my %hash_deneme;
my %fetched_organisim = {};
my $protein_counter;
foreach my $organism (@organisms) {
  print "********************\n\n";
  print "ORGANISM $organism", "\n\n";
  $url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$organism\"$search_term\"&fil=&format=txt&force=yes";  
  my $response = $ua->get($url);
  if ($response->is_success) {
    $content = $response->decoded_content;
    my @proteins = split(/\/\/\s/, $content);
    foreach my $protein (@proteins) {
      if (($captured) = $protein =~ /ID\s+(\w+)/){
        $protein_counter += 1;
        
        while($protein =~ /(IPR.*);\s(.*)\./g){
          

          $fetched_organisim{$organism}{$captured}{$1} = $2;
          
        } 
        
      }
    }
          

                foreach my $organism (sort keys %fetched_organisim) {
                      #print "$fetched_organisim{$organism}\n";
                      foreach my $protein (sort keys %{$fetched_organisim{$organism}}){
                              
                              print "$protein \n";
                            foreach my $IPR (sort keys %{$fetched_organisim{$organism}{$protein}}){
      
                                
                                print "$IPR  => " , $fetched_organisim{$organism}{$protein}{$IPR} , "\n";


  }


  }
}




  }else{
    print "$organism could not be fetched";
    die $response->status_line;
  }
  print "\n";
  print "protein count: $protein_counter\n\n";
  $protein_counter = 0; 

  print "********************\n";
}





