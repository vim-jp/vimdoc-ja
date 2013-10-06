#!/bin/sh
# vim:set sts=2 sw=2 tw=0 et:

. `dirname $0`/update-lib.sh
. `dirname $0`/to_html.sh

setup "test-gh-pages"

# Convert *.jax files to *.html.
to_html_dir "doc" "${BRANCHDIR}" "jax"
to_html_file "vim_faq/vim_faq.jax" "${BRANCHDIR}/vim_faq.html"

teardown "vim-jp/vimdoc-ja@"
