" Vim port of the Prismatic Sublime Text theme.
" Source: https://github.com/huijing/Prismatic
" Copyright 2018 Chen Hui Jing. MIT licensed; see prismatic.LICENSE.

let s:palette = {
	\ 'bg': '#242424', 'fg': '#C5C8D4',
	\ 'line_bg': '#171717', 'ui_bg': '#1D1D1D', 'menu_bg': '#171717',
	\ 'status_bg': '#171717', 'status_fg': '#C5C8D4', 'border': '#32464B',
	\ 'selection': '#32464B', 'selection_inactive': '#2B383C',
	\ 'search_bg': '#FFC15A', 'search_fg': '#242424',
	\ 'cursor': '#FFCC00', 'cursor_fg': '#242424',
	\ 'line_nr': '#65737E', 'line_nr_active': '#C5C8D4',
	\ 'muted': '#65737E', 'subtle': '#536D79',
	\ 'comment': '#65737E', 'keyword': '#EF71D5', 'function': '#B8E986',
	\ 'variable': '#FFFFFF', 'string': '#FAC863', 'constant': '#F77669',
	\ 'type': '#10BAF1', 'punctuation': '#C5C8D4', 'special': '#50E3C2',
	\ 'tag': '#FF5370', 'attribute': '#12C359', 'property': '#10BAF1',
	\ 'accent': '#FFCC00', 'error': '#F92672', 'warning': '#FAC863',
	\ 'info': '#10BAF1', 'success': '#12C359',
	\ 'diff_add_bg': '#1D3325', 'diff_delete_bg': '#3B2525',
	\ 'diff_change_bg': '#252A3B', 'diff_text_bg': '#32464B',
	\ 'ansi': ['#242424', '#FF5370', '#12C359', '#FAC863', '#10BAF1', '#EF71D5', '#50E3C2', '#C5C8D4', '#65737E', '#F77669', '#B8E986', '#FFC15A', '#10BAF1', '#CF98FF', '#50E3C2', '#FFFFFF']
	\ }

call ported_theme#apply('prismatic', 'dark', s:palette)

" Preserve distinctions made by the original TextMate scopes that do not map
" one-to-one onto Vim's standard highlight groups.
call ported_theme#highlight('Number', '#C071EF', 'NONE', 'NONE')
call ported_theme#highlight('Float', '#C071EF', 'NONE', 'NONE')
call ported_theme#highlight('StorageClass', '#FF5370', 'NONE', 'NONE')

call ported_theme#highlight('htmlArg', '#12C359', 'NONE', 'italic')
call ported_theme#highlight('cssAttr', '#9992EB', 'NONE', 'NONE')
call ported_theme#highlight('cssClassName', '#12C359', 'NONE', 'italic')
call ported_theme#highlight('cssClassNameDot', '#12C359', 'NONE', 'italic')
call ported_theme#highlight('cssIdentifier', '#12C359', 'NONE', 'italic')
call ported_theme#highlight('cssPseudoClassId', '#12C359', 'NONE', 'italic')

call ported_theme#highlight('markdownH1', '#B8E986', 'NONE', 'NONE')
call ported_theme#highlight('markdownBold', '#FFC15A', 'NONE', 'bold')
call ported_theme#highlight('markdownItalic', '#FFC15A', '#171717', 'italic')
call ported_theme#highlight('markdownBoldItalic', '#FFC15A', '#171717', 'bold,italic')
call ported_theme#highlight('markdownLinkText', '#CF98FF', 'NONE', 'NONE')
call ported_theme#highlight('markdownUrl', '#CF98FF', 'NONE', 'underline')
call ported_theme#highlight('markdownHeadingDelimiter', '#B8E986', 'NONE', 'NONE')

unlet s:palette
