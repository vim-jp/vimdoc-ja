#!gvim -u

set nocompatible
set nomore
set encoding=utf-8
set fileencodings=utf-8
syntax on
colorscheme delek

enew!

runtime plugin/tohtml.vim

source <sfile>:h/makehtml.vim

function! s:main()
  " for ja custom syntax
  let &runtimepath .= ',' . expand('<sfile>:p:h')
  call s:BuildHtml()
endfunction

function! s:BuildHtml()

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
  argdo call s:PostEdit() | update!
endfunction

function! s:system(cmd)
  call system(a:cmd)
  if v:shell_error
    throw 'system() failed: ' . a:cmd
  endif
endfunction

function! s:rmdir(path)
  if executable('rm')
    call s:system('rm -rf ' . shellescape(a:path))
  else
    call s:system('rmdir /s /q ' . shellescape(a:path))
  endif
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

call s:main()
