aug markdown-math-syntax
  au! filetype markdown call s:markdown_math_syntax()
aug END

func s:markdown_math_syntax()
  " This function is intended to be called
  " after loading $VIMRUNTIME/syntax/markdown.vim
  let l:current_syntax = b:current_syntax | unlet b:current_syntax
  syn include @tex syntax/tex.vim
  let b:current_syntax = l:current_syntax | unlet l:current_syntax

  syn region MarkdownTeX start="\$" end="\$" skip="\\\$" keepend contains=@tex
  syn region MarkdownTeX start="\$\$" end="\$\$" keepend contains=@tex
  syn region MarkdownTeX start="\V\\begin{\z(\.\*\)}" end="\V\\end{\z1}" keepend contains=@tex
endfunc
