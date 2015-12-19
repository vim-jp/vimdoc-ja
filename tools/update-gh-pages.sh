#!/bin/sh
# vim:set sts=2 sw=2 tw=0 et:

. `dirname $0`/update-lib.sh

setup "gh-pages"

# Convert *.jax files to *.html.
TOHTML_DIR="target/to_html"
if [ -e "${TOHTML_DIR}" ] ; then
  rm -rf "${TOHTML_DIR}"
fi
if [ ! -e "${TOHTML_DIR}" ] ; then
  mkdir -p "${TOHTML_DIR}/doc"
fi
cp -R syntax "${TOHTML_DIR}"
cp doc/*.jax vim_faq/*.jax "${TOHTML_DIR}/doc"
cp tools/buildhtml.vim tools/makehtml.vim "${TOHTML_DIR}"
( cd "${TOHTML_DIR}/doc" && vim -esu ../buildhtml.vim -c "qall!") > /dev/null

rsync -rlptD --delete-after "${TOHTML_DIR}"/doc/*.html "${BRANCHDIR}/"

teardown "vim-jp/vimdoc-ja@"
