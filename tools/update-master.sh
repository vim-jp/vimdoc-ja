#!/bin/sh
# vim:set sts=2 sw=2 tw=0 et:

. `dirname $0`/update-lib.sh

setup "master"

# Copy files.
rsync -rlptD --delete-after doc/ ${BRANCHDIR}/doc
rsync -rlptD --delete-after syntax/ ${BRANCHDIR}/syntax
rsync -rlptD --delete-after README.md ${BRANCHDIR}/README.md

teardown "vim-jp/vimdoc-ja@"
