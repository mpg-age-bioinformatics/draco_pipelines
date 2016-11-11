#!/bin/bash

export USER_NAME=jboucas
export HOME=/u/jboucas
export MODS=/u/jboucas/modules
export SOFT=$MODS/software
export SOUR=$MODS/sources
export MODF=$MODS/modulefiles
export LIN=$MODS/software/linux
export LFS=$MODS/software/linux/lfs
export LOGS=$MODS/installation_logs
export LFS_TGT=x86_64-pc-linux-gnu

mkdir -p $HOME/bin
cp newmod.sh $HOME/bin

#rm -rf $MODS $HOME/.R_LIBS_USER $HOME/.Python
#rm -rf $HOME/.R_LIBS_USER $HOME/.Python
#rm -rf $HOME/.Python

mkdir -p $MODS $SOFT $SOUR $MODF $LIN $LFS $LOGS && \
    cd $MODF && \
    mkdir -p bioinformatics general libs linux && \
    mkdir -p $LFS/lib $LFS/bin $LFS/include && \
    ln -sv $LFS/lib $LFS/lib64

export PATH=$HOME/bin:$LFS/bin:$PATH
export LD_LIBRARY_PATH=$LFS/lib:$LD_LIBRARY_PATH
#export CPATH=$LFS/include:$CPATH
#export C_INCLUDE_PATH=$LFS/include:$C_INCLUDE_PATH

module load autotools
module load cmake/3.6
module load gcc/6.2

echo 'java-8.0.111'
echo '#!/bin/bash
module list
cd $SOUR && wget -O l.tar.gz http://javadl.oracle.com/webapps/download/AutoDL?BundleId=216424 && \
    mv l.tar.gz jre-8.0.111-linux-x64.tar.gz && \
    tar -zxvf jre-8.0.111-linux-x64.tar.gz && \
    cd jre1.8.0_111 && \
    mkdir -p $SOFT/java/8.0.111 && \
    cp -r * $SOFT/java/8.0.111/ && \ 
    newmod.sh \
    -s java \
    -p $MODF/general/ \
    -v 8.0.111 \
    -d 8.0.111
' > $LOGS/java-8.0.111.sh
chmod 755 $LOGS/java-8.0.111.sh
#srun -o $LOGS/java-8.0.111.out $LOGS/java-8.0.111.sh

echo 'libevent-2.0.22'
echo '#!/bin/bash
module list
cd $SOUR && wget -O l.tar.gz https://github.com/libevent/libevent/archive/release-2.0.22-stable.tar.gz && \
    mv l.tar.gz release-2.0.22-stable.tar.gz && \
    tar -zxvf release-2.0.22-stable.tar.gz && \
    cd libevent-release-2.0.22-stable && ./autogen.sh && \
    mkdir -p $SOFT/libevent/2.0.22 && \
    ./configure --prefix=$SOFT/libevent/2.0.22 && make && make install && \
    newmod.sh \
    -s libevent \
    -p $MODF/libs/ \
    -v 2.0.22 \
    -d 2.0.22
' > $LOGS/libevent-2.0.22.sh
chmod 755 $LOGS/libevent-2.0.22.sh
#srun -o $LOGS/libevent-2.0.22.out $LOGS/libevent-2.0.22.sh

module load libevent/2.0.22

echo 'ncurses-6.0'
echo '#!/bin/bash
module list
rm -rf $SOUR/ncurses-6.0
cd $SOUR && \
    wget -O d.tgz http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.0.tar.gz && \
    mv d.tgz ncurses-6.0.tar.gz && \
    tar -zxvf ncurses-6.0.tar.gz && \
    cd ncurses-6.0 && \
    mkdir -p $SOFT/ncurses/6.0 && \
    ./configure --prefix=$SOFT/ncurses/6.0 --with-shared && make && make install
    newmod.sh \
    -s ncurses \
    -p $MODF/libs/ \
    -v 6.0 \
    -d 6.0
' > $LOGS/ncurses-6.0.sh
chmod 755 $LOGS/ncurses-6.0.sh
#srun -o $LOGS/ncurses-6.0.out $LOGS/ncurses-6.0.sh

module load ncurses/6.0

echo 'bzip2-1.0.6'
echo '#!/bin/bash
module list
rm -rf $SOUR/bzip2-1.0.6 $SOFT/bzip2/1.0.6
cd $SOUR && \
    wget -O d.tar.gz http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz && \
    mv d.tar.gz bzip2-1.0.6.tar.gz && \
    tar -xzf bzip2-1.0.6.tar.gz && \
    cd bzip2-1.0.6 && \
    mkdir -p $SOFT/bzip2/1.0.6 && \
    #sed -i "18s/.*/CC\=gcc -fPIC/" Makefile  && \
    #COMPILE_FLAGS+=-fPIC make Makefile-libbz2_so && COMPILE_FLAGS+=-fPIC make clean && COMPILE_FLAGS+=-fPIC make && \
    #COMPILE_FLAGS+=-fPIC make -n install PREFIX=$SOFT/bzip2/1.0.6 && \
    #COMPILE_FLAGS+=-fPIC make install PREFIX=$SOFT/bzip2/1.0.6' > $LOGS/bzip2-1.0.6.sh
echo "sed -i 's@\(ln -s -f \)\$(PREFIX)/bin/@\1@' Makefile" >> $LOGS/bzip2-1.0.6.sh
echo 'sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=$SOFT/bzip2/1.0.6 install 
    cp -v bzip2-shared $SOFT/bzip2/1.0.6/bin/bzip2
    cp -av libbz2.so* $SOFT/bzip2/1.0.6/lib 
    newmod.sh \
    -s bzip2 \
    -p $MODF/libs/ \
    -v 1.0.6 \
    -d 1.0.6
    ' >> $LOGS/bzip2-1.0.6.sh
chmod 755 $LOGS/bzip2-1.0.6.sh
#srun -o $LOGS/bzip2-1.0.6.out $LOGS/bzip2-1.0.6.sh #-o $LOGS/bzip2-1.0.6.out

module load bzip2/1.0.6

echo 'xz-5.2.2'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz http://tukaani.org/xz/xz-5.2.2.tar.gz && \
    mv d.tar.gz xz-5.2.2.tar.gz && \
    tar -xzf xz-5.2.2.tar.gz && \
    cd xz-5.2.2 && \
    mkdir -p $SOFT/xz/5.2.2 && \
    ./configure --prefix=$SOFT/xz/5.2.2 && make && make install
    newmod.sh \
    -s xz \
    -p $MODF/libs/ \
    -v 5.2.2 \
    -d 5.2.2
    ' > $LOGS/xz-5.2.2.sh
chmod 755 $LOGS/xz-5.2.2.sh
#srun -o $LOGS/xz-5.2.2.out $LOGS/xz-5.2.2.sh

module load xz/5.2.2

echo 'pcre-8.39'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre//pcre-8.39.tar.gz && \
    mv d.tar.gz pcre-8.39.tar.gz && \
    tar -xzf pcre-8.39.tar.gz && \
    cd pcre-8.39 && \
    mkdir -p $SOFT/pcre/8.39 && \
    ./configure --enable-utf8 --prefix=$SOFT/pcre/8.39 && make && make install
    newmod.sh \
    -s pcre \
    -p $MODF/libs/ \
    -v 8.39 \
    -d 8.39
    ' > $LOGS/pcre-8.39.sh
chmod 755 $LOGS/pcre-8.39.sh
#srun -o $LOGS/pcre-8.39.out $LOGS/pcre-8.39.sh # -o $LOGS/pcre-8.39.out

module load pcre/8.39

echo 'curl-7.51.0'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz https://curl.haxx.se/download/curl-7.51.0.tar.gz && \
    mv d.tar.gz curl-7.51.0.tar.gz && \
    tar -xzf curl-7.51.0.tar.gz && \
    cd curl-7.51.0 && \
    mkdir -p $SOFT/curl/7.51.0 && \
    ./configure --prefix=$SOFT/curl/7.51.0 && make && make install
    newmod.sh \
    -s curl \
    -p $MODF/libs/ \
    -v 7.51.0 \
    -d 7.51.0
    ' > $LOGS/curl-7.51.0.sh
chmod 755 $LOGS/curl-7.51.0.sh
#srun -o $LOGS/curl-7.51.0.out $LOGS/curl-7.51.0.sh # -o $LOGS/pcre-8.39.out

module load curl/7.51.0

echo 'openblas-0.2.19'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz https://github.com/xianyi/OpenBLAS/archive/v0.2.19.tar.gz && \
    mv d.tar.gz openblas-0.2.19.tar.gz && \
    tar -xzf openblas-0.2.19.tar.gz && \
    cd OpenBLAS-0.2.19 && \
    mkdir -p $SOFT/openblas/0.2.19 && \
    make PREFIX=$SOFT/openblas/0.2.19 && \
    make install PREFIX=$SOFT/openblas/0.2.19
    newmod.sh \
    -s openblas \
    -p $MODF/libs/ \
    -v 0.2.19 \
    -d 0.2.19
    ' > $LOGS/openblas-0.2.19.sh
chmod 755 $LOGS/openblas-0.2.19.sh
#srun -o $LOGS/openblas-0.2.19.out $LOGS/openblas-0.2.19.sh # -o $LOGS/openblas-0.2.19.out

module load openblas/0.2.19

echo 'rlang-3.3.2'
echo '#!/bin/bash
module list
rm -rf $SOUR/R-3.3.2 $SOFT/r/3.3.2
cd $SOUR && \
    wget -O d.tar.gz http://ftp5.gwdg.de/pub/misc/cran/src/base/R-3/R-3.3.2.tar.gz && \
    mv d.tar.gz R-3.3.2.tar.gz && \
    tar -xzf R-3.3.2.tar.gz && \
    cd R-3.3.2 && \
    mkdir -p $SOFT/rlang/3.3.2/bin && 
    ./configure --prefix=$SOFT/rlang/3.3.2 CFLAGS="-I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/libevent/2.0.22/include -I$SOFT/bzip2/1.0.6/include -I$SOFT/xz/5.2.2/include -I$SOFT/pcre/8.39/include -I$SOFT/curl/7.51.0/include -I$SOFT/openblas/0.2.19/include" LDFLAGS="-L$SOFT/ncurses/6.0/lib -L$SOFT/libevent/2.0.22/lib -L$SOFT/bzip2/1.0.6/lib -L$SOFT/xz/5.2.2/lib -L$SOFT/pcre/8.39/lib -L$SOFT/curl/7.51.0/lib -L$SOFT/openblas/0.2.19/lib" --with-readline --with-tcltk --enable-BLAS-shlib --enable-R-profiling --enable-R-shlib --enable-memory-profiling
    # other options -with-blas --with-lapack --with-cairo --with-jpeglib CFLAGS="-I$LFS/include" LDFLAGS="-L$LFS/lib"
    make && make install && \
    newmod.sh \
    -s rlang \
    -p $MODF/general/ \
    -v 3.3.2 \
    -d 3.3.2 &&
    echo "set home $::env(HOME)" >> $MODF/general/rlang/3.3.2
    echo "exec /bin/mkdir -p \$home/.R_LIBS_USER/3.3.2" >> $MODF/general/rlang/3.3.2
    echo "setenv R_LIBS_USER \$home/.R_LIBS_USER/3.3.2" >> $MODF/general/rlang/3.3.2
    echo "prepend-path LD_LIBRARY_PATH $SOFT/r/3.3.2/lib64/R/lib" >> $MODF/general/rlang/3.3.2
    echo "prepend-path CPATH $SOFT/r/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path C_INCLUDE_PATH $SOFT/r/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path CPLUS_INCLUDE_PATH $SOFT/r/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path OBJC_INCLUDE_PATH $SOFT/r/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    ' > $LOGS/rlang-3.3.2.sh
chmod 755 $LOGS/rlang-3.3.2.sh
#srun -o $LOGS/rlang-3.3.2.out $LOGS/rlang-3.3.2.sh #-o $LOGS/r-3.3.2.out

echo 'python-2.7.12'
echo '#!/bin/bash
module list
rm -rf $SOUR/python-2.7.12 $SOFT/python/2.7.12
cd $SOUR && \
    wget -O d.tgz https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz && \
    mv d.tgz python-2.7.12.tgz && \
    tar xzf python-2.7.12.tgz && \
    cd Python-2.7.12 && \
    mkdir -p $SOFT/python/2.7.12/bin && \
    ./configure --prefix=$SOFT/python/2.7.12 CFLAGS="-I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/openblas/0.2.19/include" LDFLAGS="-L$SOFT/openblas/0.2.19/lib" && \
    make && make install && \
    newmod.sh \
    -s python \
    -p $MODF/general/ \
    -v 2.7.12 \
    -d 2.7.12 &&
    echo "prepend-path LD_LIBRARY_PATH /mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64" >> $MODF/general/python/2.7.12
    echo "set home $::env(HOME)" >> $MODF/general/python/2.7.12
    echo "set pythonuser \$home/.Python/2.7.12/bin" >> $MODF/general/python/2.7.12
    echo "exec /bin/mkdir -p \$pythonuser" >> $MODF/general/python/2.7.12
    echo "prepend-path PATH \$home/.Python/2.7.12/bin" >> $MODF/general/python/2.7.12
    echo "set jupyter_runtime_dir \$home/.Python/2.7.12/jupyter/run" >> $MODF/general/python/2.7.12
    echo "exec /bin/mkdir -p \$jupyter_runtime_dir" >> $MODF/general/python/2.7.12
    echo "setenv JUPYER_RUNTIME_DIR \$home/.Python/2.7.12/jupyter/run" >> $MODF/general/python/2.7.12
    echo "set jupyter_data_dir \$home/.Python/2.7.12/jupyter/data" >> $MODF/general/python/2.7.12
    echo "exec /bin/mkdir -p \$jupyter_data_dir" >> $MODF/general/python/2.7.12
    echo "setenv JUPYTER_DATA_DIR \$home/.Python/2.7.12/jupyter/data" >> $MODF/general/python/2.7.12
    echo "setenv PYTHONHOME $SOFT/python/2.7.12/" >> $MODF/general/python/2.7.12
    echo "setenv PYTHONUSERBASE \$home/.Python/2.7.12/" >> $MODF/general/python/2.7.12
    ' > $LOGS/python-2.7.12.sh
chmod 755 $LOGS/python-2.7.12.sh
#srun -o $LOGS/python-2.7.12.out $LOGS/python-2.7.12.sh #-o $LOGS/python-2.7.12.out

echo 'pigz-2.3.4'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget http://zlib.net/pigz/pigz-2.3.4.tar.gz && \
    tar -zxvf pigz-2.3.4.tar.gz && \
    cd pigz-2.3.4 && make && \
    mkdir -p $SOFT/pigz/2.3.4/bin && \
    cp pigz $SOFT/pigz/2.3.4/bin
    cp unpigz $SOFT/pigz/2.3.4/bin
    newmod.sh \
    -s pigz \
    -p $MODF/general/ \
    -v 2.3.4 \
    -d 2.3.4
' > $LOGS/pigz-2.3.4.sh
chmod 755 $LOGS/pigz-2.3.4.sh
#srun -o $LOGS/pigz-2.3.4.out $LOGS/pigz-2.3.4.sh

echo 'tmux-2.3'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O t.tar.gz https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz && \
    mv t.tar.gz tmux-2.3.tar.gz && \
    tar -zxvf tmux-2.3.tar.gz && \
    cd tmux-2.3 && \
    mkdir -p $SOFT/tmux/2.3/ && \
    ./configure --prefix=$SOFT/tmux/2.3/ CFLAGS="-I$SOFT/libevent/2.0.22/include -I$SOFT/ncurses/6.0/include/ncurses" LDFLAGS="-L$SOFT/libevent/2.0.22/lib -L$SOFT/ncurses/6.0/lib" && \
    make && make install
    newmod.sh \
    -s tmux \
    -p $MODF/general/ \
    -v 2.3 \
    -d 2.3
    echo "module load ncurses/6.0" >> $MODF/general/tmux/2.3
    echo "module load libevent/2.0.22" >> $MODF/general/tmux/2.3
' > $LOGS/tmux-2.3.sh
chmod 755 $LOGS/tmux-2.3.sh
#srun -o $LOGS/tmux-2.3.out $LOGS/tmux-2.3.sh


echo 'bowtie2-2.2.9'
echo '#!/bin/bash
module list
cd $SOUR
    wget -O b.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip
    mv b.zip bowtie2-2.2.9-linux-x86_64.zip
    rm -rf bowtie2-2.2.9
    unzip bowtie2-2.2.9-linux-x86_64.zip
    mkdir -p $SOFT/bowtie/2.2.9/bin
    cp -r bowtie2-2.2.9/* $SOFT/bowtie/2.2.9/
    mv $SOFT/bowtie/2.2.9/bowti* $SOFT/bowtie/2.2.9/bin/
    newmod.sh \
    -s bowtie \
    -p $MODF/bioinformatics/ \
    -v 2.2.9 \
    -d 2.2.9
    #echo "module load libevent/2.0.22" >> $MODF/bioinformatics/bowtie/2.2.9
' > $LOGS/bowtie-2.2.9.sh
chmod 755 $LOGS/bowtie-2.2.9.sh
#srun -o $LOGS/bowtie-2.2.9.out $LOGS/bowtie-2.2.9.sh

echo 'cufflinks-2.2.1'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    mv d.tar.gz cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    tar -zxvf cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    cd cufflinks-2.2.1.Linux_x86_64 && \
    mkdir -p $SOFT/cufflinks/2.2.1/bin && \
    cp cuff* g* $SOFT/cufflinks/2.2.1/bin && \
    newmod.sh \
    -s cufflinks \
    -p $MODF/bioinformatics/ \
    -v 2.2.1 \
    -d 2.2.1
' > $LOGS/cufflinks-2.2.1.sh
chmod 755 $LOGS/cufflinks-2.2.1.sh
#srun -o $LOGS/cufflinks-2.2.1.out $LOGS/cufflinks-2.2.1.sh

echo 'fastqc-0.11.5'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.zip http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip && \
    mv d.zip fastqc_v0.11.5.zip && \
    unzip fastqc_v0.11.5.zip && \
    cd FastQC && \
    mkdir -p $SOFT/fastqc/0.11.5/bin && \
    cp -r * $SOFT/fastqc/0.11.5/bin && \
    chmod 755 $SOFT/fastqc/0.11.5/bin/fastqc && \ 
    newmod.sh \
    -s fastqc \
    -p $MODF/bioinformatics/ \
    -v 0.11.5 \
    -d 0.11.5
    echo "module load java" >> $MODF/bioinformatics/fastqc/0.11.5
' > $LOGS/fastqc-0.11.5.sh
chmod 755 $LOGS/fastqc-0.11.5.sh
#srun -o $LOGS/fastqc-0.11.5.out $LOGS/fastqc-0.11.5.sh

echo 'flexbar-2.5.0'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tgz https://github.com/seqan/flexbar/releases/download/v2.5.0/flexbar_v2.5_linux64.tgz && \
    mv d.tgz flexbar_v2.5_linux64.tgz && \
    tar zxvf flexbar_v2.5_linux64.tgz && \
    cd flexbar_v2.5_linux64/ && \
    mkdir -p $SOFT/flexbar/2.5.0/bin && \
    cp -r * $SOFT/flexbar/2.5.0/bin && \
    mkdir -p $SOFT/flexbar/2.5.0/lib && \
    cp -r libtbb.so.2 $SOFT/flexbar/2.5.0/lib && \
    newmod.sh \
    -s flexbar \
    -p $MODF/bioinformatics/ \
    -v 2.5.0 \
    -d 2.5.0
    echo "module load bzip2" >> $MODF/bioinformatics/flexbar/2.5.0
' > $LOGS/flexbar-2.5.0.sh
chmod 755 $LOGS/flexbar-2.5.0.sh
#srun -o $LOGS/flexbar-2.5.0.out $LOGS/flexbar-2.5.0.sh

echo 'samtools-1.3.1'
echo '#!/bin/bash
module list
rm -rf $SOUR/samtools-1.3.1
cd $SOUR && \
    wget -O d.tar.bz2 https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    mv d.tar.bz2 samtools-1.3.1.tar.bz2 && \
    tar -jxvf samtools-1.3.1.tar.bz2 && \
    cd samtools-1.3.1 && \
    mkdir -p $SOFT/samtools/1.3.1/bin && \
    ./configure --prefix=$SOFT/samtools/1.3.1 && make && make install && \
    newmod.sh \
    -s samtools \
    -p $MODF/bioinformatics/ \
    -v 1.3.1 \
    -d 1.3.1
' > $LOGS/samtools-1.3.1.sh
chmod 755 $LOGS/samtools-1.3.1.sh
srun -o $LOGS/samtools-1.3.1.out $LOGS/samtools-1.3.1.sh

echo 'hisat-2.0.4'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.zip ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-2.0.4-Linux_x86_64.zip && \
    mv d.zip hisat2-2.0.4-Linux_x86_64.zip && \
    unzip hisat2-2.0.4-Linux_x86_64.zip && \
    cd hisat2-2.0.4 && \
    mkdir -p $SOFT/hisat/2.0.4/bin && \
    cp -r * $SOFT/hisat/2.0.4/bin && \
    newmod.sh \
    -s hisat \
    -p $MODF/bioinformatics/ \
    -v 2.0.4 \
    -d 2.0.4
' > $LOGS/hisat-2.0.4.sh
chmod 755 $LOGS/hisat-2.0.4.sh
srun -o $LOGS/hisat-2.0.4.out $LOGS/hisat-2.0.4.sh

echo 'stringtie-1.3.0'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.0.Linux_x86_64.tar.gz && \
    mv d.tar.gz stringtie-1.3.0.Linux_x86_64.tar.gz && \
    tar -zxvf stringtie-1.3.0.Linux_x86_64.tar.gz && \
    cd stringtie-1.3.0.Linux_x86_64 && \
    mkdir -p $SOFT/stringtie/1.3.0/bin && \
    cp -r * $SOFT/stringtie/1.3.0/bin && \
    newmod.sh \
    -s stringtie \
    -p $MODF/bioinformatics/ \
    -v 1.3.0 \
    -d 1.3.0
' > $LOGS/stringtie-1.3.0.sh
chmod 755 $LOGS/stringtie-1.3.0.sh
srun -o $LOGS/stringtie-1.3.0.out $LOGS/stringtie-1.3.0.sh

echo 'bwa-0.7.15'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz https://github.com/lh3/bwa/archive/v0.7.15.tar.gz && \
    mv d.tar.gz v0.7.15.tar.gz && \
    tar -zxvf v0.7.15.tar.gz && \
    cd bwa-0.7.15 && \
    make && \
    mkdir -p $SOFT/bwa/0.7.15/bin && \
    cp -r * $SOFT/bwa/0.7.15/bin && \
    newmod.sh \
    -s bwa \
    -p $MODF/bioinformatics/ \
    -v 0.7.15 \
    -d 0.7.15
' > $LOGS/bwa-0.7.15.sh
chmod 755 $LOGS/bwa-0.7.15.sh
srun -o $LOGS/bwa-0.7.15.out $LOGS/bwa-0.7.15.sh

echo 'tophat-2.1.1'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.Linux_x86_64.tar.gz && \
    mv d.tar.gz tophat-2.1.1.Linux_x86_64.tar.gz && \
    tar -zxvf tophat-2.1.1.Linux_x86_64.tar.gz && \
    cd tophat-2.1.1.Linux_x86_64 && \
    mkdir -p $SOFT/tophat/2.1.1/bin && \
    cp -r * $SOFT/tophat/2.1.1/bin && \
    newmod.sh \
    -s tophat \
    -p $MODF/bioinformatics/ \
    -v 2.1.1 \
    -d 2.1.1
' > $LOGS/tophat-2.1.1.sh
chmod 755 $LOGS/tophat-2.1.1.sh
srun -o $LOGS/tophat-2.1.1.out $LOGS/tophat-2.1.1.sh

echo 'star-2.5.2b'
echo '#!/bin/bash
module list
cd $SOUR && \
    wget -O d.tar.gz https://github.com/alexdobin/STAR/archive/2.5.2b.tar.gz && \
    mv d.tar.gz 2.5.2b.tar.gz && \
    tar -xzf 2.5.2b.tar.gz && \
    cd STAR-2.5.2b && \
    mkdir -p $SOFT/star/2.5.2b/bin && \
    cp -r bin/Linux_x86_64_static/* $SOFT/star/2.5.2b/bin && \
    newmod.sh \
    -s star \
    -p $MODF/bioinformatics/ \
    -v 2.5.2b \
    -d 2.5.2b
' > $LOGS/star-2.5.2b.sh
chmod 755 $LOGS/star-2.5.2b.sh
srun -o $LOGS/star-2.5.2b.out $LOGS/star-2.5.2b.sh

echo 'skewer-0.2.2'
echo '#!/bin/bash
module list
cd $SOUR && \ 
    wget http://downloads.sourceforge.net/project/skewer/Binaries/skewer-0.2.2-linux-x86_64
    mkdir -p $SOFT/skewer/0.2.2/bin
    cp skewer-0.2.2-linux-x86_64 $SOFT/skewer/0.2.2/bin/skewer
    chmod 755 $SOFT/skewer/0.2.2/bin/skewer
    newmod.sh \
    -s skewer \
    -p $MODF/bioinformatics/ \
    -v 0.2.2 \
    -d 0.2.2
' > $LOGS/skewer-0.2.2.sh
chmod 755 $LOGS/skewer-0.2.2.sh
srun -o $LOGS/skewer-0.2.2.out $LOGS/skewer-0.2.2.sh

echo 'source("http://bioconductor.org/biocLite.R")' > ~/pack.install.R && \
echo 'biocLite(c("biomaRt"), ask=FALSE)'  >> ~/pack.install.R && \
module load rlang && srun Rscript ~/pack.install.R
#"gplots","Gviz",

module load python/2.7.12
#module load rlang
module load mkl/11.3
export LD_LIBRARY_PATH=/mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64:$LD_LIBRARY_PATH
python -m ensurepip --user
#cd $HOME && git clone https://github.com/mpg-age-bioinformatics/AGEpy
cd $HOME/AGEpy
    CFLAGS="-I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/libevent/2.0.22/include -I$SOFT/bzip2/1.0.6/include -I$SOFT/xz/5.2.2/include -I$SOFT/pcre/8.39/include -I$SOFT/curl/7.51.0/include -I$SOFT/openblas/0.2.19/include -I/u/jboucas/modules/software/rlang/3.3.2/lib64/R/include" LDFLAGS="-L$SOFT/ncurses/6.0/lib -L$SOFT/libevent/2.0.22/lib -L$SOFT/bzip2/1.0.6/lib -L$SOFT/xz/5.2.2/lib -L$SOFT/pcre/8.39/lib -L$SOFT/curl/7.51.0/lib -L$SOFT/openblas/0.2.19/lib -L/mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64 -L/u/jboucas/modules/software/r/3.3.2/lib64/R/lib" python setup.py develop --user

    #CFLAGS=-I/u/jboucas/modules/software/rlang/3.3.2/lib64/R/include \
    #LDFLAGS="-L/mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64 -L/u/jboucas/modules/software/r/3.3.2/lib64/R/lib" python setup.py develop --user

exit