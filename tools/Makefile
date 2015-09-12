include ../Makefile.in

all: samtools-0.1.20/samtools blatSrc/blat/blat

download: samtools-0.1.20.tar.gz blatSrc35.zip

samtools-0.1.20.tar.gz:
	wget https://github.com/samtools/samtools/archive/0.1.20.tar.gz
	mv 0.1.20.tar.gz samtools-0.1.20.tar.gz

samtools-0.1.20: samtools-0.1.20.tar.gz
	tar xvzf samtools-0.1.20.tar.gz
	cd samtools-0.1.20 && \
	  patch -p1 < $(GFKDIR)/tools/samtools-0.1.20_K.patch && \
	  patch -p1 < ../samtools_uncompressed_rmdup.patch && \
	  patch -p1 < ../samtools_fcc.patch
	touch $@

samtools-0.1.20/samtools: samtools-0.1.20
	cd samtools-0.1.20 && make


blatOpenMPpatch.tar.gz:
	wget http://www.scls.riken.jp/scruise/wp-content/uploads/sites/3/2015/01/blatOpenMPpatch.tar.gz

blatOpenMPpatch/blatOpenMP.patch: blatOpenMPpatch.tar.gz
	mkdir -p blatOpenMPpatch
	cd blatOpenMPpatch && tar zxvf ../blatOpenMPpatch.tar.gz
	touch $@


blatSrc35.zip:
	wget http://hgwdev.cse.ucsc.edu/~kent/src/blatSrc35.zip

blatSrc: blatSrc35.zip blatOpenMPpatch/blatOpenMP.patch
	unzip blatSrc35.zip
	cd blatSrc && \
	  patch -p1 < ../blatOpenMPpatch/blatOpenMP.patch && \
	  git --git-dir= apply ../blat_omp_aics.patch
	touch $@

blatSrc/blat/blat: blatSrc
	cd blatSrc && make

install: samtools-0.1.20/samtools blatSrc/blat/blat
	cp samtools-0.1.20/samtools ../bin
	cp blatSrc/blat/blat ../bin
	cp blatSrc/utils/faToTwoBit/faToTwoBit ../bin

clean:
	cd samtools-0.1.20 && make clean
	cd blatSrc && make clean

clean_dirs:
	rm -rf samtools-0.1.20
	rm -rf blatSrc
	rm -rf blatOpenMPpatch

clean_files:
	rm -rf samtools-0.1.20.tar.gz blatOpenMPpatch.tar.gz blatSrc35.zip

distclean: clean_dirs clean_files
