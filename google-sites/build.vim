#!gvim -u
" 手順:
" 1. gvim -u build.vim
" 2. python upload.py

if has('vim_starting')
  set nocompatible
  set loadplugins
  call feedkeys(":source " . expand('<sfile>:t') . "\<CR>")
  finish
endif

set nocompatible
set nomore

syntax on
colorscheme delek

function! s:main()
  " clean
  for f in split(glob('tmp/*'), '\n')
    call delete(f)
  endfor

  if !isdirectory('tmp')
    call mkdir('tmp')
  endif

  cd tmp

  " copy dist files
  args ../../ja/* ../../removed/vim_faq_help.jax
  argdo saveas %:t
  " remove header
  args *.jax
  argdo 1,/^$/delete | update
  " add non-ascii char
  edit vim_faq_help.jax | 1s/$/ 和訳/ | update

  " generate tags
  try
    helptags .
  catch
    echo v:exception
  endtry

  enew

  " generate html
  set foldlevel=1000
  call MakeHtmlAll()
  " add header and footer
  tabnew
  args home *-html
  argdo call s:AddHeaderFooter() | call s:ToGoogleSitesContent() | update
  quit

  cd ..
endfunction

function! s:AddHeaderFooter()
  1;/<body>/
  call append('.', [])

  1;/<\/body>/-1
  call append('.', [])
endfunction

" Remove header and footer.
" Convert class="..." to style="...".
function! s:ToGoogleSitesContent()
  let style = {}
  1;/^<style/
  let lnum = line('.')
  while getline(lnum) !~ '^</style>'
    let line = getline(lnum)
    if line =~ '^\.'
      let m = matchlist(line, '^\.\(\w*\) { \(.*\) }')
      let style[m[1]] = 'style="' . m[2] . '"'
    endif
    let lnum += 1
  endwhile
  %s/\<class="\(\w*\)"/\=get(style, submatch(1), '')/g

  1,/^<body>/delete
  /<\/body>/,$delete

endfunction

function! MakeHtmlAll()
  if bufname("%") != "" || &modified
    new
  endif
  let s:log = []
  call MakeTagsFile()
  let files = split(glob('*.??[tx]'), '\n')
  for i in range(len(files))
    call append('$', printf("%d/%d %s -> %s", i+1, len(files), files[i], s:HtmlName(files[i])))
  endfor
  silent 1delete _
  for i in range(len(files))
    call cursor(i+1, 1)
    redraw!   " show progress
    let file = files[i]
    call MakeHtml(file)
    call setline(i+1, getline(i+1) . ' *DONE*')
  endfor
  if s:log != []
    new
    call append(0, s:log)
  endif
endfunction

function! MakeTagsFile()
  let files = split(glob('tags'), '\n')
  let files += split(glob('tags-??'), '\n')
  for file in files
    let lang = matchstr(file, 'tags-\zs..$')
    if lang == ""
      let fname = "tags.txt"
    else
      let fname = printf("tags.%sx", lang)
    endif
    new `=fname`
    silent %delete _
    let tags = s:GetTags(lang)
    for tagname in sort(keys(tags))
      if tagname == "help-tags"
        continue
      endif
      call append('$', printf("|%s|\t\t%s", tagname, tags[tagname]["filename"]))
    endfor
    call append('$', ' vim:ft=help:')
    silent 1delete _
    wq!
  endfor
endfunction

function! MakeHtml(fname)
  new `=a:fname`

  " 2html options
  let g:html_use_css = 1
  let g:html_no_pre = 0
  " set dumy highlight to keep syntax identity
  if !exists("s:attr_save")
    let s:attr_save = {}
    for name in ["helpStar", "helpBar", "helpHyperTextEntry", "helpHyperTextJump", "helpOption"]
      let s:attr_save[name] = synIDattr(synIDtrans(hlID(name)), "name")
      execute printf("hi %s term=bold cterm=bold gui=bold", name)
    endfor
  endif

  TOhtml

  let lang = s:GetLang(a:fname)
  silent %s@<span class="\(helpHyperTextEntry\|helpHyperTextJump\|helpOption\)">\([^<]*\)</span>@\=s:MakeLink(lang, submatch(1), submatch(2))@ge
  silent %s@^<span class="Ignore">&lt;</span>\ze&nbsp;@\&nbsp;@ge
  silent %s@<span class="\(helpStar\|helpBar\|Ignore\)">[^<]*</span>@@ge
  " remove style
  g/^\.\(helpBar\|helpStar\|helpHyperTextEntry\|helpHyperTextJump\|helpOption\)/silent delete _

  call s:Header()
  call s:Footer()

  wq! `=s:HtmlName(a:fname)`
  quit!
endfunction

function! s:Header()
  let name = fnamemodify(bufname("%"), ":r:r")
  let indexfile = s:GetIndexFile(bufname("%"))
  let header = [
        \ '<a name="top"></a>',
        \ printf('<a href="%s">main help file</a>', indexfile),
        \ '<hr>',
        \ ]
  call append(search('^<body', 'wn'), header)
  let style = [
        \ '.MissingTag { background-color: black; color: white; }',
        \ '.EnglishTag { background-color: gray; color: white; }',
        \ ]
  call append(search('^<style', 'wn') + 1, style)
endfunction

function! s:Footer()
  let indexfile = s:GetIndexFile(bufname("%"))
  let footer = [
        \ '<hr>',
        \ printf('<a href="#top">top</a> - <a href="%s">main help file</a><br>', indexfile),
        \ ]
  call append(search('^</body', 'wn') - 1, footer)
endfunction

function! s:MakeLink(lang, hlname, tagname)
  let tagname = a:tagname
  let tagname = substitute(tagname, '&lt;', '<', 'g')
  let tagname = substitute(tagname, '&gt;', '>', 'g')
  let tagname = substitute(tagname, '&amp;', '\&', 'g')
  if a:hlname == "helpHyperTextEntry"
    let sep = "*"
  elseif a:hlname == "helpHyperTextJump"
    let sep = "|"
  elseif a:hlname == "helpOption"
    let sep = ""
  endif
  let tags = s:GetTags(a:lang)
  if has_key(tags, tagname)
    let href = tags[tagname]["html"]
    if tagname !~ '\.txt$' && tagname != "help-tags"
      let href .= '#' . tagname
    endif
    if a:hlname == "helpHyperTextEntry"
      let res = printf('<a class="%s" href="%s" name="%s">%s%s%s</a>', s:attr_save[a:hlname], href, a:tagname, sep, a:tagname, sep)
    else
      let res = printf('<a class="%s" href="%s">%s%s%s</a>', s:attr_save[a:hlname], href, sep, a:tagname, sep)
    endif
  else
    " missing tag or not translated or typo.  use English if possible.
    call s:Log("%s: tag error: %s", bufname("%"), tagname)
    let tags = s:GetTags("")
    if has_key(tags, tagname)
      let href = tags[tagname]["html"]
      if tagname !~ '\.txt$'
        let href .= '#' . tagname
      endif
      let res = printf('<a class="EnglishTag" href="%s">%s%s%s</a>', href, sep, a:tagname, sep)
    else
      let res = printf('<span class="MissingTag">%s%s%s</span>', sep, a:tagname, sep)
    endif
  endif
  return res
endfunction

function! s:GetTags(lang)
  if !exists("s:tags_" . a:lang)
    let &l:tags = (a:lang == "") ? "./tags" : "./tags-" . a:lang
    let tags = {}
    for item in taglist(".*")
      let item["html"] = s:HtmlName(item["filename"])
      let tags[item["name"]] = item
    endfor
    " for help-tags
    let item = {}
    let item["name"] = "help-tags"
    let item["html"] = "tags-html"
    let tags[item["name"]] = item
    let s:tags_{a:lang} = tags
  endif
  return s:tags_{a:lang}
endfunction

function! s:HtmlName(helpfile)
  " help.txt => "help.html"
  " help.jax => "help.ja.html"
  let base = fnamemodify(a:helpfile, ":r")
  if base == "help"
    return s:GetIndexFile(a:helpfile)
  endif
  if base == "index"
    let base = "vimindex"
  endif
  return printf("%s-html", base)
endfunction

function! s:GetLang(fname)
  " help.txt => ""
  " help.jax => "ja"
  " help.jax.html => "ja"
  return matchstr(a:fname, '^.*\.\zs..\zex\%(.html\)\?$')
endfunction

function! s:GetIndexFile(fname)
  return "home"
endfunction

function! s:Log(fmt, ...)
  if exists("s:log")
    if len(a:000) == 0
      call add(s:log, a:fmt)
    else
      call add(s:log, call("printf", [a:fmt] + a:000))
    endif
  endif
endfunction

try
  call s:main()
endtry
