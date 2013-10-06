" vim:set sts=2 sw=2 tw=0 et:
scriptencoding utf-8

set rtp+=.
set nocompatible
set nomore
"set encoding=utf-8
set fileencodings=utf-8
set foldlevel=1000
set nomodeline
set fileformat=unix
syntax on
colorscheme delek
let g:html_no_progress = 1

runtime plugin/tohtml.vim
source <sfile>:h:h/tools/makehtml.vim

function! ToJekyll(dst)
  e! `=a:dst`

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
  setlocal fileformat=unix

  wq! `=a:dst`
endfunction

function! ToJekyllHTML(src, dst)
  call MakeHtml2(a:src, a:dst)
  call ToJekyll(a:dst)
endfunction
