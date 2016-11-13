# draco_pipelines

This repo contains pipelines running on the draco cluster.

More info on the draco cluster can be found on the web page of the [Max Planck Computing & Data Facility (MPCDF)](http://www.mpcdf.mpg.de/services/computing/draco).

All users registered on [https://mpg-age-bioinformatics.github.io](https://mpg-age-bioinformatics.github.io) are by defenition also registered at the MPCDF and can therefore also use the draco cluster.

If you wish to use the software installed by the core facility you can simply source the file:

```bash
source /u/jboucas/age-bioinformatics.rc
```

An example on how to integrate it in your `.bash_profile` can be found in this example of a [.bash_profile](software/bash_profile).

As shown in the [.bash_profile](software/bash_profile) and as requested by the MPCDF please do not forget to change your `TMPDIR` with `export TMPDIR=/ptmp/$USER`.

*Jupyter* is already installed. Users who whish to run *jupyter* and have source the `age-bioinformatics.rc` can do `module laod jup` and follow the instructions [here](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html)  on how to generate a config file for running a notebook server. Please do not choose crazy ports and avoid redundancy of the 9999. VPN connection will be required and information can be found [here](https://www.mpcdf.mpg.de/services/network/vpn). You can then start your jupyter notebook server with:

```bash
module load jup
srun jup
```
**IMPORTANT**: simply running srun will take to the partition *interactive*. Your job will not leave forever - do nott forget to save your work in a regular fashion. You can allways user the argument `-p <partition>` to specify the partiton you would to like to use eg. `srun -p general jup`. It is also here **IMPORTANT** to realize that this will submit a job that will resever one full node from the *general*  partition - to change this use the `--cpus-per-task` and `--mem` arguments to lower your reservation. You can allways check your reservation with `scontrol show job <jobid>`.

We do not have a *R-studio* server running at the MPCDF but users who wish to perform such kind of interactive work can install the R kernel for *Jupyter* and run *Jupyter* as shown above.

If you wish to install the R kernel for jupyter you can simply `source /u/jboucas/modules/sources/install.jupyter.R.kernel.3.3.2`.

You can use `sinfo` for getting information on all partitions.

If you want to look for free resources you can:

```bash
module load tools
freedraco
```
also,

```bash
freedraco --help
USAGE:
  freedraco [OPTIONS]
OPTIONS:
  -h, --help                : show this help and exist
  -p, --partiton            : partition to query. For multiple partitions use eg. '(general|viz)'.
  -c, --max_cpu_load        : maximum cpu load in % (default: 71.0)
  -m, --minimum_free_memory : minimum free memory in MBs (default: 100)
```

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

### Contact

bioinformatics@age.mpg.de

