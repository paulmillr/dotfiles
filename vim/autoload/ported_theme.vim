" Shared Vim highlight renderer for the VS Code theme ports in colors/.

function! s:nearest_cube(value) abort
	let l:levels = [0, 95, 135, 175, 215, 255]
	let l:best = 0
	let l:distance = 256
	for l:index in range(0, 5)
		let l:current = abs(a:value - l:levels[l:index])
		if l:current < l:distance
			let l:best = l:index
			let l:distance = l:current
		endif
	endfor
	return l:best
endfunction

function! s:cterm(hex) abort
	if a:hex ==# '' || a:hex ==# 'NONE'
		return 'NONE'
	endif

	let l:red = str2nr(strpart(a:hex, 1, 2), 16)
	let l:green = str2nr(strpart(a:hex, 3, 2), 16)
	let l:blue = str2nr(strpart(a:hex, 5, 2), 16)
	if l:red == 0 && l:green == 0 && l:blue == 0
		return 0
	elseif l:red == 255 && l:green == 255 && l:blue == 255
		return 231
	endif

	let l:levels = [0, 95, 135, 175, 215, 255]
	let l:ri = s:nearest_cube(l:red)
	let l:gi = s:nearest_cube(l:green)
	let l:bi = s:nearest_cube(l:blue)
	let l:cr = l:levels[l:ri]
	let l:cg = l:levels[l:gi]
	let l:cb = l:levels[l:bi]
	let l:cube_distance = (l:red-l:cr)*(l:red-l:cr) + (l:green-l:cg)*(l:green-l:cg) + (l:blue-l:cb)*(l:blue-l:cb)

	let l:average = (l:red + l:green + l:blue) / 3
	let l:gray_index = max([0, min([23, (l:average - 3) / 10])])
	let l:gray = 8 + (l:gray_index * 10)
	let l:gray_distance = (l:red-l:gray)*(l:red-l:gray) + (l:green-l:gray)*(l:green-l:gray) + (l:blue-l:gray)*(l:blue-l:gray)

	return l:gray_distance < l:cube_distance ? 232 + l:gray_index : 16 + (36*l:ri) + (6*l:gi) + l:bi
endfunction

function! s:value(palette, key) abort
	return empty(a:key) ? 'NONE' : get(a:palette, a:key, 'NONE')
endfunction

function! s:highlight(group, foreground, background, style) abort
	let l:foreground = empty(a:foreground) ? 'NONE' : a:foreground
	let l:background = empty(a:background) ? 'NONE' : a:background
	let l:style = empty(a:style) ? 'NONE' : a:style
	execute 'highlight ' . a:group
		\ . ' guifg=' . l:foreground . ' guibg=' . l:background . ' gui=' . l:style
		\ . ' ctermfg=' . s:cterm(l:foreground) . ' ctermbg=' . s:cterm(l:background) . ' cterm=' . l:style
endfunction

function! ported_theme#apply(name, background, palette) abort
	execute 'set background=' . a:background
	highlight clear
	if exists('syntax_on')
		syntax reset
	endif
	let g:colors_name = a:name

	let l:groups = [
		\ ['Normal', 'fg', 'bg', 'NONE'],
		\ ['NormalNC', 'fg', 'bg', 'NONE'],
		\ ['Cursor', 'cursor_fg', 'cursor', 'NONE'],
		\ ['lCursor', 'cursor_fg', 'cursor', 'NONE'],
		\ ['CursorIM', 'cursor_fg', 'cursor', 'NONE'],
		\ ['CursorLine', '', 'line_bg', 'NONE'],
		\ ['CursorColumn', '', 'line_bg', 'NONE'],
		\ ['ColorColumn', '', 'border', 'NONE'],
		\ ['LineNr', 'line_nr', 'bg', 'NONE'],
		\ ['CursorLineNr', 'line_nr_active', 'line_bg', 'bold'],
		\ ['SignColumn', 'line_nr', 'bg', 'NONE'],
		\ ['FoldColumn', 'line_nr', 'bg', 'NONE'],
		\ ['Folded', 'muted', 'ui_bg', 'NONE'],
		\ ['VertSplit', 'border', 'bg', 'NONE'],
		\ ['WinSeparator', 'border', 'bg', 'NONE'],
		\ ['NonText', 'subtle', 'bg', 'NONE'],
		\ ['EndOfBuffer', 'bg', 'bg', 'NONE'],
		\ ['SpecialKey', 'subtle', 'bg', 'NONE'],
		\ ['Whitespace', 'subtle', 'bg', 'NONE'],
		\ ['Conceal', 'muted', 'bg', 'NONE'],
		\ ['Visual', '', 'selection', 'NONE'],
		\ ['VisualNOS', '', 'selection_inactive', 'NONE'],
		\ ['Search', 'search_fg', 'search_bg', 'NONE'],
		\ ['CurSearch', 'cursor_fg', 'cursor', 'bold'],
		\ ['IncSearch', 'cursor_fg', 'cursor', 'bold'],
		\ ['MatchParen', 'accent', 'selection', 'bold'],
		\ ['StatusLine', 'status_fg', 'status_bg', 'NONE'],
		\ ['StatusLineNC', 'muted', 'status_bg', 'NONE'],
		\ ['StatusLineTerm', 'status_fg', 'status_bg', 'NONE'],
		\ ['StatusLineTermNC', 'muted', 'status_bg', 'NONE'],
		\ ['WinBar', 'status_fg', 'status_bg', 'NONE'],
		\ ['WinBarNC', 'muted', 'status_bg', 'NONE'],
		\ ['TabLine', 'muted', 'ui_bg', 'NONE'],
		\ ['TabLineSel', 'fg', 'selection', 'bold'],
		\ ['TabLineFill', 'border', 'ui_bg', 'NONE'],
		\ ['Pmenu', 'fg', 'menu_bg', 'NONE'],
		\ ['PmenuSel', 'fg', 'selection', 'NONE'],
		\ ['PmenuSbar', '', 'border', 'NONE'],
		\ ['PmenuThumb', '', 'muted', 'NONE'],
		\ ['WildMenu', 'cursor_fg', 'cursor', 'bold'],
		\ ['QuickFixLine', '', 'selection', 'NONE'],
		\ ['NormalFloat', 'fg', 'menu_bg', 'NONE'],
		\ ['FloatBorder', 'border', 'menu_bg', 'NONE'],
		\ ['Directory', 'info', '', 'NONE'],
		\ ['Title', 'accent', '', 'bold'],
		\ ['ErrorMsg', 'error', 'bg', 'bold'],
		\ ['WarningMsg', 'warning', 'bg', 'NONE'],
		\ ['MoreMsg', 'success', '', 'NONE'],
		\ ['Question', 'info', '', 'NONE'],
		\ ['ModeMsg', 'accent', '', 'bold'],
		\ ['DiffAdd', '', 'diff_add_bg', 'NONE'],
		\ ['DiffDelete', 'error', 'diff_delete_bg', 'NONE'],
		\ ['DiffChange', '', 'diff_change_bg', 'NONE'],
		\ ['DiffText', 'fg', 'diff_text_bg', 'bold'],
		\ ['diffAdded', 'success', '', 'NONE'],
		\ ['diffRemoved', 'error', '', 'NONE'],
		\ ['diffChanged', 'info', '', 'NONE'],
		\ ['Comment', 'comment', '', 'italic'],
		\ ['Constant', 'constant', '', 'NONE'],
		\ ['String', 'string', '', 'NONE'],
		\ ['Character', 'constant', '', 'NONE'],
		\ ['Number', 'constant', '', 'NONE'],
		\ ['Boolean', 'constant', '', 'NONE'],
		\ ['Float', 'constant', '', 'NONE'],
		\ ['Identifier', 'variable', '', 'NONE'],
		\ ['Function', 'function', '', 'NONE'],
		\ ['Statement', 'keyword', '', 'NONE'],
		\ ['Conditional', 'keyword', '', 'NONE'],
		\ ['Repeat', 'keyword', '', 'NONE'],
		\ ['Label', 'keyword', '', 'NONE'],
		\ ['Operator', 'punctuation', '', 'NONE'],
		\ ['Keyword', 'keyword', '', 'NONE'],
		\ ['Exception', 'keyword', '', 'NONE'],
		\ ['PreProc', 'special', '', 'NONE'],
		\ ['Include', 'special', '', 'NONE'],
		\ ['Define', 'special', '', 'NONE'],
		\ ['Macro', 'special', '', 'NONE'],
		\ ['PreCondit', 'special', '', 'NONE'],
		\ ['Type', 'type', '', 'NONE'],
		\ ['StorageClass', 'keyword', '', 'NONE'],
		\ ['Structure', 'type', '', 'NONE'],
		\ ['Typedef', 'type', '', 'NONE'],
		\ ['Special', 'special', '', 'NONE'],
		\ ['SpecialChar', 'special', '', 'NONE'],
		\ ['Tag', 'tag', '', 'NONE'],
		\ ['Delimiter', 'punctuation', '', 'NONE'],
		\ ['SpecialComment', 'comment', '', 'italic'],
		\ ['Debug', 'error', '', 'NONE'],
		\ ['Underlined', 'info', '', 'underline'],
		\ ['Ignore', 'muted', '', 'NONE'],
		\ ['Error', 'error', '', 'bold'],
		\ ['Todo', 'cursor_fg', 'warning', 'bold'],
		\ ['htmlTag', 'punctuation', '', 'NONE'],
		\ ['htmlEndTag', 'punctuation', '', 'NONE'],
		\ ['htmlTagName', 'tag', '', 'NONE'],
		\ ['htmlArg', 'attribute', '', 'NONE'],
		\ ['cssProp', 'property', '', 'NONE'],
		\ ['cssAttr', 'constant', '', 'NONE'],
		\ ['markdownH1', 'function', '', 'bold'],
		\ ['markdownBold', 'fg', '', 'bold'],
		\ ['markdownItalic', 'fg', '', 'italic'],
		\ ['NERDTreeDir', 'info', '', 'NONE'],
		\ ['NERDTreeDirSlash', 'punctuation', '', 'NONE'],
		\ ['NERDTreeOpenable', 'accent', '', 'NONE'],
		\ ['NERDTreeClosable', 'accent', '', 'NONE'],
		\ ['NERDTreeFile', 'fg', '', 'NONE'],
		\ ['NERDTreeExecFile', 'success', '', 'NONE'],
		\ ['NERDTreeCWD', 'accent', '', 'bold'],
		\ ['NERDTreeCursorFile', 'search_fg', 'search_bg', 'NONE'],
		\ ['NERDTreeGitIgnored', 'muted', '', 'NONE'],
		\ ['SignifySignAdd', 'success', 'bg', 'NONE'],
		\ ['SignifySignChange', 'info', 'bg', 'NONE'],
		\ ['SignifySignDelete', 'error', 'bg', 'NONE']
		\ ]

	for [l:group, l:foreground, l:background, l:style] in l:groups
		call s:highlight(l:group, s:value(a:palette, l:foreground), s:value(a:palette, l:background), l:style)
	endfor

	for l:group in ['SpellBad', 'SpellCap', 'SpellRare', 'SpellLocal']
		let l:key = {'SpellBad': 'error', 'SpellCap': 'info', 'SpellRare': 'warning', 'SpellLocal': 'success'}[l:group]
		execute 'highlight ' . l:group . ' guifg=NONE guibg=NONE guisp=' . a:palette[l:key] . ' gui=undercurl cterm=underline'
	endfor

	for l:group in ['markdownH2', 'markdownH3', 'markdownH4', 'markdownH5', 'markdownH6']
		execute 'highlight! link ' . l:group . ' markdownH1'
	endfor
	highlight! link SignifySignChangeDelete SignifySignChange
	highlight! link SignifySignDeleteFirstLine SignifySignDelete
	highlight! link SignifyLineAdd DiffAdd
	highlight! link SignifyLineChange DiffChange
	highlight! link SignifyLineDelete DiffDelete
	highlight! link SignifyLineDeleteFirstLine DiffDelete

	let g:terminal_ansi_colors = copy(a:palette.ansi)
endfunction
