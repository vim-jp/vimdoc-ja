OUTDIR=build
TARGET_LANG=ja

build:
	perl tools/doc_maker.pl -v -p -d build/runtime/doc -e jax $(TARGET_LANG)/*.$(TARGET_LANG)x

clean:
	rm -rf $(OUTDIR)/runtime

distclean:
	rm -rf $(OUTDIR)

.PHONY: build clean distclean
