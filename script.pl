use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $splitter = $ARGV[0];
# sci2tax.pl dosyası varmı yokmu bakar ve oluşturur.
$base_path = "sci2tax.pl";
if (! -e $base_path) {
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
my %IPR_frequency = ();
my @common_IPRs = ();

foreach my $organism (@organisms) {
  $url = "http://www.uniprot.org/uniprot/?sort=score&desc=&compress=no&query=taxonomy:$organism\"$search_term\"&fil=&format=txt&force=yes";  
  print "$organism is fetching from uniprot.\n";
  my $response = $ua->get($url);
  if ($response->is_success) {
    $content = $response->decoded_content;
    my @proteins = split(/\/\/\s/, $content);
    foreach my $protein (@proteins) {
      if (($captured_protein) = $protein =~ /ID\s+(\w+)/){
        while($protein =~ /(IPR.*);\s(.*)\./g){
          $fetched_organisim{$organism}{$captured_protein}{$1} = $2;
          if (exists $IPR_frequency{$organism}{$1}){
            $IPR_frequency{$organism}{$1}{"count"}++;
          }else {
            $IPR_frequency{$organism}{$1}{"count"} = 1;
            $IPR_frequency{$organism}{$1}{"name"} = $2;
            $IPR_frequency{$organism}{$1}{"id"} = $1;
          }
        } 
      }
    }
  }else{
    print "$organism could not be fetched. \n";
    die $response->status_line;
  }
  if(scalar(%{$fetched_organisim{$organism}}) == 0){
    print "There is no protein for organisim $organism and given search term: ", "'$search_term'\n";
  }else{
    print "$organism was fetched.\n";
  }
  #else{
  #  print_organisims(%{$fetched_organisim{$organism}});
  #}  
}

sub print_organisims{
  (my %organisim_proteins) = @_;
  my $protein_length = scalar(keys %organisim_proteins);
  print "$protein_length proteins found.\n";
  foreach my $protein (keys %organisim_proteins){
    print "$protein \n";
    foreach my $IPR (keys %{$organisim_proteins{$protein}}){
      print "$IPR  => " , $organisim_proteins{$protein}{$IPR} , "\n";
    }
  }
  print "********************\n";
}


sub print_all{
  (my %organisms) = @_;
  foreach my $organism (keys %organisims) {
    print "organisim ", $organism, "\n";
    foreach my $protein (keys %{$organisims{$organism}}){
      print "$protein \n";
      foreach my $IPR (keys %{$organisims{$organism}{$protein}}){
        print "$IPR  => " , $organisims{$organism}{$protein}{$IPR} , "\n";
      }
    }
    print "********************\n";
  }
}

sub print_frequencies{
  foreach my $organism (keys %IPR_frequency){
    print "Organism: $organism", "\n";
    foreach $ipr (keys %{$IPR_frequency{$organism}}){
      print $ipr, ",", $IPR_frequency{$organism}{$ipr}{"name"}, ",", $IPR_frequency{$organism}{$ipr}{"count"}, "\n" ;
    }
  }
}

print_frequencies();