
set background=light

hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "pyte"

if version >= 700
  hi CursorLine guibg=#f6f6f6 gui=NONE
  hi CursorColumn guibg=#eaeaea gui=NONE
  hi MatchParen guifg=white guibg=#80a090 gui=NONE

  "Tabpages
  hi TabLine guifg=black guibg=#b0b8c0 gui=NONE
  hi TabLineFill guifg=#9098a0 gui=NONE
  hi TabLineSel guifg=black guibg=#f0f0f0 gui=NONE

  "P-Menu (auto-completion)
  hi Pmenu guifg=white guibg=#808080 gui=NONE
  "PmenuSel
  "PmenuSbar
  "PmenuThumb
endif
"
" Html-Titles
hi Title      guifg=#202020 gui=NONE
hi Underlined  guifg=#202020 gui=underline


hi Cursor    guifg=black   guibg=#b0b4b8 gui=NONE
hi lCursor   guifg=black   guibg=white gui=NONE
hi LineNr    guifg=#ffffff guibg=#c0d0e0 gui=NONE

hi Normal    guifg=#404850   guibg=#f0f0f0 gui=NONE

hi StatusLine guifg=white guibg=#8090a0 gui=NONE
hi StatusLineNC guifg=#506070 guibg=#a0b0c0 gui=NONE
hi VertSplit guifg=#a0b0c0 guibg=#a0b0c0 gui=NONE

" hi Folded    guifg=#708090 guibg=#c0d0e0 gui=NONE
hi Folded    guifg=#a0a0a0 guibg=#e8e8e8 gui=NONE

hi NonText   guifg=#c0c0c0 guibg=#e0e0e0 gui=NONE
" Kommentare
hi Comment   guifg=#a0b0c0 gui=NONE

" Konstanten
hi Constant  guifg=#a07040 gui=NONE
hi String    guifg=#4070a0  gui=NONE
hi Number    guifg=#40a070 gui=NONE
hi Float     guifg=#70a040 gui=NONE
"hi Statement guifg=#0070e0 gui=NONE
" Python: def and so on, html: tag-names
hi Statement  guifg=#007020 gui=NONE


" HTML: arguments
hi Type       guifg=#e5a00d gui=NONE
" Python: Standard exceptions, True&False
hi Structure  guifg=#007020 gui=NONE
hi Function   guifg=#06287e gui=NONE

hi Identifier guifg=#5b3674 gui=NONE

hi Repeat      guifg=#7fbf58 gui=NONE
hi Conditional guifg=#4c8f2f gui=NONE

" Cheetah: #-Symbol, function-names
hi PreProc    guifg=#1060a0 gui=NONE
" Cheetah: def, for and so on, Python: Decorators
hi Define      guifg=#1060a0 gui=NONE

hi Error      guifg=red guibg=white gui=underline
hi Todo       guifg=#a0b0c0 guibg=NONE gui=underline

" Python: %(...)s - constructs, encoding
hi Special    guifg=#70a0d0 gui=NONE

hi Operator   guifg=#408010 gui=NONE

" color of <TAB>s etc...  
"hi SpecialKey guifg=#d8a080 guibg=#e8e8e8 gui=NONE
hi SpecialKey guifg=#d0b0b0 guibg=#f0f0f0 gui=none

" Diff
hi DiffChange guifg=NONE guibg=#e0e0e0 gui=NONE
hi DiffText guifg=NONE guibg=#f0c8c8 gui=NONE
hi DiffAdd guifg=NONE guibg=#c0e0d0 gui=NONE
hi DiffDelete guifg=NONE guibg=#f0e0b0 gui=NONE


