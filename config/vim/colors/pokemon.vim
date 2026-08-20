" Vim port of MangaMode: Pokemon.
" Source: https://github.com/MarkoNikolajevic/manga-mode-theme
" Copyright 2026 Marko Nikolajevic. MIT licensed; see mangamode.LICENSE.txt.

let s:palette = {
	\ 'bg': '#1B1E22', 'fg': '#E8EBEF',
	\ 'line_bg': '#22262B', 'ui_bg': '#181B20', 'menu_bg': '#181B20',
	\ 'status_bg': '#121519', 'status_fg': '#CFD7E2', 'border': '#2B313A',
	\ 'selection': '#313843', 'selection_inactive': '#272E37',
	\ 'search_bg': '#6C6652', 'search_fg': '#F6EEF3',
	\ 'cursor': '#E7C85A', 'cursor_fg': '#1B1E22',
	\ 'line_nr': '#76808D', 'line_nr_active': '#A7B1BE',
	\ 'muted': '#7E8897', 'subtle': '#495361',
	\ 'comment': '#7E8897', 'keyword': '#E7C85A', 'function': '#AAB5C4',
	\ 'variable': '#F6EEF3', 'string': '#B6C1CD', 'constant': '#F4D36D',
	\ 'type': '#C2CAD6', 'punctuation': '#95A0AF', 'special': '#F4D36D',
	\ 'tag': '#E7C85A', 'attribute': '#E7C85A', 'property': '#E8EBEF',
	\ 'accent': '#E7C85A', 'error': '#E06B74', 'warning': '#E7C85A',
	\ 'info': '#72BDF5', 'success': '#B6C1CD',
	\ 'diff_add_bg': '#282B30', 'diff_delete_bg': '#2B2429',
	\ 'diff_change_bg': '#252B31', 'diff_text_bg': '#384352',
	\ 'ansi': ['#1B1E22', '#E06B74', '#B6C1CD', '#E7C85A', '#AAB5C4', '#E7C85A', '#AAB5C4', '#E8EBEF', '#76808D', '#E06B74', '#B6C1CD', '#F4D36D', '#C2CAD6', '#E7C85A', '#C2CAD6', '#E8EBEF']
	\ }

call ported_theme#apply('pokemon', 'dark', s:palette)
unlet s:palette
