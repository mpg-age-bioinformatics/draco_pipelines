# draco_pipelines

This repo contains pipelines running on the draco cluster.

More info on the draco cluster can be found on the web page of the [Max Planck Computing & Data Facility (MPCDF)](http://www.mpcdf.mpg.de/services/computing).

All users registered on [https://mpg-age-bioinformatics.github.io](https://mpg-age-bioinformatics.github.io) are by defenition also registered at the MPCDF.

If you wish to use software already installed by us add the following line to you `.bash_profile` with for eg. 

1. `vim .bash_profile`

2. Press *i* for inserting text.

3. Copy paste this line `export MODULEPATH=$MODULEPATH:/u/jboucas/modules/modulefiles/general:/u/jboucas/modules/modulefiles/bioinformatics::/u/jboucas/modules/modulefiles/libs

4. Copy this line as well `export TMPDIR=/ptmp/$USER`

5. Press "Esc" to escape *insert* modus

6. Type `:wq` to write and quit

Information on the different partions at the MPCDF can be found with `sinfo`

If you wish to know more about each available node, use: 

```bash
PARTITION    AVAIL  TIMELIMIT  NODES  STATE NODELIST
interactive*    up    2:00:00      2    mix draco[03-04]
small           up 1-00:00:00      5  alloc dra[0761-0762,0764-0766]
small           up 1-00:00:00      3   idle dra[0763,0767-0768]
express         up      30:00      1   drng dra0145
express         up      30:00    756  alloc dra[0001-0044,0046-0095,0097-0144,0146-0271,0273-0312,0314-0447,0449-0606,0608-0670,0672-0732,0734-0762,0764-0766]
express         up      30:00      9   idle dra[0045,0096,0272,0313,0448,0607,0671,0733,0763]
short           up    4:00:00      1   drng dra0145
short           up    4:00:00    756  alloc dra[0001-0044,0046-0095,0097-0144,0146-0271,0273-0312,0314-0447,0449-0606,0608-0670,0672-0732,0734-0762,0764-0766]
short           up    4:00:00      9   idle dra[0045,0096,0272,0313,0448,0607,0671,0733,0763]
general         up 1-00:00:00      1   drng dra0145
general         up 1-00:00:00    756  alloc dra[0001-0044,0046-0095,0097-0144,0146-0271,0273-0312,0314-0447,0449-0606,0608-0670,0672-0732,0734-0762,0764-0766]
general         up 1-00:00:00      9   idle dra[0045,0096,0272,0313,0448,0607,0671,0733,0763]
fat01           up 1-00:00:00      2  alloc dra[0771-0772]
fat01           up 1-00:00:00      3   idle dra[0769-0770,0773]
fat             up 1-00:00:00      2  alloc dra[0771-0772]
fat             up 1-00:00:00      2   idle dra[0769-0770]
gpu             up 1-00:00:00    102  alloc drag[001-102]
viz             up 1-00:00:00      4   idle drav[01-04]
```

For more information on each node use for example:

`sinfo -N -n dra[0045,0096,0272,0313,0448,0607,0671,0733,0763] -O cpus,cpusload,freemem,nodehost,partitionname`

```
CPUS                CPU_LOAD            FREE_MEM            HOSTNAMES           PARTITION
64                  0.03                123084              dra0045             express
64                  0.03                123084              dra0045             general
64                  0.03                123084              dra0045             short
64                  0.01                123073              dra0096             express
64                  0.01                123073              dra0096             general
64                  0.01                123073              dra0096             short
64                  0.02                123020              dra0272             express
64                  0.02                123020              dra0272             general
64                  0.02                123020              dra0272             short
64                  0.01                123033              dra0313             express
64                  0.01                123033              dra0313             general
64                  0.01                123033              dra0313             short
64                  0.01                123051              dra0448             express
64                  0.01                123051              dra0448             general
64                  0.01                123051              dra0448             short
64                  0.01                123021              dra0607             express
64                  0.01                123021              dra0607             general
64                  0.01                123021              dra0607             short
64                  0.01                123092              dra0671             express
64                  0.01                123092              dra0671             general
64                  0.01                123092              dra0671             short
64                  0.01                122965              dra0733             express
64                  0.01                122965              dra0733             general
64                  0.01                122965              dra0733             short
64                  0.01                122901              dra0763             small
64                  0.01                122901              dra0763             express
64                  0.01                122901              dra0763             general
64                  0.01                122901              dra0763             short
```

#### software

This folder contains the files required to install the software for the pipelines here presented.

`software.sh` a bash script for installation of all required software

`newmod.sh` required by *software.sh* this script generates the module files for each installed software.

`bash_profile` an example of a `.bash_profile` 

**jupyter**

You can install jupyter with:

```bash
module load python/2.7.12
pip install jupyter --user
```

Follow the instructions here for setting up a *jupyter notebook* as a server:

[http://jupyter-notebook.readthedocs.io/en/latest/public_server.html](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html) 

To access your notebook you will need to start your VPN - more info here:

[https://www.mpcdf.mpg.de/services/network/vpn](https://www.mpcdf.mpg.de/services/network/vpn)

Run 'ip addr show' to see your IP address.

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


