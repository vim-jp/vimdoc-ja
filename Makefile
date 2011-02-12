OUTDIR=build
TARGET_LANG=ja

all: $(OUTDIR)/runtime others jax status

clean:
	rm -rf $(OUTDIR)/runtime

distclean:
	rm -rf $(OUTDIR)

.PHONY: all clean distclean others jax snapshot


$(OUTDIR)/runtime:
	mkdir -p $(OUTDIR)/runtime
	mkdir -p $(OUTDIR)/runtime/doc
	mkdir -p $(OUTDIR)/runtime/syntax

$(OUTDIR)/runtime/%: runtime/%
	cp -f $< $@

others: $(OUTDIR)/runtime \
	$(OUTDIR)/runtime/syntax/help_$(TARGET_LANG).vim

jax:
	@perl tools/doc_maker.pl -v -p -d $(OUTDIR)/runtime/doc -e jax $(TARGET_LANG)/*.$(TARGET_LANG)x

status:
	@perl tools/status_table.pl -i $(TARGET_LANG) > $(OUTDIR)/status_$(TARGET_LANG).html

snapshot: $(OUTDIR)/runtime others jax
	tar cf - -C $(OUTDIR) runtime | bzip2 > $(OUTDIR)/vimdoc_$(TARGET_LANG)-snapshot.tar.bz2

