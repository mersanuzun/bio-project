#Detecting the common protein domains for the given organisms and search terms.

##Steps
- [x] We got taxonomy id using scientific name from UniProt. We wrote script with perl for this step. (we already made it)
- [x] We will get proteins using this taxononomy id and given search term. We will do this step using Uniprot Rest Api. We will write query to UniProt Rest Api and it will send us proteins and details.
- [x] We will get INTERPRO(protein domain) domain identifiers for these proteins.
- [x] We will show common INTERPRO domain identifiers between given organisms..
- [x] We will show how frequent these INTERPROs for all given organisms.
- [x] Finally we will report that  show the users INTERPRO statistics  & Common INTERPROs.

##Resources
* Database 
 - Uniprot
* Web Service 
 - Uniprot Rest Api
* Tools 
 - Perl 
 - Unix Commands
 
##Usage
```
perl script.pl -o 9640 10090 "Mus musculus" -s "Glucose Metabolism"
```
To run script;

 - We need to give taxonomy ids or scientific names or both after -o.
 - Also we can give search term after -s.
 - For output, give a format after -out (html, txt, all).


##Presentation & Report
[Prezi](http://prezi.com/2g3yosohp-_1/?utm_campaign=share&utm_medium=copy&rc=ex0share)

[Report](https://drive.google.com/file/d/0B7LFCn3Ee6mbaTFaMThnalJQVFE/view?usp=sharing)

##Team Members 

  * [Meltem Demir] (https://github.com/demirmeltem)
  * [Cenk Töremiş] (https://github.com/cenktrms)
  * [Mehmet Ersan Uzun] (https://github.com/mersanuzun)
