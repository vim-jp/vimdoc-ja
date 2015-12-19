#!vim -u
" FIXME:

set nocompatible
set nomore

" TODO: argument parser
enew!
let g:argv = argv()
silent! argdelete *

function! s:github_repos_downloads_list(user, repos)
  let url = printf('https://api.github.com/repos/%s/%s/downloads', a:user, a:repos)
  let cmd = printf('curl --silent %s', shellescape(url))
  let res = system(cmd)
  if v:shell_error
    throw 'fails to list downloads'
  endif
  let downloads = webapi#json#decode(res)
  if type(downloads) == type({}) && has_key(downloads, 'message')
    throw 'fails to list downloads: ' . downloads.message
  endif
  return downloads
endfunction

function! s:github_repos_downloads_get(user, repos, id)
  let url = printf('https://api.github.com/repos/%s/%s/downloads/%s', a:user, a:repos, a:id)
  let cmd = printf('curl --silent %s', shellescape(url))
  let res = system(cmd)
  if v:shell_error
    throw 'fails to get download'
  endif
  let download = webapi#json#decode(res)
  if has_key(download, 'message')
    throw 'fails to get download: ' . download.message
  endif
  return download
endfunction

function! s:github_repos_downloads_create(auth_user, auth_password, user, repos, file, name, description, content_type)
  " create download
  let url = printf('https://api.github.com/repos/%s/%s/downloads', a:user, a:repos)
  let data = {}
  let data.name = a:name
  let data.size = getfsize(a:file)
  if a:description != ''
    let data.description = a:description
  endif
  if a:content_type != ''
    let data.content_type = a:content_type
  endif
  let cmd = printf('curl --silent --user %s --data %s %s', shellescape(a:auth_user . ':' . a:auth_password), shellescape(webapi#json#encode(data)), shellescape(url))
  let res = system(cmd)
  if v:shell_error
    throw 'fails to create new download'
  endif
  let download = webapi#json#decode(res)
  if has_key(download, 'message')
    throw 'fails to create new download: ' . download.message
  endif

  " upload file
  let cmd = 'curl --silent'
        \ . ' -F ' . shellescape('key=' . download.path)
        \ . ' -F ' . shellescape('acl=' . download.acl)
        \ . ' -F ' . shellescape('success_action_status=201')
        \ . ' -F ' . shellescape('Filename=' . download.name)
        \ . ' -F ' . shellescape('AWSAccessKeyId=' . download.accesskeyid)
        \ . ' -F ' . shellescape('Policy=' . download.policy)
        \ . ' -F ' . shellescape('Signature=' . download.signature)
        \ . ' -F ' . shellescape('Content-Type=' . download.content_type)
        \ . ' -F ' . shellescape('file=@' . a:file)
        \ . ' ' . shellescape(download.s3_url)
  let res = system(cmd)
  if v:shell_error
    throw 'fails to upload file'
  endif

  return download
endfunction

function! s:github_repos_downloads_delete(auth_user, auth_password, user, repos, id)
  let url = printf('https://api.github.com/repos/%s/%s/downloads/%s', a:user, a:repos, a:id)
  let cmd = printf('curl --silent --request DELETE --user %s %s', shellescape(a:auth_user . ':' . a:auth_password), shellescape(url))
  let res = system(cmd)
  if v:shell_error
    throw 'fails to delete download'
  endif
  if res != ''
    let err = webapi#json#decode(res)
    throw 'fails to delete download: ' . err.message
  endif
endfunction

function! s:github_repos_downloads_get_by_name(user, repos, name)
  let downloads = s:github_repos_downloads_list(a:user, a:repos)
  for download in downloads
    if download.name ==# a:name
      return download
    endif
  endfor
  throw 'Not Found'
endfunction

function! s:github_repos_downloads_replace(auth_user, auth_password, user, repos, file, name, description, content_type)
  try
    let download = s:github_repos_downloads_get_by_name(a:user, a:repos, a:name)
  catch /Not Found/
    let download = {}
  endtry
  if !empty(download)
    call s:github_repos_downloads_delete(a:auth_user, a:auth_password, a:user, a:repos, download.id)
  endif
  call s:github_repos_downloads_create(a:auth_user, a:auth_password, a:user, a:repos, a:file, a:name, a:description, a:content_type)
endfunction

function! s:main()
  if isdirectory('vimdoc-ja')
    call s:rmdir('vimdoc-ja')
  endif
  if filereadable('vimdoc-ja.zip')
    call delete('vimdoc-ja.zip')
  endif
  if filereadable('vimdoc-ja.tar.gz')
    call delete('vimdoc-ja.tar.gz')
  endif
  call s:system('git clone -b master . vimdoc-ja')
  call s:rmdir('vimdoc-ja/.git')
  silent! helptags vimdoc-ja/doc
  call s:system('zip -r vimdoc-ja.zip vimdoc-ja')
  call s:system('tar czf vimdoc-ja.tar.gz vimdoc-ja')
  echo 'Please enter github user/password to upload package to vim-jp/vimdoc-ja project.'
  let auth_user = input('user: ')
  let auth_password = inputsecret('password: ')
  call s:github_repos_downloads_replace(auth_user, auth_password, 'vim-jp', 'vimdoc-ja', 'vimdoc-ja.zip', 'vimdoc-ja.zip', '', '')
  call s:github_repos_downloads_replace(auth_user, auth_password, 'vim-jp', 'vimdoc-ja', 'vimdoc-ja.tar.gz', 'vimdoc-ja.tar.gz', '', '')
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

try
  call s:main()
  qall
catch
  echo v:exception
  sleep 2
  cquit
endtry
