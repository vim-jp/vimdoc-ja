OUTDIR=build
TARGET_LANG=ja

all: $(OUTDIR)/runtime others
	@perl tools/doc_maker.pl -v -p -d $(OUTDIR)/runtime/doc -e jax $(TARGET_LANG)/*.$(TARGET_LANG)x

clean:
	rm -rf $(OUTDIR)/runtime

distclean:
	rm -rf $(OUTDIR)

.PHONY: all clean distclean


$(OUTDIR)/runtime:
	mkdir -p $(OUTDIR)/runtime
	mkdir -p $(OUTDIR)/runtime/doc
	mkdir -p $(OUTDIR)/runtime/syntax

$(OUTDIR)/runtime/%: runtime/%
	cp -f $< $@

others: $(OUTDIR)/runtime \
	$(OUTDIR)/runtime/syntax/help_ja.vim
