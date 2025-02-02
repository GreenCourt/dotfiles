syntax match MathJax '\$[^$].\{-}\$'
syntax region MathJax start=/\$\$/ end=/\$\$/
syntax region MathJax start="\V\\begin{\z(\.\*\)}" end="\V\\end{\z1}" keepend
hi def link MathJax Statement
