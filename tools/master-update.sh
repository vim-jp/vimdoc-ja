#!/bin/sh
# vim:set sts=2 sw=2 tw=0 et:

. `dirname $0`/update-lib.sh

setup "master2-test"

# TODO: update repository.
touch test.txt
ts=`date "+%Y/%m/%d %H:%M:%S%z"`
echo "${ts}" >> test.txt
if [ -e foo.txt ] ; then
  rm -f foo.txt
  touch bar.txt
  echo "${ts} foo->bar" >> bar.txt
elif [ -e bar.txt ] ; then
  rm -f bar.txt
  touch foo.txt
  echo "${ts} bar->foo" >> foo.txt
fi

teardown "vim-jp/vimdoc-ja@"
