" Language:     Colorful CSS Color Preview
" Author:       Aristotle Pagaltzis <pagaltzis@gmx.de>

if &filetype !=# 'css' | finish | endif
if !( has('gui_running') || &termguicolors || &t_Co==256 ) | finish | endif

call css_color#init('css', 'extended', 'cssMediaBlock,cssFunction,cssDefinition,cssAttrRegion,cssComment')
