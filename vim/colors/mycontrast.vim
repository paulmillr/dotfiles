" Vim color file - mycontrast
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

"set t_Co=256
let g:colors_name = "mycontrast"

hi IncSearch guifg=#030303 guibg=#d7d700 guisp=#d7d700 gui=NONE ctermfg=NONE ctermbg=184 cterm=NONE
hi WildMenu guifg=#2ac722 guibg=NONE guisp=NONE gui=NONE ctermfg=40 ctermbg=NONE cterm=NONE
"hi SignColumn -- no settings --
hi SpecialComment guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Typedef guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
"hi Title -- no settings --
hi Folded guifg=#af5f87 guibg=NONE guisp=NONE gui=NONE ctermfg=132 ctermbg=NONE cterm=NONE
hi PreCondit guifg=#ffd75f guibg=NONE guisp=NONE gui=NONE ctermfg=221 ctermbg=NONE cterm=NONE
hi Include guifg=#ffd75f guibg=NONE guisp=NONE gui=NONE ctermfg=221 ctermbg=NONE cterm=NONE
hi Float guifg=#e6af09 guibg=NONE guisp=NONE gui=NONE ctermfg=178 ctermbg=NONE cterm=NONE
hi StatusLineNC guifg=#a8a8a8 guibg=#4e4e4e guisp=#4e4e4e gui=NONE ctermfg=248 ctermbg=239 cterm=NONE
hi CTagsMember guifg=#fcfcfc guibg=#4d00f2 guisp=#4d00f2 gui=NONE ctermfg=15 ctermbg=57 cterm=NONE
hi NonText guifg=#8a8885 guibg=NONE guisp=NONE gui=NONE ctermfg=245 ctermbg=NONE cterm=NONE
"hi CTagsGlobalConstant -- no settings --
hi DiffText guifg=#610627 guibg=#808080 guisp=#808080 gui=NONE ctermfg=52 ctermbg=8 cterm=NONE
hi ErrorMsg guifg=NONE guibg=#ff0000 guisp=#ff0000 gui=bold ctermfg=NONE ctermbg=196 cterm=bold
hi Ignore guifg=#ffd75f guibg=NONE guisp=NONE gui=NONE ctermfg=221 ctermbg=NONE cterm=NONE
hi Debug guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi PMenuSbar guifg=#9e9e9e guibg=#121212 guisp=#121212 gui=NONE ctermfg=247 ctermbg=233 cterm=NONE
hi Identifier guifg=#afaf00 guibg=NONE guisp=NONE gui=NONE ctermfg=142 ctermbg=NONE cterm=NONE
hi SpecialChar guifg=#d78800 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Conditional guifg=#d76100 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi StorageClass guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Todo guifg=#ffffff guibg=#fa0505 guisp=#fa0505 gui=NONE ctermfg=15 ctermbg=196 cterm=NONE
hi Special guifg=#d78800 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi LineNr guifg=#ffffff guibg=#2e2e2e guisp=#2e2e2e gui=bold ctermfg=15 ctermbg=236 cterm=bold
hi StatusLine guifg=#f7ff00 guibg=#333233 guisp=#333233 gui=bold ctermfg=11 ctermbg=236 cterm=bold
hi Normal guifg=#dadada guibg=#000000 guisp=#000000 gui=NONE ctermfg=253 ctermbg=232 cterm=NONE
hi Label guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
"hi CTagsImport -- no settings --
hi PMenuSel guifg=#fff761 guibg=#4d4b4d guisp=#4d4b4d gui=NONE ctermfg=227 ctermbg=239 cterm=NONE
hi Search guifg=#0a0a0a guibg=#d7d700 guisp=#d7d700 gui=NONE ctermfg=232 ctermbg=184 cterm=NONE
"hi CTagsGlobalVariable -- no settings --
hi Delimiter guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Statement guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi SpellRare  guifg=#f7f7f7 guibg=#bd1b1b guisp=NONE gui=NONE ctermfg=white ctermbg=88 cterm=NONE
"hi EnumerationValue -- no settings --
hi Comment guifg=#bc4ee0 guibg=NONE guisp=NONE gui=NONE ctermfg=134 ctermbg=NONE cterm=NONE
hi Character guifg=#61d700 guibg=NONE guisp=NONE gui=NONE ctermfg=76 ctermbg=NONE cterm=NONE
hi TabLineSel guifg=#8787d7 guibg=#303030 guisp=#303030 gui=NONE ctermfg=104 ctermbg=236 cterm=NONE
hi Number guifg=#e6af09 guibg=NONE guisp=NONE gui=NONE ctermfg=178 ctermbg=NONE cterm=NONE
hi Boolean guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Operator guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi CursorLine guifg=NONE guibg=#2e2e2e guisp=#2e2e2e gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
"hi Union -- no settings --
hi TabLineFill guifg=#4e4e4e guibg=#4e4e4e guisp=#4e4e4e gui=NONE ctermfg=239 ctermbg=239 cterm=NONE
"hi Question -- no settings --
"hi WarningMsg -- no settings --
"hi VisualNOS -- no settings --
hi DiffDelete guifg=NONE guibg=#61121f guisp=#61121f gui=NONE ctermfg=NONE ctermbg=52 cterm=NONE
"hi ModeMsg -- no settings --
hi CursorColumn guifg=NONE guibg=#2e2e2e guisp=#2e2e2e gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
hi Define guifg=#d78800 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Function guifg=#cccc0a guibg=NONE guisp=NONE gui=NONE ctermfg=184 ctermbg=NONE cterm=NONE
hi FoldColumn guifg=#af5f87 guibg=NONE guisp=NONE gui=NONE ctermfg=132 ctermbg=NONE cterm=NONE
hi PreProc guifg=#ffd75f guibg=NONE guisp=NONE gui=NONE ctermfg=221 ctermbg=NONE cterm=NONE
"hi EnumerationName -- no settings --
hi Visual guifg=#a8a8a8 guibg=#444444 guisp=#444444 gui=NONE ctermfg=248 ctermbg=238 cterm=NONE
"hi MoreMsg -- no settings --
hi SpellCap  guifg=#f7f7f7 guibg=#bd1b1b guisp=NONE gui=NONE ctermfg=white ctermbg=88 cterm=NONE
hi VertSplit guifg=#f7ff00 guibg=#4e4e4e guisp=#4e4e4e gui=NONE ctermfg=11 ctermbg=239 cterm=NONE
hi Exception guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Keyword guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Type guifg=#d76100 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi DiffChange guifg=#dadada guibg=#101957 guisp=#101957 gui=NONE ctermfg=253 ctermbg=17 cterm=NONE
hi Cursor guifg=#000000 guibg=#ffffff guisp=#ffffff gui=NONE ctermfg=NONE ctermbg=15 cterm=NONE
hi SpellLocal  guifg=#f7f7f7 guibg=#bd1b1b guisp=NONE gui=NONE ctermfg=white ctermbg=88 cterm=NONE
hi Error guifg=#ff0000 guibg=NONE guisp=NONE gui=NONE ctermfg=196 ctermbg=NONE cterm=NONE
hi PMenu guifg=#a8a818 guibg=#333333 guisp=#333333 gui=NONE ctermfg=142 ctermbg=236 cterm=NONE
hi SpecialKey guifg=#5faf00 guibg=NONE guisp=NONE gui=NONE ctermfg=70 ctermbg=NONE cterm=NONE
hi Constant guifg=#5fd700 guibg=NONE guisp=NONE gui=NONE ctermfg=76 ctermbg=NONE cterm=NONE
hi DefinedName guifg=#d76100 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Tag guifg=#d78700 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi String guifg=#61d700 guibg=NONE guisp=NONE gui=NONE ctermfg=76 ctermbg=NONE cterm=NONE
hi PMenuThumb guifg=#a8a8a8 guibg=#121212 guisp=#121212 gui=NONE ctermfg=248 ctermbg=233 cterm=NONE
hi MatchParen guifg=#cc8710 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi LocalVariable guifg=#8787d7 guibg=NONE guisp=NONE gui=NONE ctermfg=104 ctermbg=NONE cterm=NONE
hi Repeat guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi SpellBad  guifg=#f7f7f7 guibg=#bd1b1b guisp=NONE gui=NONE ctermfg=white ctermbg=88 cterm=NONE
"hi CTagsClass -- no settings --
hi Directory guifg=#d76100 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Structure guifg=#d75f00 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi Macro guifg=#d78800 guibg=NONE guisp=NONE gui=NONE ctermfg=172 ctermbg=NONE cterm=NONE
hi Underlined guifg=#129be0 guibg=NONE guisp=NONE gui=NONE ctermfg=32 ctermbg=NONE cterm=NONE
hi DiffAdd guifg=NONE guibg=#156926 guisp=#156926 gui=NONE ctermfg=NONE ctermbg=22 cterm=NONE
hi TabLine guifg=#8a8a8a guibg=#4e4e4e guisp=#4e4e4e gui=NONE ctermfg=245 ctermbg=239 cterm=NONE
hi mbenormal guifg=#cfbfad guibg=#2e2e3f guisp=#2e2e3f gui=NONE ctermfg=187 ctermbg=237 cterm=NONE
hi perlspecialstring guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE ctermfg=176 ctermbg=238 cterm=NONE
hi doxygenspecial guifg=#fdd090 guibg=NONE guisp=NONE gui=NONE ctermfg=222 ctermbg=NONE cterm=NONE
hi underline guifg=#afafff guibg=NONE guisp=NONE gui=NONE ctermfg=147 ctermbg=NONE cterm=NONE
hi mbechanged guifg=#eeeeee guibg=#2e2e3f guisp=#2e2e3f gui=NONE ctermfg=255 ctermbg=237 cterm=NONE
hi mbevisiblechanged guifg=#eeeeee guibg=#4e4e8f guisp=#4e4e8f gui=NONE ctermfg=255 ctermbg=60 cterm=NONE
hi doxygenparam guifg=#fdd090 guibg=NONE guisp=NONE gui=NONE ctermfg=222 ctermbg=NONE cterm=NONE
hi doxygensmallspecial guifg=#fdd090 guibg=NONE guisp=NONE gui=NONE ctermfg=222 ctermbg=NONE cterm=NONE
hi doxygencomment guifg=#ad7b20 guibg=NONE guisp=NONE gui=NONE ctermfg=130 ctermbg=NONE cterm=NONE
hi doxygenprev guifg=#fdd090 guibg=NONE guisp=NONE gui=NONE ctermfg=222 ctermbg=NONE cterm=NONE
hi perlspecialmatch guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE ctermfg=176 ctermbg=238 cterm=NONE
hi cformat guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE ctermfg=176 ctermbg=238 cterm=NONE
hi lcursor guifg=#404040 guibg=#8fff8b guisp=#8fff8b gui=NONE ctermfg=238 ctermbg=120 cterm=NONE
hi cursorim guifg=#404040 guibg=#8b8bff guisp=#8b8bff gui=NONE ctermfg=238 ctermbg=105 cterm=NONE
hi user2 guifg=#7070a0 guibg=#3e3e5e guisp=#3e3e5e gui=NONE ctermfg=103 ctermbg=60 cterm=NONE
hi doxygenspecialmultilinedesc guifg=#ad600b guibg=NONE guisp=NONE gui=NONE ctermfg=130 ctermbg=NONE cterm=NONE
hi taglisttagname guifg=#808bed guibg=NONE guisp=NONE gui=NONE ctermfg=105 ctermbg=NONE cterm=NONE
hi doxygenbrief guifg=#fdab60 guibg=NONE guisp=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
hi mbevisiblenormal guifg=#cfcfcd guibg=#4e4e8f guisp=#4e4e8f gui=NONE ctermfg=252 ctermbg=60 cterm=NONE
hi user1 guifg=#00ff8b guibg=#3e3e5e guisp=#3e3e5e gui=NONE ctermfg=48 ctermbg=60 cterm=NONE
hi doxygenspecialonelinedesc guifg=#ad600b guibg=NONE guisp=NONE gui=NONE ctermfg=130 ctermbg=NONE cterm=NONE
hi cspecialcharacter guifg=#c080d0 guibg=#404040 guisp=#404040 gui=NONE ctermfg=176 ctermbg=238 cterm=NONE
"hi clear -- no settings --
hi link javascriptRegexpString  String
hi link javascriptNumber Number
hi link javascriptFunction Function
hi link jsFuncCall Function
hi link NERDtreeDir DefinedName
hi link jsBrackets DefinedName
hi link jsFuncBraces DefinedName
hi link jsFuncParens Define
hi link jsParens Define
hi NERDtreeDir guifg=#f7ff00 guibg=#000000 guisp=#4e4e4e gui=NONE ctermfg=11 ctermbg=232 cterm=NONE
hi yamlKey guifg=#f7ff00 guibg=#000000 guisp=#4e4e4e gui=NONE ctermfg=11 ctermbg=232 cterm=NONE
hi link yamlBlockMappingKey yamlKey
hi link javascriptNull Constant
hi link rubySymbol Constant
hi link rubyAttribute Identifier
hi rubyBlockParameter guifg=#8787d7 guibg=NONE guisp=#303030 gui=NONE ctermfg=104 ctermbg=NONE cterm=NONE
hi rubyLocalVariableOrMethod guifg=#8787d7 guibg=NONE guisp=#303030 gui=NONE ctermfg=104 ctermbg=NONE cterm=NONE
hi cssSelectorOp guifg=#8787d7 guibg=NONE guisp=#303030 gui=NONE ctermfg=104 ctermbg=NONE cterm=NONE
hi link rubyInclude Include
hi link javaScopeDecl Identifier
hi link sqlStatement Define
hi link sqlKeyword Identifier
hi link sqlOperator DefinedName
hi link sqlSpecial Identifier
hi link sqlType Identifier
hi link htmlTagN htmlTag
hi link htmlDoctype htmlTag