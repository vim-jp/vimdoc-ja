#!gvim -u

if has('vim_starting')
  set nocompatible
  set loadplugins
  call feedkeys(":source " . expand('<sfile>') . "\<CR>")
  finish
endif

set nocompatible
set nomore
set encoding=utf-8
set fileencodings=utf-8
syntax on
colorscheme delek

let $VIMDOCROOT = expand('<sfile>:p:h:h')

" for ja custom syntax
set runtimepath+=$VIMDOCROOT/runtime

source $VIMDOCROOT/tools/makehtml.vim

function! s:main()
  " clean
  for f in split(glob('html/*'), '\n')
    call delete(f)
  endfor

  if !isdirectory('html')
    call mkdir('html')
  endif

  cd html

  "
  " copy dist files
  "
  args $VIMDOCROOT/runtime/doc/* $VIMDOCROOT/vim_faq/vim_faq.jax
  argdo saveas %:t

  " generate tags
  try
    helptags .
  catch
    echo v:exception
  endtry

  enew

  "
  " generate html
  "
  set foldlevel=1000
  call MakeHtmlAll()
  " add header and footer
  tabnew
  " XXX: modeline may cause error.
  " 2html.vim escape modeline.  But it doesn't escape /^vim:/.
  set nomodeline
  args *.html
  argdo call s:PostEdit() | update
  quit

  cd -
endfunction

function! s:PostEdit()
  set fileformat=unix
  call s:ToJekyll()
endfunction

function! s:ToJekyll()
  let helpname = expand('%:t:r')
  if helpname == 'index'
    let helpname = 'help'
  endif
  " remove header
  1,/^<hr>/delete _
  " remove footer
  /^<hr>/,$delete _
  " escape jekyll tags
  %s/{\{2,}\|{%/{{ "\0" }}/ge
  " YAML front matter
  call append(0, [
        \ '---',
        \ 'layout: vimdoc',
        \ printf("helpname: '%s'", helpname),
        \ '---',
        \ ])
endfunction

try
  call s:main()
endtry

