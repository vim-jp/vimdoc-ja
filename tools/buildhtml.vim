#!gvim -u

set nocompatible
set nomore
set encoding=utf-8
set fileencodings=utf-8
syntax on
colorscheme delek


" TODO: argument parser
enew!
let g:argv = argv()
argdelete *

runtime plugin/tohtml.vim

source <sfile>:h:h/tools/makehtml.vim

function! s:main()
  if isdirectory('html')
    call s:rmdir('html')
  endif
  call s:system('git clone . html')
  cd html
  call s:system('git branch -f master origin/master')
  call s:system('git branch -f gh-pages origin/gh-pages')
  call s:system('git checkout master')
  call s:system('git checkout-index --prefix=master/ -a')
  call s:system('git checkout devel')
  call s:system('git checkout-index --prefix=devel/ -a')
  call s:system('git checkout gh-pages')
  " for ja custom syntax
  let &runtimepath .= ',' . fnamemodify('./master', ':p')
  call s:BuildHtml()
  call s:system('git commit -a -m "update html"')
  cd ..
endfunction

function! s:BuildHtml()
  call mkdir('tmp')
  cd tmp

  "
  " copy dist files
  "
  args ../master/doc/* ../devel/vim_faq/vim_faq.jax
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
  argdo call s:PostEdit() | saveas! ../%:t

  cd ..
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

if index(g:argv, "--batch") != -1
  try
    call s:main()
  catch
    cquit
  endtry
  qall!
else
  try
    call s:main()
  endtry
endif

