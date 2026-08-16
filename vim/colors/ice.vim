" Ice Ice OLED -- a pure-black, cool-toned colorscheme for Vim.
" Ported from https://github.com/mholt/ice-ice-oled
" Original theme copyright 2026 Matthew Holt, licensed under the MIT License.
" See colors/ice.LICENSE.txt.

set background=dark
highlight clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'ice'

" Editor
highlight Normal          guifg=#b5d0df guibg=#000000 gui=NONE      ctermfg=152 ctermbg=0   cterm=NONE
highlight Cursor          guifg=#000000 guibg=#ffffff gui=NONE      ctermfg=0   ctermbg=231 cterm=NONE
highlight lCursor         guifg=#000000 guibg=#77def3 gui=NONE      ctermfg=0   ctermbg=117 cterm=NONE
highlight CursorIM       guifg=#000000 guibg=#77def3 gui=NONE      ctermfg=0   ctermbg=117 cterm=NONE
highlight CursorLine     guifg=NONE    guibg=#070e12 gui=NONE      ctermfg=NONE ctermbg=233 cterm=NONE
highlight CursorColumn   guifg=NONE    guibg=#070e12 gui=NONE      ctermfg=NONE ctermbg=233 cterm=NONE
highlight ColorColumn    guifg=NONE    guibg=#14242c gui=NONE      ctermfg=NONE ctermbg=235 cterm=NONE
highlight LineNr         guifg=#395466 guibg=#000000 gui=NONE      ctermfg=240 ctermbg=0   cterm=NONE
highlight CursorLineNr   guifg=#6c9dbe guibg=#070e12 gui=bold      ctermfg=110 ctermbg=233 cterm=bold
highlight SignColumn     guifg=#395466 guibg=#000000 gui=NONE      ctermfg=240 ctermbg=0   cterm=NONE
highlight FoldColumn     guifg=#395466 guibg=#000000 gui=NONE      ctermfg=240 ctermbg=0   cterm=NONE
highlight Folded         guifg=#708090 guibg=#050a0d gui=NONE      ctermfg=66  ctermbg=233 cterm=NONE
highlight VertSplit      guifg=#112a36 guibg=#000000 gui=NONE      ctermfg=235 ctermbg=0   cterm=NONE
highlight WinSeparator   guifg=#112a36 guibg=#000000 gui=NONE      ctermfg=235 ctermbg=0   cterm=NONE
highlight NonText        guifg=#14242c guibg=#000000 gui=NONE      ctermfg=235 ctermbg=0   cterm=NONE
highlight EndOfBuffer    guifg=#000000 guibg=#000000 gui=NONE      ctermfg=0   ctermbg=0   cterm=NONE
highlight SpecialKey     guifg=#1e2a32 guibg=#000000 gui=NONE      ctermfg=236 ctermbg=0   cterm=NONE
highlight Whitespace     guifg=#1e2a32 guibg=#000000 gui=NONE      ctermfg=236 ctermbg=0   cterm=NONE

" Selection and search
highlight Visual         guifg=NONE    guibg=#1a2530 gui=NONE      ctermfg=NONE ctermbg=236 cterm=NONE
highlight VisualNOS      guifg=NONE    guibg=#0f1a20 gui=NONE      ctermfg=NONE ctermbg=234 cterm=NONE
highlight Search         guifg=#d0e0e8 guibg=#004f6f gui=NONE      ctermfg=188 ctermbg=24  cterm=NONE
highlight CurSearch      guifg=#000000 guibg=#00a2cf gui=bold      ctermfg=0   ctermbg=38  cterm=bold
highlight IncSearch      guifg=#000000 guibg=#77def3 gui=bold      ctermfg=0   ctermbg=117 cterm=bold
highlight MatchParen     guifg=#77def3 guibg=#1a3038 gui=bold      ctermfg=117 ctermbg=236 cterm=bold

" Menus and status
highlight StatusLine     guifg=#b0c4d0 guibg=#000000 gui=NONE      ctermfg=152 ctermbg=0   cterm=NONE
highlight StatusLineNC   guifg=#4a5a65 guibg=#000000 gui=NONE      ctermfg=59  ctermbg=0   cterm=NONE
highlight StatusLineTerm guifg=#b0c4d0 guibg=#000000 gui=NONE      ctermfg=152 ctermbg=0   cterm=NONE
highlight StatusLineTermNC guifg=#4a5a65 guibg=#000000 gui=NONE    ctermfg=59  ctermbg=0   cterm=NONE
highlight TabLine        guifg=#485b66 guibg=#000000 gui=NONE      ctermfg=59  ctermbg=0   cterm=NONE
highlight TabLineSel     guifg=#c8d8e4 guibg=#112a36 gui=bold      ctermfg=188 ctermbg=235 cterm=bold
highlight TabLineFill    guifg=#112a36 guibg=#000000 gui=NONE      ctermfg=235 ctermbg=0   cterm=NONE
highlight Pmenu          guifg=#b0c4d0 guibg=#050a0d gui=NONE      ctermfg=152 ctermbg=233 cterm=NONE
highlight PmenuSel       guifg=#d0e0e8 guibg=#1a3038 gui=NONE      ctermfg=188 ctermbg=236 cterm=NONE
highlight PmenuSbar      guifg=NONE    guibg=#112a36 gui=NONE      ctermfg=NONE ctermbg=235 cterm=NONE
highlight PmenuThumb     guifg=NONE    guibg=#4a7a88 gui=NONE      ctermfg=NONE ctermbg=66  cterm=NONE
highlight WildMenu       guifg=#ffffff guibg=#157aad gui=bold      ctermfg=231 ctermbg=31  cterm=bold
highlight QuickFixLine   guifg=NONE    guibg=#1a3038 gui=NONE      ctermfg=NONE ctermbg=236 cterm=NONE
highlight ToolbarLine    guifg=#b0c4d0 guibg=#050a0d gui=NONE      ctermfg=152 ctermbg=233 cterm=NONE
highlight ToolbarButton  guifg=#ffffff guibg=#157aad gui=bold      ctermfg=231 ctermbg=31  cterm=bold

" Messages
highlight Directory      guifg=#6abef6 guibg=NONE    gui=NONE      ctermfg=75  ctermbg=NONE cterm=NONE
highlight Title          guifg=#46afff guibg=NONE    gui=bold      ctermfg=75  ctermbg=NONE cterm=bold
highlight ErrorMsg       guifg=#ea5353 guibg=#000000 gui=bold      ctermfg=203 ctermbg=0   cterm=bold
highlight WarningMsg     guifg=#e6df7e guibg=#000000 gui=NONE      ctermfg=186 ctermbg=0   cterm=NONE
highlight MoreMsg        guifg=#43b35d guibg=NONE    gui=NONE      ctermfg=71  ctermbg=NONE cterm=NONE
highlight Question       guifg=#77def3 guibg=NONE    gui=NONE      ctermfg=117 ctermbg=NONE cterm=NONE
highlight ModeMsg        guifg=#77def3 guibg=NONE    gui=bold      ctermfg=117 ctermbg=NONE cterm=bold

" Diff
highlight DiffAdd        guifg=NONE    guibg=#001f1c gui=NONE      ctermfg=NONE ctermbg=22  cterm=NONE
highlight DiffDelete     guifg=#7e3636 guibg=#230011 gui=NONE      ctermfg=95  ctermbg=52  cterm=NONE
highlight DiffChange     guifg=NONE    guibg=#082433 gui=NONE      ctermfg=NONE ctermbg=235 cterm=NONE
highlight DiffText       guifg=#d0e0e8 guibg=#004f6f gui=bold      ctermfg=188 ctermbg=24  cterm=bold
highlight diffAdded      guifg=#43b35d guibg=NONE    gui=NONE      ctermfg=71  ctermbg=NONE cterm=NONE
highlight diffRemoved    guifg=#7e3636 guibg=NONE    gui=NONE      ctermfg=95  ctermbg=NONE cterm=NONE
highlight diffChanged    guifg=#6abef6 guibg=NONE    gui=NONE      ctermfg=75  ctermbg=NONE cterm=NONE

" Syntax
highlight Comment        guifg=#5b6266 guibg=NONE    gui=NONE      ctermfg=59  ctermbg=NONE cterm=NONE
highlight Constant       guifg=#b0c8d8 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight String         guifg=#7ec5e4 guibg=NONE    gui=NONE      ctermfg=117 ctermbg=NONE cterm=NONE
highlight Character      guifg=#b0c8d8 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Number         guifg=#a3cae0 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Boolean        guifg=#b0c8d8 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Float          guifg=#a3cae0 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Identifier     guifg=#e6f1f6 guibg=NONE    gui=NONE      ctermfg=255 ctermbg=NONE cterm=NONE
highlight Function       guifg=#71c7eb guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Statement      guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Conditional    guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Repeat         guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Label          guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Operator       guifg=#92a4ae guibg=NONE    gui=NONE      ctermfg=109 ctermbg=NONE cterm=NONE
highlight Keyword        guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Exception      guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight PreProc        guifg=#a1cae1 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Include        guifg=#a1cae1 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Define         guifg=#a1cae1 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Macro          guifg=#a1cae1 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight PreCondit      guifg=#a1cae1 guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Type           guifg=#abbfce guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight StorageClass   guifg=#67c5ed guibg=NONE    gui=NONE      ctermfg=81  ctermbg=NONE cterm=NONE
highlight Structure      guifg=#abbfce guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Typedef        guifg=#abbfce guibg=NONE    gui=NONE      ctermfg=152 ctermbg=NONE cterm=NONE
highlight Special        guifg=#93bdea guibg=NONE    gui=NONE      ctermfg=111 ctermbg=NONE cterm=NONE
highlight SpecialChar    guifg=#93bdea guibg=NONE    gui=NONE      ctermfg=111 ctermbg=NONE cterm=NONE
highlight Tag            guifg=#93bdea guibg=NONE    gui=NONE      ctermfg=111 ctermbg=NONE cterm=NONE
highlight Delimiter      guifg=#5c7688 guibg=NONE    gui=NONE      ctermfg=66  ctermbg=NONE cterm=NONE
highlight SpecialComment guifg=#5b6266 guibg=NONE    gui=NONE      ctermfg=59  ctermbg=NONE cterm=NONE
highlight Debug          guifg=#ea5353 guibg=NONE    gui=NONE      ctermfg=203 ctermbg=NONE cterm=NONE
highlight Underlined     guifg=#46afff guibg=NONE    gui=underline ctermfg=75  ctermbg=NONE cterm=underline
highlight Ignore         guifg=#395466 guibg=NONE    gui=NONE      ctermfg=240 ctermbg=NONE cterm=NONE
highlight Error          guifg=#a57575 guibg=NONE    gui=bold      ctermfg=138 ctermbg=NONE cterm=bold
highlight Todo           guifg=#000000 guibg=#eccc3e gui=bold      ctermfg=0   ctermbg=220 cterm=bold

" Spell checking
highlight SpellBad       guisp=#ea5353 gui=undercurl cterm=underline
highlight SpellCap       guisp=#77def3 gui=undercurl cterm=underline
highlight SpellRare      guisp=#8f5c9b gui=undercurl cterm=underline
highlight SpellLocal     guisp=#56c5c5 gui=undercurl cterm=underline

" Common language groups
highlight htmlTag        guifg=#5c7688 guibg=NONE gui=NONE ctermfg=66  ctermbg=NONE cterm=NONE
highlight htmlEndTag     guifg=#5c7688 guibg=NONE gui=NONE ctermfg=66  ctermbg=NONE cterm=NONE
highlight htmlTagName    guifg=#93bdea guibg=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight htmlArg        guifg=#477d96 guibg=NONE gui=NONE ctermfg=67  ctermbg=NONE cterm=NONE
highlight cssProp        guifg=#d3e6ef guibg=NONE gui=NONE ctermfg=195 ctermbg=NONE cterm=NONE
highlight cssAttr        guifg=#a3cae0 guibg=NONE gui=NONE ctermfg=152 ctermbg=NONE cterm=NONE
highlight markdownH1     guifg=#46afff guibg=NONE gui=bold ctermfg=75 ctermbg=NONE cterm=bold
highlight! link markdownH2 markdownH1
highlight! link markdownH3 markdownH1
highlight! link markdownH4 markdownH1
highlight! link markdownH5 markdownH1
highlight! link markdownH6 markdownH1
highlight markdownBold   guifg=#9aa8b0 guibg=NONE gui=bold ctermfg=145 ctermbg=NONE cterm=bold
highlight markdownItalic guifg=#a0b4c0 guibg=NONE gui=italic ctermfg=146 ctermbg=NONE cterm=italic

" Bundled plugins
highlight NERDTreeDir          guifg=#6abef6 guibg=NONE    gui=NONE ctermfg=75  ctermbg=NONE cterm=NONE
highlight NERDTreeDirSlash     guifg=#395466 guibg=NONE    gui=NONE ctermfg=240 ctermbg=NONE cterm=NONE
highlight NERDTreeOpenable     guifg=#93bdea guibg=NONE    gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight NERDTreeClosable     guifg=#93bdea guibg=NONE    gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight NERDTreeFile         guifg=#b6c5d1 guibg=NONE    gui=NONE ctermfg=152 ctermbg=NONE cterm=NONE
highlight NERDTreeExecFile     guifg=#43b35d guibg=NONE    gui=NONE ctermfg=71  ctermbg=NONE cterm=NONE
highlight NERDTreeCWD          guifg=#77def3 guibg=NONE    gui=bold ctermfg=117 ctermbg=NONE cterm=bold
highlight NERDTreeCursorFile   guifg=#000000 guibg=#00a2cf gui=NONE ctermfg=0   ctermbg=38   cterm=NONE
highlight NERDTreeGitIgnored   guifg=#535f67 guibg=NONE    gui=NONE ctermfg=59  ctermbg=NONE cterm=NONE
highlight SignifySignAdd       guifg=#1bc74c guibg=#000000 gui=NONE ctermfg=41  ctermbg=0    cterm=NONE
highlight SignifySignChange    guifg=#0c9bdd guibg=#000000 gui=NONE ctermfg=38  ctermbg=0    cterm=NONE
highlight SignifySignDelete    guifg=#7e3636 guibg=#000000 gui=NONE ctermfg=95  ctermbg=0    cterm=NONE
highlight! link SignifySignChangeDelete SignifySignChange
highlight! link SignifySignDeleteFirstLine SignifySignDelete
highlight! link SignifyLineAdd DiffAdd
highlight! link SignifyLineChange DiffChange
highlight! link SignifyLineDelete DiffDelete
highlight! link SignifyLineDeleteFirstLine DiffDelete

" Built-in terminal palette
let g:terminal_ansi_colors = [
	\ '#000000', '#b25757', '#3b9267', '#e6df7e',
	\ '#588db6', '#8f5c9b', '#56c5c5', '#b0c4d0',
	\ '#395466', '#ea5353', '#43b35d', '#eccc3e',
	\ '#6abef6', '#a575b0', '#77def3', '#ffffff'
	\ ]
