" Vim port of MangaMode: Sailor Moon.
" Source: https://github.com/MarkoNikolajevic/manga-mode-theme
" Copyright 2026 Marko Nikolajevic. MIT licensed; see mangamode.LICENSE.txt.

let s:palette = {
	\ 'bg': '#F0EBE3', 'fg': '#3A3248',
	\ 'line_bg': '#E9E4DB', 'ui_bg': '#EBE6DD', 'menu_bg': '#F5F0E8',
	\ 'status_bg': '#E3DED5', 'status_fg': '#4A3D58', 'border': '#D6CCDC',
	\ 'selection': '#E0D5DE', 'selection_inactive': '#E6DEEA',
	\ 'search_bg': '#E8C8D6', 'search_fg': '#3A3248',
	\ 'cursor': '#B45679', 'cursor_fg': '#F5F0E8',
	\ 'line_nr': '#B0A8BA', 'line_nr_active': '#7D7290',
	\ 'muted': '#8A7E98', 'subtle': '#C0B3C6',
	\ 'comment': '#8A7E98', 'keyword': '#B45679', 'function': '#3D5A99',
	\ 'variable': '#3A3248', 'string': '#2B8C6F', 'constant': '#B8860B',
	\ 'type': '#7D6A9E', 'punctuation': '#7B6D94', 'special': '#B8860B',
	\ 'tag': '#B45679', 'attribute': '#B45679', 'property': '#45394F',
	\ 'accent': '#B45679', 'error': '#C74852', 'warning': '#B8860B',
	\ 'info': '#3D5A99', 'success': '#2B8C6F',
	\ 'diff_add_bg': '#E0E3D9', 'diff_delete_bg': '#ECDDE0',
	\ 'diff_change_bg': '#DED9E6', 'diff_text_bg': '#D5DED3',
	\ 'ansi': ['#3A3248', '#C74852', '#2B8C6F', '#B8860B', '#3D5A99', '#B45679', '#3D7A8C', '#F0EBE3', '#7D7290', '#D4586A', '#389E7E', '#C89720', '#536FA6', '#C46B8E', '#4D8E9C', '#F5F0E8']
	\ }

call ported_theme#apply('sailormoon', 'light', s:palette)
unlet s:palette
