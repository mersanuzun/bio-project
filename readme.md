#Detecting the common protein domains for the given organisms and search terms.

Database : Uniprot<br>
Web Service : Uniprot Rest Api<br>
Tools : Perl, Unix Commands<br>

##STEPS
- [x] We got taxonomy id using scientific name from UniProt. We wrote script with perl for this step. (we already made it)
- [x] We will get proteins using this taxononomy id and given search term. We will do this step using Uniprot Rest Api. We will write query to UniProt Rest Api and it will send us proteins and details.
- [x] We will get INTERPRO(protein domain) domain identifiers for these proteins.
- [x] We will show common INTERPRO domain identifiers between given organisms..
- [x] We will show how frequent these INTERPROs for all given organisms.
- [ ] Finally we will report that  show the users INTERPRO statistics  & Common INTERPROs.

##Usage
```
perl script.pl -o 9640 10090 "Mus musculus" -s "Glucose Metabolism"
```
##Presentation
[Prezi](http://prezi.com/2g3yosohp-_1/?utm_campaign=share&utm_medium=copy&rc=ex0share)


##Team Members 

  * [Meltem Demir] (https://github.com/demirmeltem)
  * [Cenk Töremiş] (https://github.com/cenktrms)
  * [Mehmet Ersan Uzun] (https://github.com/mersanuzun)
