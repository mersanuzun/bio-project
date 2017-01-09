use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my @organisms = ();
my $search_term = "";
my $out_format = "txt";
my $splitter = $ARGV[0];
# sci2tax.pl dosyası varmı yokmu bakar ve oluşturur.
$base_path = "sci2tax.pl";
if (! -e $base_path) {
  print "Speclist not exist, please wait while downloading...\n";
    $url = "http://www.uniprot.org/docs/speclist.txt";
    my $response = $ua->get($url);
    if ($response->is_success) {
        $content = $response->decoded_content;
        print "Speclist was successfully loaded.. \n";
    }else{
        print "Not successfull try again..\n";
        die $response->status_line;
    }
    my $write_file = "sci2tax.pl";
    open(my $out, ">", $write_file)
    or die "Could not open file $write_file";
    $all_tax = "%sci2tax = (\n";
    
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
require "sci2tax.pl";

#--------------

foreach my $arg (@ARGV) {
  if ($arg eq "-o"){
    $splitter = "-o";
    next;
  } elsif ($arg eq "-s"){
    $splitter = "-s";
    next;
  }elsif ($arg eq "-out"){
    $splitter = "-out";
    next;
  }
  if ($splitter eq "-o"){
    if ($arg =~ /^[^0-9]*$/){
      $arg = $sci2tax{$arg};
    }
    push(@organisms, $arg);
  }elsif ($splitter eq "-s"){
    $search_term = $arg;
  }elsif ($splitter eq "-out"){
    $out_format = $arg;
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





sub print_all_html{
  my $file_name = "all.html";
  open(my $out, '>', $file_name)
  or die "Could not open file ";
  print $out "<!DOCTYPE html>
  <html>
  <head>
    <style>
      .organism{
        margin: 5px;

      }
      .organism_title{
        background: #443918;
        color: #e1f7f7;
        margin: 10px;
        padding: 5px;
        text-align: center;
        border-radius: 10px;
      }
      .protein{
        margin: 10px;
        padding: 5px;
        background:  #c18762;
        border-radius: 10px;
        display: inline-table;
        width: 300px;
        min-width: 300px;
      }
      .protein_name{
        text-align: center;
        font-size: 17px;
      }
      a:link {
        text-decoration: none;
        color: #372ac1;
      }
      a:hover {
        text-decoration: underline
      }
      a:visited {
        color: #372ac1;
      }
      .ipr{
        margin: 5px;
      }
      .ipr_name{
        margin-left: 10px;
      }
    </style>
  <title>Bioinformatics</title>
  </head>
  <body>"; 
  foreach my $organism (sort keys %fetched_organisim) {
    print $out "<div class='organism'>";
    print $out "<h1 class=\"organism_title\">Organism:\t", $organism, "</h1>";
    foreach my $protein (sort keys %{$fetched_organisim{$organism}}){
      print $out "<div class=\"protein\"><b><div class=\"protein_name\"><a target=\"_blank\" href='http://www.uniprot.org/uniprot/$protein'>$protein</a></div></b>";
      foreach my $IPR (sort keys %{$fetched_organisim{$organism}{$protein}}){
        print $out "<div class=\"ipr\"><a target=\"_blank\" href='https://www.ebi.ac.uk/interpro/entry/$IPR'>$IPR</a><span class=\"ipr_name\">" , $fetched_organisim{$organism}{$protein}{$IPR} , "</span></div>";
      }
      print $out "</div>";
    }
    print $out "</div>\n";
  }

  print $out "
  </body>
  </html> ";
  print "All organism informations were printed to $file_name.\n";
}


sub print_frequencies_html{
  my $file_name = "ipr_frequencies.html";
  open(my $out, '>', $file_name)
    or die "Could not open file ";

  print $out "<!DOCTYPE html>
  <html>
  <head>
  <style>
    .organism{
      margin: 5px;
    }  
    .organism_title{
       background: #443918;
       color: #e1f7f7;
       margin: 10px;
       padding: 5px;
       text-align: center;
       border-radius: 10px;
    }
    .ipr{
      margin: 10px;
    }
    table{
      margin: 10px;
    }
    a:link {
      text-decoration: none;
      color: #372ac1;
    }
    a:hover {
      text-decoration: underline
    }
    a:visited {
      color: #372ac1;
    }
    td{
      padding: 5px;
    }
    th{
      padding: 10px;
    }
  </style>
  <title>Bioinformatics</title>
  </head>
  <body>"; 
  foreach $organism (keys %IPR_frequency){
    print $out "<h1 class=\"organism_title\">Organism:\t", $organism, "</h1>";
    print $out "<table border=\"1\">";
    print $out "<th>Frequency</th>";
    print $out "<th>IPR ID</th>";
    print $out "<th>IPR Name</th>";
    if ($isSort eq "true"){
      @organisim_ipr = sort {$IPR_frequency{$organism}{$b}{count} <=> $IPR_frequency{$organism}{$a}{count}} keys %{$IPR_frequency{$organism}};
    }else{
      @organisim_ipr = keys %{$IPR_frequency{$organism}};
    }
    foreach $ipr (@organisim_ipr){   
      print $out "<tr>";
      print $out "<td><span class=\"frequency\">", $IPR_frequency{$organism}{$ipr}{"count"}, "</span></td>";
      print $out "<td><span class=\"ipr_id\"><a target=\"_blank\" href='https://www.ebi.ac.uk/interpro/entry/$ipr'>$ipr</a></span></td>";
      print $out "<td><span class=\"ipr_name\">", $IPR_frequency{$organism}{$ipr}{"name"}, "</span></td>";
      print $out "</tr>";
    }
    print $out "</table>";
  }
  print $out "
  </body>
  </html> ";
  print "IPR frequencies were printed to $file_name.\n";
}




sub print_common_iprs_html {
  $file_name = "common_iprs.html";
  open(my $out, '>', $file_name)
    or die "Could not open file ";

  print $out "<!DOCTYPE html>
  <html>
  <head>
    <style>
      .organisms{
        font-size: x-large;
        margin: 5px;
      }
      .ipr_id{
        font-size: 18px;
        margin: 5px;
      }
      a:link {
        text-decoration: none;
        color: #372ac1;
      }
      a:hover {
        text-decoration: underline
      }
      a:visited {
        color: #372ac1;
      }
    </style>
  <title>Bioinformatics</title>
  </head>
  <body>"; 
  print $out "<div class=\"organisms\">Organisms " . join(", ", keys %fetched_organisim), "</div>";
  foreach $ipr (@common_IPRs){
    print $out  "<div class=\"ipr_id\">", "<a target=\"_blank\" href='https://www.ebi.ac.uk/interpro/entry/$ipr'>$ipr</a></div>";
  }
  print $out "
  </body>
  </html> ";
  print "Common INTERPROs were printed to $file_name.\n";
}

if ($out_format eq "txt"){
  print_all();
  print_frequencies("true");
  print_common_iprs();  
}elsif ($out_format eq "html"){
  print_all_html();
  print_frequencies_html("true");
  print_common_iprs_html();
}elsif ($out_format eq "all"){
  print_all();
  print_frequencies("true");
  print_common_iprs();
  print_all_html();
  print_frequencies_html("true");
  print_common_iprs_html();
}
