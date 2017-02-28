#!/bin/bash

umask 022

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
cp newmod.sh newmod.ruby.sh $HOME/bin

mkdir -p $MODS $SOFT $SOUR $MODF $LIN $LFS $LOGS && \
    mkdir -p $MODF/bioinformatics $MODF/general $MODF/libs $MODF/linux && \
    mkdir -p $LFS/lib $LFS/bin $LFS/include && \
    ln -sv $LFS/lib $LFS/lib64

echo "export MODULEPATH=\$MODULEPATH:$MODF/libs:$MODF/general:$MODF/bioinformatics" > $INSTALL_MOD_ROOT/age-bioinformatics.rc
chmod 755 $INSTALL_MOD_ROOT/age-bioinformatics.rc
source $INSTALL_MOD_ROOT/age-bioinformatics.rc
cp install.AGEpy $SOUR
cp install.jupyter.R.kernel.3.3.2 $SOUR
cp install.jupyter.ruby.kernel.2.4.0 $SOUR

export PATH=$HOME/bin:$PATH

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

echo "tools/0.1"
mkdir -p $SOFT/tools/0.1/bin
if [ ! -f $SOFT/tools/0.1/bin/freedraco ]; then
	cp freedraco $SOFT/tools/0.1/bin
fi
if [ ! -f $MODF/general/tools/0.1 ]; then
	newmod.sh \
	-s tools \
	-p $MODF/general/ \
	-v 0.1 \
	-d 0.1
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
    COMPILE_FLAGS+=-fPIC make -f Makefile-libbz2_so && COMPILE_FLAGS+=-fPIC make clean && COMPILE_FLAGS+=-fPIC make && \
    COMPILE_FLAGS+=-fPIC make -n install PREFIX=$SOFT/bzip2/1.0.6 && \
    COMPILE_FLAGS+=-fPIC make install PREFIX=$SOFT/bzip2/1.0.6
	cp -v bzip2-shared $SOFT/bzip2/1.0.6/bin/bzip2
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
	echo "prepend-path PATH $SOFT/openssl/1.1.0c/lib" >> $MODF/libs/openssl/1.1.0c
    echo "prepend-path PKG_CONFIG_PATH $SOFT/openssl/1.1.0c/lib/pkgconfig" >> $MODF/libs/openssl/1.1.0c
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
	echo "module load openssl/1.1.0c" >> $MODF/general/rlang/3.3.2
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
    ./configure --prefix=$SOFT/python/2.7.12 --enable-shared CLFAGS="-I$SOFT/openblas/0.2.19/include -I$SOFT/ncurses/6.0/include/ncurses" LDFLAGS="-L$SOFT/openblas/0.2.19/lib -L$SOFT/bzip2/1.0.6/lib" && \
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
    echo "setenv JUPYTER_RUNTIME_DIR \$home/.Python/2.7.12/jupyter/run" >> $MODF/general/python/2.7.12
    echo "set jupyter_data_dir \$home/.Python/2.7.12/jupyter/data" >> $MODF/general/python/2.7.12
    echo "exec /bin/mkdir -p \$jupyter_data_dir" >> $MODF/general/python/2.7.12
    echo "setenv JUPYTER_DATA_DIR \$home/.Python/2.7.12/jupyter/data" >> $MODF/general/python/2.7.12
    echo "setenv PYTHONHOME $SOFT/python/2.7.12/" >> $MODF/general/python/2.7.12
    echo "setenv PYTHONUSERBASE \$home/.Python/2.7.12/" >> $MODF/general/python/2.7.12
    echo "exec /bin/mkdir -p \$home/.Python/2.7.12/pythonpath/site-packages" >> $MODF/general/python/2.7.12
	echo "module load gcc/6.2 bzip2/1.0.6 xz/5.2.2 ncurses/6.0 libevent/2.0.22 pcre/8.39 curl/7.51.0 freetype/2.7 openblas/0.2.19" >> $MODF/general/python/2.7.12
	echo "setenv CFLAGS \"-I$SOFT/openblas/0.2.19/include -I$SOFT/ncurses/6.0/include/ncurses -I$SOFT/libevent/2.0.22/include -I$SOFT/bzip2/1.0.6/include -I$SOFT/xz/5.2.2/include -I$SOFT/pcre/8.39/include -I$SOFT/curl/7.51.0/include -I$SOFT/openblas/0.2.19/include -I$SOFT/rlang/3.3.2/lib64/R/include\"" >> $MODF/general/python/2.7.12
	echo "setenv LDFLAGS \"-L$SOFT/openblas/0.2.19/lib -L$SOFT/ncurses/6.0/lib -L$SOFT/libevent/2.0.22/lib -L$SOFT/bzip2/1.0.6/lib -L$SOFT/xz/5.2.2/lib -L$SOFT/pcre/8.39/lib -L$SOFT/curl/7.51.0/lib -L/mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64 -L$SOFT/bzip2/1.0.6/lib -L$SOFT/rlang/3.3.2/lib64/R/lib\"" >> $MODF/general/python/2.7.12
	' > $LOGS/python-2.7.12.sh
	chmod 755 $LOGS/python-2.7.12.sh
	srun -o $LOGS/python-2.7.12.out -c 1 --mem=4gb -p express $LOGS/python-2.7.12.sh #-o $LOGS/python-2.7.12.out
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
    echo "set home $::env(HOME)" >> $MODF/general/tmux/2.3
    echo "set hostname $::env(HOSTNAME)" >> $MODF/general/tmux/2.3
	echo "module load ncurses/6.0" >> $MODF/general/tmux/2.3
    echo "module load libevent/2.0.22" >> $MODF/general/tmux/2.3
    echo "exec /bin/mkdir -p \$home/.tmux.socket/\$hostname" >> $MODF/general/tmux/2.3
	echo "setenv TMUX_TMPDIR \$home/.tmux.socket/\$hostname" >> $MODF/general/tmux/2.3 
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

if [ ! -f $MODF/bioinformatics/bedtools/2.26.0 ]; then
    echo 'bedtools-2.26.0'
    echo '#!/bin/bash
    module list
    rm -rf $SOUR/bedtools-2.26.0
    cd $SOUR && \
    wget -O d.tar.gz https://github.com/arq5x/bedtools2/archive/v2.26.0.tar.gz && \
    mv d.tar.gz bedtools-2.26.0.tar.gz && \
    tar -zxvf bedtools-2.26.0.tar.gz && \
    cd bedtools2-2.26.0 && \
    mkdir -p $SOFT/bedtools/2.26.0/ && \
    make
	cp -r bin $SOFT/bedtools/2.26.0
    newmod.sh \
    -s bedtools \
    -p $MODF/bioinformatics/ \
    -v 2.26.0 \
    -d 2.26.0
    ' > $LOGS/bedtools-2.26.0.sh
    chmod 755 $LOGS/bedtools-2.26.0.sh
    srun -o $LOGS/bedtools-2.26.0.out $LOGS/bedtools-2.26.0.sh
fi

if [ ! -f $MODF/bioinformatics/vcftools/0.1.14 ]; then
	echo 'vcftools-0.1.14'
	echo '#!/bin/bash
	module list
	rm -rf $SOUR/vcftools-0.1.14
	cd $SOUR && \
	wget -O d.tar.gz https://github.com/vcftools/vcftools/releases/download/v0.1.14/vcftools-0.1.14.tar.gz && \
	mv d.tar.gz vcftools-0.1.14.tar.gz && \
	tar -zxvf vcftools-0.1.14.tar.gz && \
	cd vcftools-0.1.14 && \
	mkdir -p $SOFT/vcftools/0.1.14 && \
	./configure --prefix=$SOFT/vcftools/0.1.14 && make && make install && \
    newmod.sh \
    -s vcftools \
    -p $MODF/bioinformatics/ \
    -v 0.1.14 \
    -d 0.1.14
    ' > $LOGS/vcftools-0.1.14.sh
    chmod 755 $LOGS/vcftools-0.1.14.sh
    srun -o $LOGS/vcftools-0.1.14.out $LOGS/vcftools-0.1.14.sh
fi

if [ ! -f $MODF/bioinformatics/igvtools/2.3.89 ]; then
    echo 'igvtools-2.3.89'
    echo '#!/bin/bash
    module list
    rm -rf $SOUR/IGVTools
	rm -rf $SOFT/igvtools/2.3.89
    cd $SOUR && \
    wget -O d.tar.gz http://data.broadinstitute.org/igv/projects/downloads/igvtools_2.3.89.zip && \
	mv d.tar.gz igvtools_2.3.89.zip && \
	unzip igvtools_2.3.89.zip && \
	cd IGVTools && \ 
    mkdir -p $SOFT/igvtools/2.3.89/bin && \
    cp i* $SOFT/igvtools/2.3.89/bin
    newmod.sh \
    -s igvtools \
    -p $MODF/bioinformatics/ \
    -v 2.3.89 \
    -d 2.3.89
    ' > $LOGS/igvtools-2.3.89.sh
    chmod 755 $LOGS/igvtools-2.3.89.sh
    srun -o $LOGS/igvtools-2.3.89.out $LOGS/igvtools-2.3.89.sh
fi

if [ ! -f $MODF/bioinformatics/gatk/3.4.46 ]; then 
	echo 'gatk-3.4.46'
	echo '#!/bin/bash
	module list
	rm -rf $SOUR/GenomeAnalysisTK-3.4-46-gbc0262
	cd $SOUR && \
	wget -O d.tar.bz2 https://datashare.mpcdf.mpg.de/s/gml1aS2HUXfspXW/download && \
	mkdir -p GenomeAnalysisTK-3.4-46-gbc02625 && \
	mv d.tar.bz2 GenomeAnalysisTK-3.4-46-gbc02625.tar.bz2 && \
	cp GenomeAnalysisTK-3.4-46-gbc02625.tar.bz2 GenomeAnalysisTK-3.4-46-gbc02625/ && \
	cd GenomeAnalysisTK-3.4-46-gbc02625 && \
	tar -jxvf GenomeAnalysisTK-3.4-46-gbc02625.tar.bz2 && \
	mkdir -p $SOFT/gatk/3.4.46/bin && \
	cp *.jar $SOFT/gatk/3.4.46/bin && \ 
	cp -r resources $SOFT/gatk/3.4.46/ && \
	chmod 755 $SOFT/gatk/3.4.46/bin/*
	newmod.sh \
    -s gatk \
    -p $MODF/bioinformatics/ \
    -v 3.4.46 \
    -d 3.4.46
	echo "module load java" >> $MODF/bioinformatics/gatk/3.4.46
	echo "setenv GATK $SOFT/gatk/3.4.46/bin/GenomeAnalysisTK.jar" >> $MODF/bioinformatics/gatk/3.4.46
    ' > $LOGS/gatk-3.4.46.sh
    chmod 755 $LOGS/gatk-3.4.46.sh
    srun -o $LOGS/gatk-3.4.46.out $LOGS/gatk-3.4.46.sh
fi

if [ ! -f $MODF/bioinformatics/picard/2.8.1 ]; then
    echo 'picard-2.8.1'
    echo '#!/bin/bash
    module list
    rm -rf $SOUR/picard-2.8.1.jar
    cd $SOUR && \
    wget -O d.jar https://github.com/broadinstitute/picard/releases/download/2.8.1/picard.jar && \
    mv d.jar picard-2.8.1.jar && \
    mkdir -p $SOFT/picard/2.8.1/bin && \
    cp picard-2.8.1.jar $SOFT/picard/2.8.1/bin/picard.jar && \ 
    newmod.sh \
    -s picard \
    -p $MODF/bioinformatics/ \
    -v 2.8.1 \
    -d 2.8.1
    echo "module load java" >> $MODF/bioinformatics/picard/2.8.1
    echo "setenv PICARD $SOFT/picard/2.8.1/bin/picard.jar" >> $MODF/bioinformatics/picard/2.8.1
    ' > $LOGS/picard-2.8.1.sh
    chmod 755 $LOGS/picard-2.8.1.sh
    srun -o $LOGS/picard-2.8.1.out $LOGS/picard-2.8.1.sh
fi

if [ ! -f $MODF/bioinformatics/sratoolkit/2.8.1 ]; then
    echo 'sratoolkit-2.8.1'
    echo '#!/bin/bash
    module list
    rm -rf $SOUR/sratoolkit.2.8.1-centos_linux64.tar.gz
    cd $SOUR && \
    wget -O d.tar.gz http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.1/sratoolkit.2.8.1-centos_linux64.tar.gz && \
    mv d.tar.gz sratoolkit.2.8.1-centos_linux64.tar.gz && \
    tar -zxvf sratoolkit.2.8.1-centos_linux64.tar.gz && \
	mkdir -p $SOFT/sratoolkit/2.8.1/ && \
	cp -r sratoolkit.2.8.1-centos_linux64/*  $SOFT/sratoolkit/2.8.1/
    newmod.sh \
    -s sratoolkit \
    -p $MODF/bioinformatics/ \
    -v 2.8.1 \
    -d 2.8.1
    ' > $LOGS/sratoolkit-2.8.1.sh
    chmod 755 $LOGS/sratoolkit-2.8.1.sh
    srun -o $LOGS/sratoolkit-2.8.1.out $LOGS/sratoolkit-2.8.1.sh
fi

if [ ! -f $MODF/general/ruby-install/0.6.1 ]; then
	echo 'ruby-install-0.6.1'
	echo '#!/bin/bash
	module list
	rm -rf $SOUR/ruby-install-0.6.1.tar.gz
	cd $SOUR && \ 
	wget -O d.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.1.tar.gz && \
	mv d.tar.gz ruby-install-0.6.1.tar.gz && \
	tar -xzvf ruby-install-0.6.1.tar.gz && \
	cd ruby-install-0.6.1/ && \
	mkdir -p $SOFT/ruby-install/0.6.1 && \
	make install PREFIX=$SOFT/ruby-install/0.6.1 && \
	newmod.sh \
    -s ruby-install \
    -p $MODF/general/ \
    -v 0.6.1 \
    -d 0.6.1
    ' > $LOGS/ruby-install-0.6.1.sh
    chmod 755 $LOGS/ruby-install-0.6.1.sh
    srun -o $LOGS/ruby-install-0.6.1.out $LOGS/ruby-install-0.6.1.sh
fi

if [ ! -f $MODF/general/ruby/2.4.0 ]; then
	echo 'ruby-2.4.0'
	echo '#!/bin/bash
	module load ruby-install
	module list
	cd $SOUR && \
	ruby-install --install-dir $SOFT/ruby/2.4.0 && \
	newmod.sh \
    -s ruby \
    -p $MODF/general/ \
    -v 2.4.0 \
    -d 2.4.0
    echo "set home $::env(HOME)" >> $MODF/general/ruby/2.4.0
	echo "prepend-path PATH \$home/.gem/ruby/2.4.0/bin" >> $MODF/general/ruby/2.4.0
	echo "module load gcc/6.2" >> $MODF/general/ruby/2.4.0
	' > $LOGS/ruby-2.4.0.sh
    chmod 755 $LOGS/ruby-2.4.0.sh
	srun -o $LOGS/ruby-2.4.0.out $LOGS/ruby-2.4.0.sh
fi

if [ ! -f $MODF/libs/gmp/6.1.2 ]; then
    echo 'gmp-6.1.2'
    echo '#!/bin/bash
    module list
    cd $SOUR && wget -O l.tar.bz2 https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2 && \
    mv l.tar.bz2 gmp-6.1.2.tar.bz2 && \
    tar -jxvf gmp-6.1.2.tar.bz2 && \
    cd gmp-6.1.2 && \
    ./configure --prefix=$SOFT/gmp/6.1.2 && make && make check && make install && \
    newmod.sh \
    -s gmp \
    -p $MODF/libs/ \
    -v 6.1.2 \
    -d 6.1.2
    ' > $LOGS/gmp-6.1.2.sh
    chmod 755 $LOGS/gmp-6.1.2.sh
    srun -o $LOGS/gmp-6.1.2.out $LOGS/gmp-6.1.2.sh
    #$LOGS/gmp-6.1.2.sh
fi

#rm -rf $MODF/libs/headers $SOUR/linux-4.9.1.tar.xz $SOFT/headers
# not required
#if [ ! -f $MODF/libs/headers/4.9.1 ]; then
#    echo 'headers-4.9.1'
#    echo '#!/bin/bash
#    module list
#    cd $SOUR && wget -O l.tar.xz https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.9.1.tar.xz && \
#    mv l.tar.xz linux-4.9.1.tar.xz && \
#    tar xf linux-4.9.1.tar.xz && \
#    cd $SOUR/linux-4.9.1 && \
#	mkdir -p $SOFT/headers/4.9.1 && \
#	make mrproper && \
#	make INSTALL_HDR_PATH=$SOFT/headers/4.9.1/ headers_install && \
#	#find $SOFT/headers/4.9.1/include \( -name .install -o -name ..install.cmd \) -delete
#    newmod.sh \
#    -s headers \
#    -p $MODF/libs/ \
#    -v 4.9.1 \
#    -d 4.9.1
#    ' > $LOGS/headers-4.9.1.sh
#    chmod 755 $LOGS/headers-4.9.1.sh
#    #srun -o $LOGS/headers-4.9.1.out $LOGS/headers-4.9.1.sh
#    $LOGS/headers-4.9.1.sh
#fi

#rm -rf $MODF/libs/glibc $SOFT/glibc $SOUR/glibc* 
# conlfict when loaded
#if [ ! -f $MODF/libs/glibc/2.24.0 ]; then
#    echo 'glibc-2.24.0'
#    echo '#!/bin/bash
#    module list
#    cd $SOUR && wget -O l.tar.bz2 http://ftp.halifax.rwth-aachen.de/gnu/libc/glibc-2.24.tar.bz2 && \
#    mv l.tar.bz2 glibc-2.24.tar.bz2 && \
#    tar -jxvf glibc-2.24.tar.bz2 && \
#    cd $SOUR/glibc-2.24 && \
#	rm -rf build && mkdir build && cd build && \
#    ../configure --prefix=$SOFT/glibc/2.24.0 --with-headers=$SOFT/headers/4.9.1/include/ && make && make install
#    newmod.sh \
#    -s glibc \
#    -p $MODF/libs/ \
#    -v 2.24.0 \
#    -d 2.24.0
#    ' > $LOGS/glibc-2.24.0.sh
#    chmod 755 $LOGS/glibc-2.24.0.sh
#    #srun -o $LOGS/glibc-2.24.0.out $LOGS/glibc-2.24.0.sh
#    $LOGS/glibc-2.24.0.sh
#fi

# not functional
#rm -rf $SOUR/ghc-8.0.2 $SOUR/ghc-8.0.2-* $SOUR/ghc-7.0.3 $SOFT/ghc/7.0.3 $SOFT/ghc/8.0.2 $SOUR/l.rpm $SOUR/ghc-7.0.3-13.1.x86_64.rpm $MODF/general/ghc
#if [ ! -f $MODF/general/ghc/7.0.3 ]; then
#    echo 'ghc-7.0.3'
#    echo '#!/bin/bash
#	rm -rf $SOUR/ghc-8.0.2 $SOUR/ghc-8.0.2-* $SOUR/ghc-7.0.3 $SOFT/ghc/7.0.3 $SOFT/ghc/8.0.2 $SOUR/l.rpm $SOUR/ghc-7.0.3-13.1.x86_64.rpm
#	#module load headers
#	#module load glibc/2.24.0
#	#module load gmp/6.1.2
#	#export LD_LIBRARY_PATH=$SOFT/gmp/6.1.2/lib:/:$LD_LIBRARY_PATH
#    module list
#    #cd $SOUR && wget -O l.tar.xz http://downloads.haskell.org/~ghc/8.0.2/ghc-8.0.2-x86_64-deb8-linux.tar.xz && \
#    #mv l.tar.xz ghc-8.0.2-x86_64-deb8-linux.tar.xz && \
#    #tar xf ghc-8.0.2-x86_64-deb8-linux.tar.xz && \
#    #cd $SOUR/ghc-8.0.2 && \
#	#mkdir -p $SOFT/ghc/8.02
#	#cp -r * $SOFT/ghc/8.02/
#	#./configure --prefix=$SOFT/ghc/8.0.2 && make clean && make && make install && \
#    #wget -O l.tar.xz http://downloads.haskell.org/~ghc/8.0.2/ghc-8.0.2-src.tar.xz && \
#	#mv l.tar.xz ghc-8.0.2-src.tar.xz && \
#	#tar xvf ghc-8.0.2-src.tar.xz && \
#	#cd ghc-8.0.2 && \
#	#./configure --prefix=$SOFT/ghc/8.0.2 && make clean && make && make install
#	#wget -O l.rpm http://www.rpmseek.com/download/http://download.opensuse.org/repositories/home:/mvancura:/haskel/SLE_11_SP1/x86_64/ghc-7.0.3-13.1.x86_64.rpm?hl=com&nid=5316:589 && \
#	wget -O l.rpm http://ftp.gwdg.de/pub/opensuse/repositories/home:/mvancura:/haskel/SLE_11_SP1/x86_64/ghc-7.0.3-13.1.x86_64.rpm
#	mv l.rpm ghc-7.0.3-13.1.x86_64.rpm && \
#	rm -rf ghc-7.0.3 && mkdir -p ghc-7.0.3 && \
#	mv ghc-7.0.3-13.1.x86_64.rpm ghc-7.0.3/ && \
#	cd ghc-7.0.3/ && \
#	rpm2cpio ghc-7.0.3-13.1.x86_64.rpm | cpio -idmv && \
#	cd usr && \
#	mkdir -p $SOFT/ghc/7.0.3 && \
#	cp -r * $SOFT/ghc/7.0.3
#	newmod.sh \
#    -s ghc \
#    -p $MODF/general/ \
#    -v 7.0.3 \
#    -d 7.0.3
#    ' > $LOGS/ghc-7.0.3.sh
#    chmod 755 $LOGS/ghc-7.0.3.sh
#    #srun -o $LOGS/ghc-7.0.3.out $LOGS/ghc-7.0.3.sh
#	$LOGS/ghc-7.0.3.sh 
#fi


if [ ! -f $MODF/bioinformatics/qiime/1.9.1 ]; then
	echo 'qiime-1.9.1'
	export GSL_h=/mpcdf/soft/SLES114/HSW/gsl/2.1/gcc-5.4
	echo '#!/bin/bash
	rm -rf $SOUR/qiime-1.9.1 $SOUR/qiime-1.9.1.tar.gz $SOUR/AmpliconNoiseV1.29 $SOUR/AmpliconNoiseV1.29.tar.gz $SOUR/qiime-deploy $SOUR/qiime-deploy-conf $SOFT/qiime/1.9.1
	module list
	
	printf "\n\nPrepare environment\n\n"
	
	### Prepare environment ###
	module load python/2.7.12
	module load jdk
	module load rlang/3.3.2
	mkdir -p $SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library
	mkdir -p $SOFT/qiime/1.9.1/bin $SOFT/qiime/1.9.1/pythonpath/site-packages
	export pythonuser=$SOFT/qiime/1.9.1/bin
	export PATH=$PATH:$SOFT/qiime/1.9.1/bin
	export PYTHONUSERBASE=$SOFT/qiime/1.9.1
	export R_LIBS_USER=$SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library
	
	printf "\n\nInstall qiime base\n\n"
	### Install qiime base ###
	cd $SOUR && \
	wget -O d.tar.gz https://github.com/biocore/qiime/archive/1.9.1.tar.gz && \
	mv d.tar.gz qiime-1.9.1.tar.gz && \
	tar -zxvf qiime-1.9.1.tar.gz && \
	cd qiime-1.9.1 && \
	pip install numpy -I --user && \
	pip install h5py -I --user && \
	pip install ../qiime-1.9.1 -I --user
	
	printf "\n\nPrepare qiime full deployment\n\n"
	### Prepare qiime full deployment ###
	cd $SOUR/ && \
	git clone https://github.com/qiime/qiime-deploy.git && \
	git clone https://github.com/qiime/qiime-deploy-conf.git
	
    printf "\n\nInstall ant\n\n"
	### Install ant ###
	cd $SOFT/qiime/1.9.1 && wget https://www.apache.org/dist/ant/binaries/apache-ant-1.10.0-bin.tar.bz2 && \
    tar -jxvf apache-ant-1.10.0-bin.tar.bz2
    export PATH=$PATH:$SOFT/qiime/1.9.1/apache-ant-1.10.0/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT/qiime/1.9.1/apache-ant-1.10.0/lib
	
	printf "\n\nqiime full deployment\n\n"
	### qiime full deployment ###
	sed -i "s/append-environment-to-bashrc: yes/append-environment-to-bashrc: no/g" $SOUR/qiime-deploy-conf/qiime-1.9.1/qiime.conf
	cd $SOUR/qiime-deploy && python qiime-deploy.py $SOFT/qiime/1.9.1/ -f $SOUR/qiime-deploy-conf/qiime-1.9.1/qiime.conf --force-remove-failed-dirs
	
	printf "\n\nInstall usearch5.2.236 aka usearch\n\n"
	### Install usearch5.2.236 aka usearch ###
	wget https://github.com/edamame-course/2015-tutorials/raw/master/QIIME_files/usearch5.2.236_i86linux32	
	cp usearch5.2.236_i86linux32 $SOFT/qiime/1.9.1/bin/usearch
	chmod 755 $SOFT/qiime/1.9.1/bin/usearch
	
	### FlowgramAlignment - requires ghc, NOT WORKING and only required for 454 data ###
	#mkdir $SOFT/qiime/1.9.1/FlowgramAlignment
	#cd $SOUR/qiime-1.9.1/qiime/support_files/denoiser/FlowgramAlignment/ && \
	#module load ghc && make install PREFIX=$SOFT/qiime/1.9.1/FlowgramAlignment
	
	printf "\n\nInstall cd-hit\n\n"
	### Install cd-hit ###
	cd $SOFT/qiime/1.9.1 &&	wget -O h.tar.gz https://github.com/weizhongli/cdhit/releases/download/V4.6.6/cd-hit-v4.6.6-2016-0711.tar.gz && \
	mv h.tar.gz cd-hit-v4.6.6-2016-0711.tar.gz && tar -zxvf cd-hit-v4.6.6-2016-0711.tar.gz && \
	cd cd-hit-v4.6.6-2016-0711 && make
	
	printf "\n\nInstall swarm, see follow up at the end of this file == issues with gcc/6.2\n\n"
	### Install swarm, see follow up at the end of this file == issues with gcc/6.2 ###
	cd $SOFT/qiime/1.9.1/ &&  wget -O d.tar.gz https://github.com/torognes/swarm/archive/1.2.19.tar.gz && mv d.tar.gz swarm-1.2.19.tar.gz && \
	tar -zxvf swarm-1.2.19.tar.gz
	
	printf "\n\nInstall uclust\n\n"
	### Install uclust ###
	cd $SOFT/qiime/1.9.1/bin && wget -O d http://www.drive5.com/uclust/uclustq1.2.21_i86linux64 && mv d uclustq1.2.21_i86linux64 && ln -s uclustq1.2.21_i86linux64 uclust && \
	chmod 755 uclustq1.2.21_i86linux64 && chmod 755 uclust
	
	printf "\n\nrdp_classifier_2.2\n\n"
	### rdp_classifier_2.2 ###
	cd $SOFT/qiime/1.9.1/ && wget -O l.zip https://downloads.sourceforge.net/project/rdp-classifier/rdp-classifier/rdp_classifier_2.2.zip && \
	mv l.zip rdp_classifier_2.2.zip && unzip rdp_classifier_2.2.zip
	
	printf "\n\nmicrobiomeutil-r20110519\n\n"
	### microbiomeutil-r20110519 ###
	cd $SOFT/qiime/1.9.1 &&  wget -O l.tgz https://downloads.sourceforge.net/project/microbiomeutil/microbiomeutil-r20110519.tgz && \
	mv l.tgz microbiomeutil-r20110519.tgz && tar -zxvf microbiomeutil-r20110519.tgz
	#cd microbiomeutil-r20110519 && make
	
	#printf "\n\nea-utils\n\n"
	#### ea-utils ### 
	#cd $SOFT/qiime/1.9.1 ; wget -O d.tar.gz https://github.com/ExpressionAnalysis/ea-utils/tarball/master
	#mv d.tar.gz ExpressionAnalysis-ea-utils-27a4809.tar.gz ; tar -zxvf ExpressionAnalysis-ea-utils-27a4809.tar.gz
	#cd ExpressionAnalysis-ea-utils-27a4809/clipper 
	#sed -i "s/^all:/#all:/g" Makefile
	#sed -i "s/-lgsl -lgslcblas/-L\/mpcdf\/soft\/SLES114\/HSW\/gsl\/2.1\/gcc-5.4\/lib -lgsl -lgslcblas/g" Makefile
	#module load gsl
	#CFLAGS="-L/mpcdf/soft/SLES114/HSW/gsl/2.1/gcc-5.4/lib -I/mpcdf/soft/SLES114/HSW/gsl/2.1/gcc-5.4/include -I/draco/u/jboucas/modules/software/qiime/1.9.1/ExpressionAnalysis-ea-utils-27a4809/clipper" make	
	
	printf "\n\nSeqPrep-1.2\n\n"
	### SeqPrep-1.2 ###
	cd $SOFT/qiime/1.9.1 && wget -O d.tar.gz https://github.com/jstjohn/SeqPrep/archive/v1.2.tar.gz && \
	mv d.tar.gz SeqPrep-1.2.tar.gz  && tar -zxvf SeqPrep-1.2.tar.gz && cd SeqPrep-1.2 && make
	
	printf "\n\nMothur.1.25.0\n\n"
	### Mothur.1.25.0 ###
	cd $SOFT/qiime/1.9.1 && wget -O m.zip http://www.mothur.org/w/images/6/6d/Mothur.1.25.0.zip && \
	mv m.zip Mothur.1.25.0.zip && unzip Mothur.1.25.0.zip && \
	cd $SOFT/qiime/1.9.1/Mothur.source && \
	sed -i "s/TARGET_ARCH += -arch x86_64/#TARGET_ARCH += -arch x86_64/g" makefile && \
	sed -i "s/#CXXFLAGS += -mtune=native -march=native -m64/CXXFLAGS += -mtune=native -march=native -m64/g" makefile && \
	module load boost && make

	printf "\n\nvsearch-2.3.4 alternative to usearch61\n\n"
	### vsearch-2.3.4 alternative to usearch61 ### 
	cd $SOFT/qiime/1.9.1 && wget -O d.tar.gz https://github.com/torognes/vsearch/releases/download/v2.3.4/vsearch-2.3.4-linux-x86_64.tar.gz && \
	mv d.tar.gz vsearch-2.3.4-linux-x86_64.tar.gz && tar -zxvf vsearch-2.3.4-linux-x86_64.tar.gz && \
	cd vsearch-2.3.4-linux-x86_64/bin && cp vsearch usearch61
	
	printf "\n\nCreate module file\n\n"
	### Create module file ###
	newmod.sh \
    -s qiime \
    -p $MODF/bioinformatics/ \
    -v 1.9.1 \
    -d 1.9.1 &&	\
	echo "prepend-path PATH $SOFT/qiime/1.9.1/vsearch-2.3.4-linux-x86_64/bin:$SOFT/qiime/1.9.1/SeqPrep-1.2:$SOFT/qiime/1.9.1/swarm-1.2.19:$SOFT/qiime/1.9.1/ExpressionAnalysis-ea-utils-27a4809/clipper:$SOFT/qiime/1.9.1/microbiomeutil-r20110519/ChimeraSlayer:$SOFT/qiime/1.9.1/Mothur.source:/draco/u/jboucas/modules/software/qiime/1.9.1/swarm-1.2.19/scripts" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv RDP_JAR_PATH $SOFT/qiime/1.9.1/rdp_classifier_2.2/rdp_classifier-2.2.jar" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PATH $SOFT/qiime/1.9.1/cd-hit-v4.6.6-2016-0711" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PATH $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Scripts"  >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PATH $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/bin" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv PYRO_LOOKUP_FILE $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Data/LookUp_E123.dat" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv SEQ_LOOKUP_FILE $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Data/Tran.dat" >> $MODF/bioinformatics/qiime/1.9.1
	echo "module load jdk" >> $MODF/bioinformatics/qiime/1.9.1
	echo "module load gsl" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path LD_LIBRARY_PATH $GSL_h/lib" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path LD_LIBRARY_PATH $SOFT/qiime/1.9.1/apache-ant-1.10.0/lib" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PATH $SOFT/qiime/1.9.1/apache-ant-1.10.0/bin" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path CPATH $GSL_h/include" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path C_INCLUDE_PATH $GSL_h/include" >> $MODF/bioinformatics/qiime/1.9.1
	#echo "exec $SOFT/qiime/1.9.1/activate.sh" >> $MODF/bioinformatics/qiime/1.9.1
	echo "module load python/2.7.12" >> $MODF/bioinformatics/qiime/1.9.1
	echo "module load rlang/3.3.2" >> $MODF/bioinformatics/qiime/1.9.1
	echo "module load bwa" >> $MODF/bioinformatics/qiime/1.9.1
    echo "setenv pythonuser $SOFT/qiime/1.9.1/bin" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv PYTHONUSERBASE $SOFT/qiime/1.9.1" >> $MODF/bioinformatics/qiime/1.9.1
    echo "setenv R_LIBS_USER $SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library" >> $MODF/bioinformatics/qiime/1.9.1
	#echo "prepend-path LD_LIBRARY_PATH /mpcdf/soft/SLES114/common/intel/ps2016.3/16.0/linux/mkl/lib/intel64" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PYTHONPATH $SOFT/qiime/1.9.1/lib/python2.7/site-packages/:$SOFT/qiime/1.9.1:$SOFT/qiime/1.9.1/pprospector-1.0.1-release/lib/python2.7/site-packages:$SOFT/qiime/1.9.1/qiime-galaxy-0.0.1-repository-de3646d3/lib/:$SOFT/qiime/1.9.1/tax2tree-1.0-release/lib/python2.7/site-packages" >> $MODF/bioinformatics/qiime/1.9.1
	echo "prepend-path PATH $SOFT/qiime/1.9.1/chimeraslayer-4.29.2010-release/ChimeraSlayer:$SOFT/qiime/1.9.1/chimeraslayer-4.29.2010-release/NAST-iEr:$SOFT/qiime/1.9.1/rdpclassifier-2.2-release/.:$SOFT/qiime/1.9.1/blast-2.2.22-release/bin:$SOFT/qiime/1.9.1/muscle-3.8.31-release/.:$SOFT/qiime/1.9.1/infernal-1.0.2-release/bin:$SOFT/qiime/1.9.1/cytoscape-2.7.0-release/.:$SOFT/qiime/1.9.1/pprospector-1.0.1-release/bin:$SOFT/qiime/1.9.1/qiime-galaxy-0.0.1-repository-de3646d3/scripts:$SOFT/qiime/1.9.1/raxml-7.3.0-release/.:$SOFT/qiime/1.9.1/drisee-1.2-release/.:$SOFT/qiime/1.9.1/cdbtools-10.11.2010-release/.:$SOFT/qiime/1.9.1/sourcetracker-1.0.0-release/.:$SOFT/qiime/1.9.1/rtax-0.984-release/.:$SOFT/qiime/1.9.1/clearcut-1.0.9-release/.:$SOFT/qiime/1.9.1/blat-34-release/.:$SOFT/qiime/1.9.1/tax2tree-1.0-release/bin" >> $MODF/bioinformatics/qiime/1.9.1 
	echo "setenv BLASTMAT $SOFT/qiime/1.9.1/blast-2.2.22-release/data" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv RDP_JAR_PATH $SOFT/qiime/1.9.1/rdpclassifier-2.2-release/rdp_classifier-2.2.jar" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv QIIME_CONFIG_FP $SOFT/qiime/1.9.1/qiime_config" >> $MODF/bioinformatics/qiime/1.9.1
	echo "setenv SOURCETRACKER_PATH $SOFT/qiime/1.9.1/sourcetracker-1.0.0-release/." >> $MODF/bioinformatics/qiime/1.9.1	
	echo "prepend-path PATH $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/bin:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Data:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/FastaUnique:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/FCluster:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/NDist:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Perseus:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/PerseusD:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/PyroDist:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/PyroNoise:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/PyroNoiseA:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/PyroNoiseM:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Scripts:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/SeqDist:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/SeqNoise:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/SplitClusterClust:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/SplitClusterEven:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/Test:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/TestFLX:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/TestTitanium:$SOFT/qiime/1.9.1/AmpliconNoiseV1.29/TestTitaniumFast" >> $MODF/bioinformatics/qiime/1.9.1 
	
	printf "\n\nmake swarm\n\n"
	module purge
	module load intel/16.0 mkl/11.3 impi/5.1.3 git/2.8 ncurses/6.0 libevent/2.0.22 tmux/2.3
	cd $SOFT/qiime/1.9.1/swarm-1.2.19 
	make

	printf "\n\nAmpliconNoiseV1.29\n\n"
	### AmpliconNoiseV1.29 ###
    cd $SOUR && wget -O d.tar.gz https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ampliconnoise/AmpliconNoiseV1.29.tar.gz  
    mv $SOUR/d.tar.gz $SOUR/AmpliconNoiseV1.29.tar.gz && cd $SOUR && tar -zxvf AmpliconNoiseV1.29.tar.gz 
    mv $SOUR/AmpliconNoiseV1.29 $SOFT/qiime/1.9.1/
    cd $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/ && \
    cd Perseus && sed -i "s/LIBS   = -lm -lgsl -lgslcblas/LIBS   = -L\/mpcdf\/soft\/SLES114\/HSW\/gsl\/2.1\/gcc-5.4\/lib -lm -lgsl -lgslcblas/g" makefile && \
    cd ../PerseusD && sed -i "s/LIBS   = -lm -lgsl -lgslcblas/LIBS   = -L\/mpcdf\/soft\/SLES114\/HSW\/gsl\/2.1\/gcc-5.4\/lib -lm -lgsl -lgslcblas/g" makefile && \
    cd $SOFT/qiime/1.9.1/AmpliconNoiseV1.29/
    module load gsl
    export LD_LIBRARY_PATH=$GSL_HOME/lib:$LD_LIBRARY_PATH
    export CPATH=$GSL_HOME/include:$CPATH
    export C_INCLUDE_PATH=$GSL_HOME/include/:$C_INCLUDE_PATH
	make

    printf "\n\nea-utils\n\n"
    ### ea-utils ### 
    cd $SOFT/qiime/1.9.1 ; wget -O d.tar.gz https://github.com/ExpressionAnalysis/ea-utils/tarball/master
    mv d.tar.gz ExpressionAnalysis-ea-utils-27a4809.tar.gz ; tar -zxvf ExpressionAnalysis-ea-utils-27a4809.tar.gz
    cd ExpressionAnalysis-ea-utils-27a4809/clipper 
    sed -i "s/^all:/#all:/g" Makefile
    sed -i "s/-lgsl -lgslcblas/-L\/mpcdf\/soft\/SLES114\/HSW\/gsl\/2.1\/gcc-5.4\/lib -lgsl -lgslcblas/g" Makefile
    module load gsl
	module load qiime
    CFLAGS="-L/mpcdf/soft/SLES114/HSW/gsl/2.1/gcc-5.4/lib -I/mpcdf/soft/SLES114/HSW/gsl/2.1/gcc-5.4/include -I/draco/u/jboucas/modules/software/qiime/1.9.1/ExpressionAnalysis-ea-utils-27a4809/clipper" make   
	chmod 755 $SOFT/qiime/1.9.1/bin/*.py
	' > $LOGS/qiime-1.9.1.sh
    chmod 755 $LOGS/qiime-1.9.1.sh
    srun -o $LOGS/qiime-1.9.1.out $LOGS/qiime-1.9.1.sh
	#$LOGS/qiime-1.9.1.sh > $LOGS/qiime-1.9.1.out

	module load qiime

	mkdir -p $SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library
	echo "install.packages(c('ape', 'biom', 'optparse', 'RColorBrewer', 'randomForest', 'vegan'), c('$SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library')  ,repos='http://ftp5.gwdg.de/pub/misc/cran/', dependencies=TRUE )" > $SOFT/qiime/1.9.1/install.R.packages
	echo "source('http://bioconductor.org/biocLite.R')" >> $SOFT/qiime/1.9.1/install.R.packages
	echo "biocLite(c('DESeq2', 'metagenomeSeq','biomformat'),lib='$SOFT/qiime/1.9.1/rlang/3.3.2/lib64/R/library' )" >> $SOFT/qiime/1.9.1/install.R.packages
	chmod 755 $SOFT/qiime/1.9.1/install.R.packages
	srun -o $LOGS/qiime-1.9.1.Rpackages.out Rscript $SOFT/qiime/1.9.1/install.R.packages
	
	cd $SOFT/qiime/1.9.1/lib/python2.7/site-packages/qiime
	for i in $(ls *.py); do sed -i "s/\/u\/jboucas\/modules\/software\/python\/2.7.12\/bin\/python/\/usr\/bin\/env python/g" ${i} ;  cat ${i} | egrep '#!/usr/|__future__' > _${i} ; echo "import matplotlib" >> _${i} ; echo "matplotlib.use('agg')" >> _${i} ; cat ${i} | egrep -v '#!/usr/|__future__' >> _${i} ; mv _${i} ${i}; chmod 755 ${i} ; done

	cd $SOUR/qiime-1.9.1/tests
    for i in $(ls *.py); do sed -i "s/\/u\/jboucas\/modules\/software\/python\/2.7.12\/bin\/python/\/usr\/bin\/env python/g" ${i} ; cat ${i} | egrep '#!/usr/|__future__' > _${i} ; echo "import matplotlib" >> _${i} ; echo "matplotlib.use('agg')" >> _${i} ; cat ${i} | egrep -v '#!/usr/|__future__' >> _${i} ;
mv _${i} ${i}; chmod 755 ${i}; done

	cd $SOFT/qiime/1.9.1/bin
	for i in $(ls *.py); do sed -i "s/\/u\/jboucas\/modules\/software\/python\/2.7.12\/bin\/python/\/usr\/bin\/env python/g" ${i} ; cat ${i} | egrep '#!/usr/|__future__' > _${i} ; echo "import matplotlib" >> _${i} ; echo "matplotlib.use('agg')" >> _${i} ; cat ${i} | egrep -v '#!/usr/|__future__' >> _${i} ;
mv _${i} ${i}; chmod 755 ${i} ; done

    cd $SOFT/qiime/1.9.1/rtax-0.984-release
    sed -i 's/tempdir=\/tmp/tempdir=\${TMPDIR}/g' rtax

	srun -o $LOGS/qiime-1.9.1.full.tests.out python $SOUR/qiime-1.9.1/tests/all_tests.py
fi


if [ ! -f $MODF/bioinformatics/snpeff/4.3.i ]; then
    echo 'snpeff-4.3.i'
    echo '#!/bin/bash
    module list
    cd $SOUR && wget -O l.zip https://downloads.sourceforge.net/project/snpeff/snpEff_v4_3i_core.zip && \
    mv l.zip snpEff_v4_3i_core.zip && \
	rm -rf snpEff && \
    unzip snpEff_v4_3i_core.zip && \
    rm -rf snpEff_v4_3i_core && \
	mv snpEff snpEff_v4_3i_core && \
	mkdir -p $SOFT/snpeff/4.3.i/bin && \
	cp -r snpEff_v4_3i_core/* $SOFT/snpeff/4.3.i/bin && \
    newmod.sh \
    -s snpeff \
    -p $MODF/bioinformatics/ \
    -v 4.3.i \
    -d 4.3.i && \
	echo "module load java" >> $MODF/bioinformatics/snpeff/4.3.i
	echo "setenv SNPEFF $SOFT/snpeff/4.3.i/bin/snpEff.jar" >> $MODF/bioinformatics/snpeff/4.3.i
	echo "setenv SNPSIFT $SOFT/snpeff/4.3.i/bin/SnpSift.jar" >> $MODF/bioinformatics/snpeff/4.3.i
    ' > $LOGS/snpeff-4.3.i.sh
    chmod 755 $LOGS/snpeff-4.3.i.sh
    srun -o $LOGS/snpeff-4.3.i.out $LOGS/snpeff-4.3.i.sh
fi

if [ ! -f $MODF/bioinformatics/spades/3.10.0 ]; then
    echo 'spades-3.10.0'
    echo '#!/bin/bash
    module list
    cd $SOUR && wget http://spades.bioinf.spbau.ru/release3.10.0/SPAdes-3.10.0-Linux.tar.gz && \
    tar -zxvf SPAdes-3.10.0-Linux.tar.gz && \
    cd SPAdes-3.10.0-Linux && \
    mkdir -p $SOFT/spades/3.10.0 && \
    cp -r * $SOFT/spades/3.10.0/ && \ 
    newmod.sh \
    -s spades \
    -p $MODF/bioinformatics/ \
    -v 3.10.0 \
    -d 3.10.0
    ' > $LOGS/spades-3.10.0.sh
    chmod 755 $LOGS/spades-3.10.0.sh
    srun -o $LOGS/spades-3.10.0.out $LOGS/spades-3.10.0.sh
fi

rm -rf $MODF/bioinformatics/rsem/1.3.0

if [ ! -f $MODF/bioinformatics/rsem/1.3.0 ]; then
	echo 'rsem-1.3.0'
	echo '#!/bin/bash
	rm -rf $SOFT/rsem $SOUR/RSEM-1.3.0
	module load rlang/3.3.2
	module list
	cd $SOUR && wget -O l.tar.gz https://github.com/deweylab/RSEM/archive/v1.3.0.tar.gz && \ 
	mv l.tar.gz rsem-v1.3.0.tar.gz && \
	tar -zxvf rsem-v1.3.0.tar.gz && \
	mkdir -p $SOFT/rsem/1.3.0 && \
	mv RSEM-1.3.0 $SOFT/rsem/1.3.0/bin  && \
	cd $SOFT/rsem/1.3.0/bin && \
	make && make ebseq && \
	newmod.sh \
    -s rsem \
    -p $MODF/bioinformatics/ \
    -v 1.3.0 \
    -d 1.3.0 && \
    echo "module load rlang/3.3.2" >> $MODF/bioinformatics/rsem/1.3.0
	echo "prepend-path R_LIBS_USER /u/jboucas/modules/software/rsem/1.3.0/bin/EBSeq" >> $MODF/bioinformatics/rsem/1.3.0
	' > $LOGS/rsem-1.3.0.sh
    chmod 755 $LOGS/rsem-1.3.0.sh
    srun -o $LOGS/rsem-1.3.0.out $LOGS/rsem-1.3.0.sh
fi

exit

#exit

#module load python/2.7.12
#module load rlang/3.3.2
#python -m ensurepip
#pip install pip --upgrade
#pip install jupyter


cd $SOUR
wget -o d.tar.gz https://github.com/jeroenooms/openssl/archive/v0.9.5.tar.gz
mv d.tar.gz openssl_0.9.5.tar.gz
export PATH=$SOFT/openssl/1.1.0c/lib/:$PATH
export PKG_CONFIG_PATH=$SOFT/openssl/1.1.0c/lib/pkgconfig:$PKG_CONFIG_PATH
R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=$SOFT/openssl/1.1.0c/lib' -l $SOFT/rlang/3.3.2/lib64/R/library openssl_0.9.5.tar.gz
git clone https://github.com/ropensci/git2r.git
R CMD INSTALL --configure-vars='INCLUDE_DIR=$SOFT/openssl/1.1.0c/include LIB_DIR=$SOFT/openssl/1.1.0c/lib' -l $SOFT/rlang/3.3.2/lib64/R/library git2r

echo "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), c('$SOFT/rlang/3.3.2/lib64/R/library')  ,repos='http://ftp5.gwdg.de/pub/misc/cran/', dependencies=TRUE )" > ~/jupyter.install.R
echo "devtools::install_github('IRkernel/IRkernel',lib=c('$SOFT/rlang/3.3.2/lib64/R/library'))" >> ~/jupyter.install.R
unset R_LIBS_USER
Rscript ~/jupyter.install.R

chmod -R 755 $MODS

exit
