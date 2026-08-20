" Keep the gitignored status marker available for matching, but do not render it.
if has('conceal')
	syntax match NERDTreeGitIgnoredMarker '\[!\]' conceal containedin=NERDTreeFlags
	setlocal conceallevel=3 concealcursor=nvic
endif
