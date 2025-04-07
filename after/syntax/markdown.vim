let s:current_syntax = b:current_syntax | unlet b:current_syntax
syn include @tex syntax/tex.vim
let b:current_syntax = s:current_syntax | unlet s:current_syntax

syn region MarkdownTeX start="\$" end="\$" skip="\\\$" keepend contains=@tex
syn region MarkdownTeX start="\$\$" end="\$\$" keepend contains=@tex
syn region MarkdownTeX start="\V\\begin{\z(\.\*\)}" end="\V\\end{\z1}" keepend
