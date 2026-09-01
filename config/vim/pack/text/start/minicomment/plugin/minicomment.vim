" minicomment.vim — minimal comment toggler.
" <Leader>c<Space> toggles comments on the current line, [count] lines,
" or a visual selection. Replaces NERDCommenter.
if exists('g:loaded_minicomment')
  finish
endif
let g:loaded_minicomment = 1

" filetype: [left, right] delimiters (right empty for line comments)
let s:delims = {
      \ 'javascript': ['//', ''],
      \ 'typescript': ['//', ''],
      \ 'rust':       ['//', ''],
      \ 'c':          ['//', ''],
      \ 'cpp':        ['//', ''],
      \ 'go':         ['//', ''],
      \ 'sh':         ['#', ''],
      \ 'bash':       ['#', ''],
      \ 'zsh':        ['#', ''],
      \ 'python':     ['#', ''],
      \ 'ruby':       ['#', ''],
      \ 'yaml':       ['#', ''],
      \ 'toml':       ['#', ''],
      \ 'vim':        ['"', ''],
      \ 'html':       ['<!--', '-->'],
      \ 'css':        ['/*', '*/'],
      \ }

function! s:Toggle(first, last) abort
  let l:d = get(s:delims, &filetype, [])
  if empty(l:d)
    echo 'minicomment: no delimiter for filetype "' . &filetype . '"'
    return
  endif
  let [l:left, l:right] = l:d
  let l:lpat = '\V\^\(\s\*\)' . escape(l:left, '\') . '\s\?'

  " uncomment only if every non-blank line is commented
  let l:all_commented = 1
  for l:lnum in range(a:first, a:last)
    let l:line = getline(l:lnum)
    if l:line =~# '^\s*$'
      continue
    endif
    if l:line !~# l:lpat
      let l:all_commented = 0
      break
    endif
  endfor

  for l:lnum in range(a:first, a:last)
    let l:line = getline(l:lnum)
    if l:line =~# '^\s*$'
      continue
    endif
    if l:all_commented
      let l:line = substitute(l:line, l:lpat, '\1', '')
      if l:right !=# ''
        let l:line = substitute(l:line, '\V\s\?' . escape(l:right, '\') . '\s\*\$', '', '')
      endif
    else
      let l:line = substitute(l:line, '^\(\s*\)', '\1' . escape(l:left, '&\') . ' ', '')
      if l:right !=# ''
        let l:line .= ' ' . l:right
      endif
    endif
    call setline(l:lnum, l:line)
  endfor
endfunction

nnoremap <silent> <Leader>c<Space> :<C-u>call <SID>Toggle(line('.'), min([line('.') + v:count1 - 1, line('$')]))<CR>
xnoremap <silent> <Leader>c<Space> :<C-u>call <SID>Toggle(line("'<"), line("'>"))<CR>
