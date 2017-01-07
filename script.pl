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
  my $response = $ua->get($url);

  print "$organism is fetching from uniprot.\n";
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
}

foreach my $organism (keys %IPR_frequency){
  foreach $ipr (keys %{$IPR_frequency{$organism}}){
    if (isCommon($ipr) == 1){
      if (isPushed($ipr) == 0){
        push @common_IPRs, $ipr;
      }
    }
  }
}

sub print_all{
  my $file_name = "all.txt";
  open(my $out, '>', $file_name)
  or die "Could not open file ";
  foreach my $organism (keys %fetched_organisim) {
    print $out "Organisim\t", $organism, "\n";
    foreach my $protein (keys %{$fetched_organisim{$organism}}){
      print $out "\n";
      print $out "$protein \n";
      foreach my $IPR (keys %{$fetched_organisim{$organism}{$protein}}){
        print $out "$IPR\t" , $fetched_organisim{$organism}{$protein}{$IPR} , "\n";
      }
    }
    print $out "\n";
  }
  print "All organism informations were printed to $file_name.\n";
}

sub print_frequencies{
  ($isSort) = @_;
  my $file_name = "ipr_frequencies.txt";
  open(my $out, '>', $file_name)
    or die "Could not open file ";
  foreach $organism (keys %IPR_frequency){
    print $out "Organism\t", $organism, "\n" ;
    print $out "Frequency\tID\tName\n";
    if ($isSort eq "true"){
      @organisim_ipr = sort {$IPR_frequency{$organism}{$b}{count} <=> $IPR_frequency{$organism}{$a}{count}} keys %{$IPR_frequency{$organism}};
    }else{
      @organisim_ipr = keys %{$IPR_frequency{$organism}};
    }
    foreach $ipr (@organisim_ipr){   
      print $out $IPR_frequency{$organism}{$ipr}{"count"}, "\t", $ipr, "\t", $IPR_frequency{$organism}{$ipr}{"name"}, "\n" ;
    }
    print $out "\n";
  }
  print "IPR frequencies were printed to $file_name.\n";
}

sub print_common_iprs {
  my $file_name = "common_iprs.txt";
  open(my $out, '>', $file_name)
    or die "Could not open file ";
  print $out "Organisms\t";
  print $out "$_\t" foreach (keys %IPR_frequency), "\n";
  print $out "\n";
  foreach $ipr (@common_IPRs){
    print $out $ipr, "\n" ;
  }
  print "Common INTERPROs were printed to $file_name.\n";
}

sub isPushed {
  (my $ipr) = @_;
  foreach (@common_IPRs){
    #print $_->{"id"}, "\n";
    if ($ipr eq $_){
      return 1;
    }
  }
  return 0;
}

sub isCommon {
  (my $ipr) = @_;
  my $counter = 0;
  foreach $organism (keys %IPR_frequency){
    if(exists $IPR_frequency{$organism}{$ipr}){
      $counter++;
    }else{
      return 0;
    }
  }
  if ($counter == scalar keys %IPR_frequency){
    return 1;
  }else{
    return 0;
  }
}

print_all();
print_frequencies("true");
print_common_iprs();