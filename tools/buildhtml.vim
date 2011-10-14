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
  call s:FixIE8()
  call s:AddHeaderFooter()
  call s:StyleToLink()
endfunction

function! s:FixIE8()
  " IE8はHTMLがインライン要素のみの長いテキストだった場合にテキストの選
  " 択が激しく遅くなるようなので、適当にブロック要素を入れる。
  %s@^<br>$@<div><br></div>@e
endfunction

function! s:AddHeaderFooter()
  call append(search('^<body', 'wn')-1, [
        \ '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js" type="text/javascript"></script>',
        \ '<script src="vimdoc-ja.js" type="text/javascript"></script>',
        \ ])
  call append(search('^<body', 'wn'), [
        \ '<div id="cse-search-form" style="float:right;">Loading</div>',
        \ '<script src="//www.google.com/jsapi" type="text/javascript"></script>',
        \ '<script type="text/javascript"> ',
        \ '  google.load("search", "1", {language : "ja"});',
        \ '  google.setOnLoadCallback(function() {',
        \ '    var customSearchControl = new google.search.CustomSearchControl("001325159752250591701:65aunpq8rlg");',
        \ '    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);',
        \ '    var options = new google.search.DrawOptions();',
        \ '    options.enableSearchboxOnly("http://www.google.com/cse?cx=001325159752250591701:65aunpq8rlg");',
        \ '    customSearchControl.draw("cse-search-form", options);',
        \ '  }, true);',
        \ '</script>',
        \ '<link rel="stylesheet" href="//www.google.com/cse/style/look/default.css" type="text/css" />',
        \ ])
  call append(search('^</body', 'wn') - 1, [
        \ '<div style="text-align:right;">',
        \ '<a href="https://github.com/vim-jp/vimdoc-ja">Vim日本語ドキュメント</a><br>',
        \ '</div>',
        \ ])
endfunction

function! s:StyleToLink()
  1;/^<style/,/^<\/style/change
<link rel="stylesheet" href="style.css" type="text/css" />
.
endfunction

try
  call s:main()
endtry

