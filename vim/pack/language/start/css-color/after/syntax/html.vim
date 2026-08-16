" Language:     Colorful CSS Color Preview
" Author:       Aristotle Pagaltzis <pagaltzis@gmx.de>

if &filetype !=# 'html' | finish | endif
if !( has('gui_running') || &termguicolors || &t_Co==256 ) | finish | endif

" default html syntax should already be including the css syntax
call css_color#init('css', 'extended', 'cssMediaBlock,cssFunction,cssDefinition,cssAttrRegion,cssComment')
syn cluster colorableGroup add=htmlString,htmlCommentPart
