" makehtml.vim
"
" Description:
"   Convert help file to HTML file.
"
"   When there are other language files,  multi-language HTML are
"   created.  (1) HTML files are named with "help.ab.html" (but
"   "help.txt" => "help.html").  (2) Header and Footer have links to
"   other language.  Otherwise single language HTML files are created
"   (named with "help.html" and no language links).
"
" Usage:
"   :cd doc
"   :helptags .
"   :source mkhtml.vim
"   :call MakeHtmlAll()

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

function! MakeHtmlAllBatch()
  call MakeTagsFile()
  let files = split(glob('*.??[tx]'), '\n')
  for i in range(len(files))
    call MakeHtml(files[i])
  endfor
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
  let g:html_no_pre = 1
  " set dumy highlight to keep syntax identity
  if !exists("s:attr_save")
    let s:attr_save = {}
    for name in ["helpStar", "helpBar", "helpHyperTextEntry", "helpHyperTextJump", "helpOption", "helpExample"]
      let s:attr_save[name] = synIDattr(synIDtrans(hlID(name)), "name")
      execute printf("hi %s term=bold cterm=bold gui=bold", name)
    endfor
  endif

  silent! %foldopen!
  TOhtml

  let lang = s:GetLang(a:fname)
  silent %s@<span class="\(helpHyperTextEntry\|helpHyperTextJump\|helpOption\)">\([^<]*\)</span>@\=s:MakeLink(lang, submatch(1), submatch(2))@ge
  silent %s@^<span class="Ignore">&lt;</span>\ze&nbsp;@\&nbsp;@ge
  silent %s@<span class="\(helpStar\|helpBar\|Ignore\)">[^<]*</span>@@ge
  call s:TranslateHelpExampleBlock()
  " remove style
  g/^\.\(helpBar\|helpStar\|helpHyperTextEntry\|helpHyperTextJump\|helpOption\)/silent delete _

  call s:Header()
  call s:Footer()

  wq! `=s:HtmlName(a:fname)`
  quit!
endfunction

" <span>...</span>  -> <div>...
" <span>...</span>     ...</div>
function! s:TranslateHelpExampleBlock()
  let mx = '^<span class="helpExample">\zs.*\ze</span><br>$'
  let i = 1
  while i <= line('$')
    if getline(i) =~ mx
      let start = i
      while i <= line('$') && getline(i) =~ mx
        call setline(i, matchstr(getline(i), mx) . '<br>')
        let i += 1
      endwhile
      let end = i - 1
      call setline(start, '<div class="helpExample">' . getline(start))
      call setline(end, matchstr(getline(end), '.*\ze<br>') . '</div>')
    else
      let i += 1
    endif
  endwhile
endfunction

function! s:Header()
  let name = fnamemodify(bufname("%"), ":r:r")
  let indexfile = s:GetIndexFile(bufname("%"))
  let title = printf("<title>Vim documentation: %s</title>", name)
  call setline(search('^<title', 'wn'), title)
  let header = [
        \ s:MakeLangLinks(bufname("%")),
        \ printf('<a name="top"></a><h1>Vim documentation: %s</h1>', name),
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
        \ s:MakeLangLinks(bufname("%")),
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
  elseif has_key(tags, ":" . tagname)
    let href = tags[":" . tagname]["html"]
    let href .= '#:' . tagname
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
    if s:IsSingleMode()
      let item["html"] = "tags.html"
    else
      let item["html"] = printf("tags%s.html", (a:lang == "") ? "" : "." . a:lang)
    endif
    let tags[item["name"]] = item
    let s:tags_{a:lang} = tags
  endif
  return s:tags_{a:lang}
endfunction

function! s:IsSingleMode()
  " if there is one language files, do not append language identifier
  " (use "help.html" instead of "help.ab.html").
  if !exists("s:single_mode")
    let files = split(glob('tags'), '\n')
    let files += split(glob('tags-??'), '\n')
    let s:single_mode = (len(files) == 1)
  endif
  return s:single_mode
endfunction

function! s:HtmlName(helpfile)
  " help.txt => "help.html"
  " help.jax => "help.ja.html"
  let lang = s:GetLang(a:helpfile)
  let base = fnamemodify(a:helpfile, ":r")
  if base == "help"
    let base = "index"
  elseif base == "index"
    let base = "vimindex"
  endif
  if s:IsSingleMode()
    return printf("%s.html", base)
  endif
  return printf("%s%s.html", base, (lang == "") ? "" : "." . lang)
endfunction

function! s:GetLang(fname)
  " help.txt => ""
  " help.jax => "ja"
  " help.jax.html => "ja"
  return matchstr(a:fname, '^.*\.\zs..\zex\%(.html\)\?$')
endfunction

function! s:GetIndexFile(fname)
  if s:IsSingleMode()
    return "index.html"
  endif
  let lang = s:GetLang(a:fname)
  return printf("index%s.html", (lang == "") ? "" : "." . lang)
endfunction

function! s:MakeLangLinks(htmlfile)
  if s:IsSingleMode()
    return ""
  endif
  let base = fnamemodify(a:htmlfile, ':r:r')
  let files = split(glob(base . '.??x'), '\n')
  let res = printf('Language: <a href="%s.html">en</a>', base)
  for name in files
    let lang = s:GetLang(name)
    let res .= printf(' <a href="%s">%s</a>', s:HtmlName(name), lang)
  endfor
  return res
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

