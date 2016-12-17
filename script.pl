use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $splitter = $ARGV[0];
# sci2tax.pl dosyası varmı yokmu bakar ve oluşturur.
$base_path = "sci2tax.pl";
if (-e $base_path) {
  print "$base_path exists!\n";
}else{
  print "File not exist, please wait while downloading...\n";
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
}


#--------------

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


my %fetched_organisim;
my $protein_counter;

foreach my $organism (@organisms) {
  $url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$organism\"$search_term\"&fil=&format=txt&force=yes";  
  print "********************\n";
  print "$organism is fetching from uniprot.\n";
  my $response = $ua->get($url);
  if ($response->is_success) {
    $content = $response->decoded_content;
    my @proteins = split(/\/\/\s/, $content);
    foreach my $protein (@proteins) {
      if (($captured) = $protein =~ /ID\s+(\w+)/){
        while($protein =~ /(IPR.*);\s(.*)\./g){
          $fetched_organisim{$organism}{$captured}{$1} = $2;
        } 
      }
    }
  }else{
    print "$organism could not be fetched";
    die $response->status_line;
  }
  if(scalar(%{$fetched_organisim{$organism}}) == 0){
    print "There is no protein for organisim $organism and given search term: ", "'$search_term'\n";
  }else{
    print_organisims(%{$fetched_organisim{$organism}});
  }
}


sub print_organisims{
  (my %organisim_proteins) = @_;
  my $protein_length = scalar(keys %organisim_proteins);
  print "$protein_length proteins found.\n";
  foreach my $protein (sort keys %organisim_proteins){
    print "$protein \n";
    foreach my $IPR (sort keys %{$organisim_proteins{$protein}}){
      print "$IPR  => " , $organisim_proteins{$protein}{$IPR} , "\n";
    }
  }
  print "********************\n";
}


sub print_all{
  foreach my $organism (sort keys %organisims) {
    print "organisim ", $organism, "\n";
    foreach my $protein (sort keys %{$organisims{$organism}}){
      print "$protein \n";
      foreach my $IPR (sort keys %{$organisims{$organism}{$protein}}){
        print "$IPR  => " , $organisims{$organism}{$protein}{$IPR} , "\n";
      }
    }
    print "********************\n";
  }
}
