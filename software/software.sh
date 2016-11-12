#!/bin/bash

umask 022

#export USER_NAME=$USER
#export HOME=/u/$USER
export INSTALL_MOD_ROOT=/u/$USER
export MODS=$INSTALL_MOD_ROOT/modules
export SOFT=$MODS/software
export SOUR=$MODS/sources
export MODF=$MODS/modulefiles
export LIN=$MODS/software/linux
export LFS=$MODS/software/linux/lfs
export LOGS=$MODS/installation_logs
export LFS_TGT=x86_64-pc-linux-gnu

mkdir -p $HOME/bin
cp newmod.sh $HOME/bin

#rm -rf $MODS #$HOME/.R_LIBS_USER $HOME/.Python
#rm -rf $HOME/.R_LIBS_USER $HOME/.Python
#rm -rf $HOME/.Python

mkdir -p $MODS $SOFT $SOUR $MODF $LIN $LFS $LOGS && \
    mkdir -p $MODF/bioinformatics $MODF/general $MODF/libs $MODF/linux && \
    mkdir -p $LFS/lib $LFS/bin $LFS/include && \
    ln -sv $LFS/lib $LFS/lib64

echo "export MODULEPATH=\$MODULEPATH:$MODF/libs:$MODF/general:$MODF/bioinformatics" > $INSTALL_MOD_ROOT/age-bioinformatics.rc
source $INSTALL_MOD_ROOT/age-bioinformatics.rc

export PATH=$HOME/bin:$PATH
#export LD_LIBRARY_PATH=$LFS/lib:$LD_LIBRARY_PATH
#export CPATH=$LFS/include:$CPATH
#export C_INCLUDE_PATH=$LFS/include:$C_INCLUDE_PATH

module load autotools
module load cmake/3.6
module load gcc/6.2

if [ ! -f $MODF/general/jup/0.1 ]; then
    echo 'jup-0.1'
    mkdir -p $SOFT/jup/0.1/bin
    cp jup $SOFT/jup/0.1/bin
    newmod.sh \
    -s jup \
    -p $MODF/general/ \
    -v 0.1 \
    -d 0.1
	echo "module load rlang" >> $MODF/general/jup/0.1
	echo "module load python" >> $MODF/general/jup/0.1
fi

if [ ! -f $MODF/general/java/8.0.111 ]; then 
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
	srun -o $LOGS/java-8.0.111.out $LOGS/java-8.0.111.sh
fi

if [ ! -f $MODF/libs/libz/1.2.8 ]; then
	echo 'zlib-1.2.8'
	echo '#!/bin/bash
	module list
	cd $SOUR
	wget -O l.tar.gz http://zlib.net/zlib-1.2.8.tar.gz
	mv l.tar.gz zlib-1.2.8.tar.gz
	tar -zxvf zlib-1.2.8.tar.gz 
	cd zlib-1.2.8
	mkdir $SOFT/libz/1.2.8
	./configure --prefix=$SOFT/libz/1.2.8
	make
	make install 
    newmod.sh \
    -s libz \
    -p $MODF/libs/ \
    -v 1.2.8 \
    -d 1.2.8
    ' > $LOGS/libz-1.2.8.sh
    chmod 755 $LOGS/libz-1.2.8.sh
    srun -o $LOGS/libz-1.2.8.out $LOGS/libz-1.2.8.sh
fi

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/zlib.html for shared option 
if [ ! -f $MODF/libs/libevent/2.0.22 ]; then
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
	srun -o $LOGS/libevent-2.0.22.out $LOGS/libevent-2.0.22.sh
fi
module load libevent/2.0.22

if [ ! -f $MODF/libs/ncurses/6.0 ]; then
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
	srun -o $LOGS/ncurses-6.0.out $LOGS/ncurses-6.0.sh
fi

module load ncurses/6.0

if [ ! -f $MODF/libs/bzip2/1.0.6 ]; then
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
    sed -i "18s/.*/CC\=gcc -fPIC/" Makefile  && \
    COMPILE_FLAGS+=-fPIC make Makefile-libbz2_so && COMPILE_FLAGS+=-fPIC make clean && COMPILE_FLAGS+=-fPIC make && \
    COMPILE_FLAGS+=-fPIC make -n install PREFIX=$SOFT/bzip2/1.0.6 && \
    COMPILE_FLAGS+=-fPIC make install PREFIX=$SOFT/bzip2/1.0.6' > $LOGS/bzip2-1.0.6.sh
	#echo "sed -i 's@\(ln -s -f \)\$(PREFIX)/bin/@\1@' Makefile" >> $LOGS/bzip2-1.0.6.sh
	#echo 'sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	#echo 'make -f Makefile-libbz2_so
 	#   make clean
 	#   make
 	#   make PREFIX=$SOFT/bzip2/1.0.6 install 
	echo 'cp -v bzip2-shared $SOFT/bzip2/1.0.6/bin/bzip2
    cp -av libbz2.so* $SOFT/bzip2/1.0.6/lib 
    newmod.sh \
    -s bzip2 \
    -p $MODF/libs/ \
    -v 1.0.6 \
    -d 1.0.6
    ' >> $LOGS/bzip2-1.0.6.sh
	chmod 755 $LOGS/bzip2-1.0.6.sh
	srun -o $LOGS/bzip2-1.0.6.out $LOGS/bzip2-1.0.6.sh #-o $LOGS/bzip2-1.0.6.out
fi
module load bzip2/1.0.6


if [ ! -f $MODF/libs/xz/5.2.2 ]; then
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
	srun -o $LOGS/xz-5.2.2.out $LOGS/xz-5.2.2.sh
fi
module load xz/5.2.2

if [ ! -f $MODF/libs/pcre/8.39 ]; then
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
	srun -o $LOGS/pcre-8.39.out $LOGS/pcre-8.39.sh # -o $LOGS/pcre-8.39.out
fi
module load pcre/8.39

if [ ! -f $MODF/libs/curl/7.51.0 ]; then
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
	srun -o $LOGS/curl-7.51.0.out $LOGS/curl-7.51.0.sh # -o $LOGS/pcre-8.39.out
fi
module load curl/7.51.0

if [ ! -f $MODF/libs/openblas/0.2.19 ]; then
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
	srun -o $LOGS/openblas-0.2.19.out $LOGS/openblas-0.2.19.sh # -o $LOGS/openblas-0.2.19.out
fi
#module load openblas/0.2.19

if [ ! -f $MODF/libs/freetype/2.7 ]; then
	echo 'freetype-2.7'
	echo '#!/bin/bash
	module list
	cd $SOUR
	wget -O d.tar.gz http://downloads.sourceforge.net/project/freetype/freetype2/2.7/freetype-2.7.tar.gz
	mv d.tar.gz freetype-2.7.tar.gz
	tar -zxvf freetype-2.7.tar.gz
	cd freetype-2.7
	mkdir -p $SOFT/freetype/2.7
	export LDFLAGS=-L$SOFT/bzip2/1.0.6/lib 
	export CFLAGS=-I$SOFT/bzip2/1.0.6/include
	./configure --prefix=$SOFT/freetype/2.7
	make
	make install
    newmod.sh \
    -s freetype \
    -p $MODF/libs/ \
    -v 2.7 \
    -d 2.7
    ' > $LOGS/freetype-2.7.sh
    chmod 755 $LOGS/freetype-2.7.sh
    srun -o $LOGS/freetype-2.7.out $LOGS/freetype-2.7.sh # -o $LOGS/freetype-2.7.out
fi
module load freetype/2.7

if [ ! -f $MODF/libs/openssl/1.1.0c ]; then
    echo 'openssl-1.1.0c'
    echo '#!/bin/bash
    module load libz/1.2.8
	module list
	rm -rf $SOUR/openssl-1.1.0c $SOFT/openssl/1.1.0c
    cd $SOUR
    wget -O d.tar.gz https://www.openssl.org/source/openssl-1.1.0c.tar.gz
    mv d.tar.gz openssl-1.1.0c.tar.gz
    tar -zxvf openssl-1.1.0c.tar.gz
    cd openssl-1.1.0c
    mkdir -p $SOFT/openssl/1.1.0c
    export LDFLAGS=-L$SOFT/libz/1.2.8/lib 
    export CFLAGS=-I$SOFT/libz/1.2.8/include
    ./config --prefix=$SOFT/openssl/1.1.0c --openssldir=$SOFT/openssl/1.1.0c/etc/ssl --libdir=lib shared zlib-dynamic 
	make depend 
    make
	make install
    newmod.sh \
    -s openssl \
    -p $MODF/libs/ \
    -v 1.1.0c \
    -d 1.1.0c
    ' > $LOGS/openssl-1.1.0c.sh
    chmod 755 $LOGS/openssl-1.1.0c.sh
    srun -o $LOGS/openssl-1.1.0c.out $LOGS/openssl-1.1.0c.sh # -o $LOGS/freetype-2.7.out
fi

if [ ! -f $MODF/general/rlang/3.3.2 ]; then
	echo 'rlang-3.3.2'
	echo '#!/bin/bash
	module list
	rm -rf $SOUR/R-3.3.2 $SOFT/rlang/3.3.2
	cd $SOUR && \
    wget -O d.tar.gz http://ftp5.gwdg.de/pub/misc/cran/src/base/R-3/R-3.3.2.tar.gz && \
    mv d.tar.gz R-3.3.2.tar.gz && \
    tar -xzf R-3.3.2.tar.gz && \
    cd R-3.3.2 && \
    mkdir -p $SOFT/rlang/3.3.2/bin && 
    ./configure --prefix=$SOFT/rlang/3.3.2 CFLAGS="-I$SOFT/openssl/1.1.0c/include/openssl -I$SOFT/libz/1.2.8/include -I$SOFT/freetype/2.7/include -I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/libevent/2.0.22/include -I$SOFT/bzip2/1.0.6/include -I$SOFT/xz/5.2.2/include -I$SOFT/pcre/8.39/include -I$SOFT/curl/7.51.0/include" LDFLAGS="-L$SOFT/openssl/1.1.0c/lib -L$SOFT/libz/1.2.8/lib -L$SOFT/freetype/2.7/lib -L$SOFT/ncurses/6.0/lib -L$SOFT/libevent/2.0.22/lib -L$SOFT/bzip2/1.0.6/lib -L$SOFT/xz/5.2.2/lib -L$SOFT/pcre/8.39/lib -L$SOFT/curl/7.51.0/lib" --with-readline --with-tcltk --enable-BLAS-shlib --enable-R-profiling --enable-R-shlib=yes --enable-memory-profiling --with-blas --with-lapack
    # other options -with-blas --with-lapack --with-cairo --with-jpeglib CFLAGS="-I$LFS/include" LDFLAGS="-L$LFS/lib"
    make && make install && \
    newmod.sh \
    -s rlang \
    -p $MODF/general/ \
    -v 3.3.2 \
    -d 3.3.2 &&
    echo "set home $::env(HOME)" >> $MODF/general/rlang/3.3.2
    echo "exec /bin/mkdir -p \$home/.R/3.3.2/R_LIBS_USER/" >> $MODF/general/rlang/3.3.2
    echo "setenv R_LIBS_USER \$home/.R/3.3.2/R_LIBS_USER" >> $MODF/general/rlang/3.3.2
    echo "prepend-path LD_LIBRARY_PATH $SOFT/rlang/3.3.2/lib64/R/lib" >> $MODF/general/rlang/3.3.2
    echo "prepend-path CPATH $SOFT/rlang/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path C_INCLUDE_PATH $SOFT/rlang/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path CPLUS_INCLUDE_PATH $SOFT/rlang/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "prepend-path OBJC_INCLUDE_PATH $SOFT/rlang/3.3.2/lib64/R/include" >> $MODF/general/rlang/3.3.2
    echo "module load gcc/6.2" >> $MODF/general/rlang/3.3.2
	mv $SOFT/rlang/3.3.2/lib64/R/lib/libRblas.so $SOFT/rlang/3.3.2/lib64/R/lib/old_libRblas.so
    ln -s $SOFT/openblas/0.2.19/lib/libopenblas.so $SOFT/rlang/3.3.2/lib64/R/lib/libRblas.so
	' > $LOGS/rlang-3.3.2.sh
	chmod 755 $LOGS/rlang-3.3.2.sh
	srun -o $LOGS/rlang-3.3.2.out $LOGS/rlang-3.3.2.sh #-o $LOGS/r-3.3.2.out
fi
module load rlang

if [ ! -f $MODF/general/python/2.7.12 ]; then
	echo 'python-2.7.12'
	echo '#!/bin/bash
	module load openblas/0.2.19
	module load libz/1.2.8
	module list
	rm -rf $SOUR/python-2.7.12 $SOFT/python/2.7.12
	cd $SOUR && \
    wget -O d.tgz https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz && \
    mv d.tgz python-2.7.12.tgz && \
    tar xzf python-2.7.12.tgz && \
    cd Python-2.7.12 && \
    mkdir -p $SOFT/python/2.7.12/bin && \
    #./configure --prefix=$SOFT/python/2.7.12 CFLAGS="-I$SOFT/openssl/1.1.0c/include  -I$SOFT/libz/1.2.8/include -I$SOFT/freetype/2.7/include -I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/openblas/0.2.19/include" LDFLAGS="-L$SOFT/openssl/1.1.0c/lib -L$SOFT/libz/1.2.8/lib -L$SOFT/freetype/2.7/lib -L$SOFT/openblas/0.2.19/lib" && \
    ./configure --prefix=$SOFT/python/2.7.12 CLFAGS="-I$SOFT/openblas/0.2.19/include -I$SOFT/ncurses/6.0/include/ncurses" LDFLAGS=-L$SOFT/openblas/0.2.19/lib
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
    echo "exec /bin/mkdir -p \$home/.Python/2.7.12/pythonpath/site-packages" >> $MODF/general/python/2.7.12
	#echo "prepend-path PYTHONPATH \$home/.Python/2.7.12/pythonpath/site-packages" >> $MODF/general/python/2.7.12
	echo "module load gcc/6.2 bzip2/1.0.6 xz/5.2.2 ncurses/6.0 libevent/2.0.22 pcre/8.39 curl/7.51.0 freetype/2.7 openblas/0.2.19" >> $MODF/general/python/2.7.12
	echo "setenv CFLAGS \"-I$SOFT/openblas/0.2.19/include -I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/libevent/2.0.22/include -I$SOFT/bzip2/1.0.6/include -I$SOFT/xz/5.2.2/include -I$SOFT/pcre/8.39/include -I$SOFT/curl/7.51.0/include -I$SOFT/openblas/0.2.19/include -I/u/jboucas/modules/software/rlang/3.3.2/lib64/R/include\"" >> $MODF/general/python/2.7.12
	echo "setenv LDFLAGS \"-L$SOFT/openblas/0.2.19/lib -L$SOFT/ncurses/6.0/lib -L$SOFT/libevent/2.0.22/lib -L$SOFT/bzip2/1.0.6/lib -L$SOFT/xz/5.2.2/lib -L$SOFT/pcre/8.39/lib -L$SOFT/curl/7.51.0/lib -L/mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64 -L/u/jboucas/modules/software/r/3.3.2/lib64/R/lib\"" >> $MODF/general/python/2.7.12
    # openblas/0.2.19 -L$SOFT/openblas/0.2.19/lib
	' > $LOGS/python-2.7.12.sh
	chmod 755 $LOGS/python-2.7.12.sh
	srun -o $LOGS/python-2.7.12.out $LOGS/python-2.7.12.sh #-o $LOGS/python-2.7.12.out
fi

if [ ! -f $MODF/general/pigz/2.3.4 ]; then
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
	srun -o $LOGS/pigz-2.3.4.out $LOGS/pigz-2.3.4.sh
fi

if [ ! -f $MODF/general/tmux/2.3 ]; then
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
	srun -o $LOGS/tmux-2.3.out $LOGS/tmux-2.3.sh
fi

if [ ! -f $MODF/bioinformatics/bowtie/2.2.9 ]; then
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
	srun -o $LOGS/bowtie-2.2.9.out $LOGS/bowtie-2.2.9.sh
fi

if [ ! -f $MODF/bioinformatics/cufflinks/2.2.1 ]; then
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
	srun -o $LOGS/cufflinks-2.2.1.out $LOGS/cufflinks-2.2.1.sh
fi

if [ ! -f $MODF/bioinformatics/fastqc/0.11.5 ]; then
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
	srun -o $LOGS/fastqc-0.11.5.out $LOGS/fastqc-0.11.5.sh
fi

if [ ! -f $MODF/bioinformatics/samtools/1.3.1 ]; then
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
fi

if [ ! -f $MODF/bioinformatics/hisat/2.0.4 ]; then
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
fi

if [ ! -f $MODF/bioinformatics/stringtie/1.3.0 ]; then
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
fi

if [ ! -f $MODF/bioinformatics/bwa/0.7.15 ]; then
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
fi

if [ ! -f $MODF/bioinformatics/tophat/2.1.1 ]; then
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
fi

if [ ! -f $MODF/bioinformatics/star/2.5.2b ]; then
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
fi

if [ ! -f $MODF/bioinformatics/skewer/0.2.2 ]; then
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
fi


module load python/2.7.12
module load rlang/3.3.2
python -m ensurepip
pip install pip --upgrade

cd $SOUR
wget -o d.tar.gz https://github.com/jeroenooms/openssl/archive/v0.9.5.tar.gz
mv d.tar.gz openssl_0.9.5.tar.gz
export PATH=$SOFT/openssl/1.1.0c/lib/:$PATH
export PKG_CONFIG_PATH=$SOFT/openssl/1.1.0c/lib/pkgconfig:$PKG_CONFIG_PATH
R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=/u/jboucas/modules/software/openssl/1.1.0c/lib' -l $SOFT/rlang/3.3.2/lib64/R/library openssl_0.9.5.tar.gz
git clone https://github.com/ropensci/git2r.git
R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=/u/jboucas/modules/software/openssl/1.1.0c/lib' -l $SOFT/rlang/3.3.2/lib64/R/library git2r

echo "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), c('$SOFT/rlang/3.3.2/lib64/R/library')  ,repos='http://ftp5.gwdg.de/pub/misc/cran/', dependencies=TRUE )" > ~/jupyter.install.R
echo "devtools::install_github('IRkernel/IRkernel',lib=c('$SOFT/rlang/3.3.2/lib64/R/library'))" >> ~/jupyter.install.R
echo "IRkernel::installspec(name = 'ir332', displayname = 'R 3.3.2',user = FALSE )" >> ~/jupyter.install.R
unset R_LIBS_USER
Rscript ~/jupyter.install.R

chmod -R 755 $MODS

exit

echo 'source("http://bioconductor.org/biocLite.R")' > ~/pack.install.R && \
echo 'biocLite(c("biomaRt"), ask=FALSE)'  >> ~/pack.install.R && \
module load rlang && srun Rscript ~/pack.install.R

# installing AGEpy
module load python/2.7.12
module load rlang/3.3.2
python -m ensurepip --user
pip install pip --user --upgrade  
cd $HOME && git clone https://github.com/mpg-age-bioinformatics/AGEpy
cd $HOME/AGEpy && python setup.py develop --user

cd $HOME
wget -o d.tar.gz https://github.com/jeroenooms/openssl/archive/v0.9.5.tar.gz
mv d.tar.gz openssl_0.9.5.tar.gz
export PATH=$SOFT/openssl/1.1.0c/lib/:$PATH
export PKG_CONFIG_PATH=$SOFT/openssl/1.1.0c/lib/pkgconfig:$PKG_CONFIG_PATH 
#LDFLAGS=-L/u/jboucas/modules/software/openssl/1.1.0c/lib CFLAGS=-I/u/jboucas/modules/software/openssl/1.1.0c/include ./configure 

R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=/u/jboucas/modules/software/openssl/1.1.0c/lib' openssl_0.9.5.tar.gz 

git clone https://github.com/ropensci/git2r.git
R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=/u/jboucas/modules/software/openssl/1.1.0c/lib' git2r

install.packages(c('git2r'),repos='http://ftp5.gwdg.de/pub/misc/cran/', dependencies=TRUE )
echo "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), repos='http://ftp5.gwdg.de/pub/misc/cran/', dependencies=TRUE )" > ~/jupyter.install.R
echo "devtools::install_github('IRkernel/IRkernel')" >> ~/jupyter.install.R
echo "IRkernel::installspec(name = 'ir332', displayname = 'R 3.3.2')" >> ~/jupyter.install.R 
Rscript ~/jupyter.install.R

exit
