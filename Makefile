include Makefile.in

all: install setup

install:
	cd src && make install
	cd tools && make install

setup: install
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/align_bin.conf align/bin
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/align_ref.conf align/ref
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/dedup_bin.conf dedup/bin
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/dedup_ref.conf dedup/ref
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/detect_bin.conf detect/bin
	env GFKDIR=$(GFKDIR) etc/link_files.sh etc/detect_ref.conf detect/ref
	ln -sf `readlink -e $(INPUT_DIR)` align/Input

clean:
	cd src && make clean
	cd tools && make clean

setup_clean:
	rm -rf align/bin/* align/ref/*
	rm -rf dedup/bin/* dedup/ref/*
	rm -rf detect/bin/* detect/ref/*

distclean: setup_clean
	cd src && make distclean
	cd tools && make distclean
	rm -rf bin/*
