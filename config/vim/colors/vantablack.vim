" Vim port of the VS Code Vantablack theme.
" Source: https://github.com/bjarneo/vantablack-vscode
" Copyright 2025 Bjarne Oeverli. MIT licensed; see vantablack.LICENSE.txt.

let s:palette = {
	\ 'bg': '#0d0d0d', 'fg': '#ffffff',
	\ 'line_bg': '#111111', 'ui_bg': '#0d0d0d', 'menu_bg': '#111111',
	\ 'status_bg': '#111111', 'status_fg': '#ececec', 'border': '#333333',
	\ 'selection': '#222222', 'selection_inactive': '#1a1a1a',
	\ 'search_bg': '#333333', 'search_fg': '#ffffff',
	\ 'cursor': '#ffffff', 'cursor_fg': '#0d0d0d',
	\ 'line_nr': '#444444', 'line_nr_active': '#ffffff',
	\ 'muted': '#555555', 'subtle': '#222222',
	\ 'comment': '#555555', 'keyword': '#d0d0d0', 'function': '#e8e8e8',
	\ 'variable': '#909090', 'string': '#a8a8a8', 'constant': '#c0c0c0',
	\ 'type': '#b8b8b8', 'punctuation': '#707070', 'special': '#c0c0c0',
	\ 'tag': '#d0d0d0', 'attribute': '#b8b8b8', 'property': '#808080',
	\ 'accent': '#ececec', 'error': '#a4a4a4', 'warning': '#cecece',
	\ 'info': '#8d8d8d', 'success': '#b6b6b6',
	\ 'diff_add_bg': '#1a1a1a', 'diff_delete_bg': '#161616',
	\ 'diff_change_bg': '#1a1a1a', 'diff_text_bg': '#333333',
	\ 'ansi': ['#0d0d0d', '#a4a4a4', '#b6b6b6', '#cecece', '#8d8d8d', '#9b9b9b', '#b0b0b0', '#ececec', '#555555', '#a4a4a4', '#b6b6b6', '#cecece', '#8d8d8d', '#9b9b9b', '#b0b0b0', '#ffffff']
	\ }

call ported_theme#apply('vantablack', 'dark', s:palette)
unlet s:palette
