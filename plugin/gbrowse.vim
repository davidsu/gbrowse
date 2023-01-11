function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

function! s:gitlab_server_url(opts, ...) abort
  if a:0 || type(a:opts) != type({}) || a:opts.remote !~ 'git@gitlab.com'
    return ''
  endif
  let path = substitute(a:opts.path, '^/', '', '')
  let path = substitute(path, '\(.*\)\(Netrw\|NERD_tree\).*', '\1', '')
  
  let remote = substitute(substitute(a:opts.remote, 'git@gitlab.com:', 'https://gitlab.com/', ''), '.git$', '', '')
  if a:opts.commit =~# '^\d\=$'
    let commit = fugitive#RevParse(a:opts.commit, a:opts.repo.git_dir) 
  else
    let commit = fugitive#RevParse(a:opts.commit, a:opts.repo.git_dir)
  endif
  if get(a:opts, 'type', '') ==# 'blob' || a:opts.path =~# '[^/]$'
    let url = remote . '/-/blob/' . commit . '/' . path
    if get(a:opts, 'line1')
      let url .= '#L' . a:opts.line1
      if get(a:opts, 'line2') && get(a:opts, 'line2') != get(a:opts, 'line1')
        " gitlab sucks... this url only works if we first request single line, than change the url!!!???
      "   let url .= '-' . a:opts.line2
      endif
    endif
  endif
  return url
endfunction

if !exists('g:fugitive_browse_handlers')
  let g:fugitive_browse_handlers = []
endif

call insert(g:fugitive_browse_handlers, s:function('s:gitlab_server_url'))
