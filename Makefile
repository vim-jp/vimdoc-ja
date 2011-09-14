OUTDIR=build
TARGET_LANG=ja
VERSION=$(shell date +%Y%m%d)-r$(shell svnversion)

all: build_runtime

clean:
	rm -rf $(OUTDIR)/runtime

distclean:
	rm -rf $(OUTDIR)

.PHONY: all clean build_runtime snapshot zip distupload

$(OUTDIR)/runtime:
	mkdir -p $(OUTDIR)
	svn export --force runtime $(OUTDIR)/runtime

build_runtime: $(OUTDIR)/runtime

snapshot: build_runtime
	cd $(OUTDIR)/runtime && tar cf - * | bzip2 > ../vimdoc_$(TARGET_LANG)-snapshot.tar.bz2

zip: build_runtime
	cd $(OUTDIR)/runtime && zip -r9q ../vimdoc_ja-$(VERSION).zip *

distupload: zip
	python tools/googlecode_upload.py \
	  --project="vimdoc-ja" \
	  --summary="release $(VERSION)" \
	  $(OUTDIR)/vimdoc_ja-$(VERSION).zip

sites:
	cd google-sites; \
	  gvim -u build.vim -f; \
	  python upload.py;

