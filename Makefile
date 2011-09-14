OUTDIR=build
TARGET_LANG=ja
VERSION=$(shell date +%Y%m%d)-r$(shell svnversion)

all: build_runtime

clean:
	rm -rf $(OUTDIR)/runtime

distclean:
	rm -rf $(OUTDIR)

.PHONY: all clean distclean others jax build_runtime snapshot zip

$(OUTDIR)/runtime:
	mkdir -p $(OUTDIR)
	svn export --force runtime $(OUTDIR)/runtime

build_runtime: $(OUTDIR)/runtime

snapshot: build_runtime
	tar cf - -C $(OUTDIR) runtime | bzip2 > $(OUTDIR)/vimdoc_$(TARGET_LANG)-snapshot.tar.bz2

zip: build_runtime
	cd $(OUTDIR) && zip -r9q vimdoc_ja-$(VERSION).zip runtime
