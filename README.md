# draco_pipelines

This repo containg pipelines running on the draco cluster.

More info on the draco cluster can be on the web page of the [Max Planck Computing & Data Facility (MPCDF)](http://www.mpcdf.mpg.de/services/computing).

All users registered on [https://mpg-age-bioinformatics.github.io](https://mpg-age-bioinformatics.github.io) are by defenition also registered at the MPCDF.

#### software

This folder contains the files required to install the software for the pipelines here presented.

`software.sh` a bash script to install all required software

`newmod.sh` required by *software.sh* this scripts generates the module files for each installed software.

`bash_profile` an example of a `.bash_profile` 

#### tuxedo-slurm.sh

*Made for SLURM & Environment Modules Project*

This script runs a full RNAseq pipeline under a slurm jobs distribution system 
using about 18 processes per file allowing full analysis of 20 libraries with 
50 - 150 M reads per library to complete under 12h 

* fastQC - quality control 
* skewer - adapters and quality trimming 
* hisat - aligner 
* stringtie - transcripts assembly and quantification 
* cuffmerge - merging of assemblies 
* cuffquant - transcript expression profiles 
* cuffdiff - differential expression analysis 

Please read the instructions inside the script for usage.

#### ensref

*Made for SLURM & Environment Modules Project*

This is the script we use for downloading genome assemblies from ENSEMBL and 
build the respective indexes and folders structure. 
 
For usage check the help output: 
```
./ensref --help
```

#### others

Other useful tools like `aDiff` and `QC.R` can also be found on the [htseq-tools repository](https://github.com/mpg-age-bioinformatics/htseq-tools).


