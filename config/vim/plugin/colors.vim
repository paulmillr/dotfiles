" :Colors — minimal fuzzy colorscheme picker with live preview.
" First-party replacement for fzf.vim's :Colors; needs only vim 8.2.1665+
" (popup windows and matchfuzzy()).  Type to filter, ctrl-j/ctrl-k or
" arrows to move (the scheme under the cursor is applied immediately),
" enter to keep it, esc to restore the previous scheme.
"
" Order: custom schemes (from ~/.vim etc.) first, then dark built-ins,
" then light built-ins.  A built-in that adapts to 'background' appears
" twice, as "name [dark]" and "name [light]"; picking a variant sets
" 'background' before loading the scheme.
if exists('g:loaded_colors_picker') || !has('popupwin') || !exists('*matchfuzzy')
	finish
endif
let g:loaded_colors_picker = 1

let s:height = 15

function! s:ByName(a, b) abort
	return a:a.name ==# a:b.name ? 0 : (a:a.name ># a:b.name ? 1 : -1)
endfunction

function! s:AllSchemes() abort
	if exists('s:all')
		return s:all
	endif
	let l:runtime = resolve($VIMRUNTIME)
	let l:custom = []
	let l:dark = []
	let l:light = []
	let l:seen = {}
	for l:file in globpath(&runtimepath, 'colors/*.vim', 0, 1)
		let l:name = fnamemodify(l:file, ':t:r')
		" First hit along 'runtimepath' wins, like :colorscheme itself.
		if has_key(l:seen, l:name)
			continue
		endif
		let l:seen[l:name] = 1
		if stridx(resolve(fnamemodify(l:file, ':p')), l:runtime) != 0
			call add(l:custom, {'name': l:name, 'bg': '', 'label': l:name})
			continue
		endif
		let l:text = join(readfile(l:file), "\n")
		let l:has_dark = l:text =~# 'background=dark'
		let l:has_light = l:text =~# 'background=light'
		if !l:has_dark && !l:has_light
			" No explicit background: dark by default; schemes that read
			" &background adapt to either, so list both variants.
			let l:has_dark = 1
			let l:has_light = l:text =~# '&background'
		endif
		if l:has_dark
			call add(l:dark, {'name': l:name, 'bg': 'dark', 'label': l:name . ' [dark]'})
		endif
		if l:has_light
			call add(l:light, {'name': l:name, 'bg': 'light', 'label': l:name . ' [light]'})
		endif
	endfor
	let s:all = sort(l:custom, 's:ByName') + sort(l:dark, 's:ByName') + sort(l:light, 's:ByName')
	return s:all
endfunction

function! s:Schemes(query) abort
	let l:all = s:AllSchemes()
	return a:query ==# '' ? copy(l:all) : matchfuzzy(l:all, a:query, {'key': 'name'})
endfunction

function! s:Apply(item) abort
	let &background = a:item.bg ==# '' ? s:saved_background : a:item.bg
	execute 'colorscheme' fnameescape(a:item.name)
endfunction

function! s:Preview() abort
	if s:index >= len(s:items)
		return
	endif
	try
		call s:Apply(s:items[s:index])
	catch
	endtry
endfunction

function! s:Render() abort
	" Keep the selection inside the visible slice.
	let s:top = min([s:top, s:index])
	let s:top = max([s:top, s:index - s:height + 1])
	let l:lines = ['> ' . s:query]
	let l:i = s:top
	while l:i < min([s:top + s:height, len(s:items)])
		call add(l:lines, (l:i == s:index ? '» ' : '  ') . s:items[l:i].label)
		let l:i += 1
	endwhile
	if empty(s:items)
		call add(l:lines, '  [no match]')
	endif
	call popup_settext(s:winid, l:lines)
endfunction

function! s:Move(step) abort
	if empty(s:items)
		return
	endif
	let s:index = (s:index + a:step + len(s:items)) % len(s:items)
	call s:Preview()
	call s:Render()
endfunction

function! s:Filter(winid, key) abort
	if a:key ==# "\<Esc>" || a:key ==# "\<C-c>"
		call popup_close(a:winid, -1)
	elseif a:key ==# "\<CR>"
		call popup_close(a:winid, s:index < len(s:items) ? s:index : -1)
	elseif a:key ==# "\<C-j>" || a:key ==# "\<Down>" || a:key ==# "\<Tab>"
		call s:Move(1)
	elseif a:key ==# "\<C-k>" || a:key ==# "\<Up>" || a:key ==# "\<S-Tab>"
		call s:Move(-1)
	elseif a:key ==# "\<BS>" || a:key ==# "\<C-h>"
		let s:query = strcharpart(s:query, 0, strchars(s:query) - 1)
		call s:Requery()
	elseif strchars(a:key) == 1 && a:key >=# ' ' && a:key !=# "\<Del>"
		let s:query .= a:key
		call s:Requery()
	endif
	return 1
endfunction

function! s:Requery() abort
	let s:items = s:Schemes(s:query)
	let s:index = 0
	let s:top = 0
	call s:Preview()
	call s:Render()
endfunction

function! s:Done(winid, result) abort
	if a:result >= 0 && a:result < len(s:items)
		call s:Apply(s:items[a:result])
		echo 'colorscheme' s:items[a:result].label
	else
		let &background = s:saved_background
		execute 'colorscheme' fnameescape(s:saved_scheme)
	endif
endfunction

function! s:Open(query) abort
	let s:saved_scheme = get(g:, 'colors_name', 'default')
	let s:saved_background = &background
	let s:query = a:query
	let s:winid = popup_create([], {
		\ 'title': ' :Colors ',
		\ 'pos': 'center',
		\ 'minwidth': 32,
		\ 'maxheight': s:height + 1,
		\ 'border': [],
		\ 'padding': [0, 1, 0, 1],
		\ 'mapping': 0,
		\ 'filter': function('s:Filter'),
		\ 'callback': function('s:Done'),
		\ })
	call s:Requery()
endfunction

command! -nargs=? Colors call s:Open(<q-args>)
