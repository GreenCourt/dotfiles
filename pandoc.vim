"------------ math syntax ------------

aug markdown-math-syntax
  au! filetype markdown call s:markdown_math_syntax()
aug END

func s:markdown_math_syntax() abort
  " This function is intended to be called
  " after loading $VIMRUNTIME/syntax/markdown.vim
  let l:current_syntax = b:current_syntax | unlet b:current_syntax
  syn include @tex syntax/tex.vim
  let b:current_syntax = l:current_syntax | unlet l:current_syntax

  syn region MarkdownTeX start="\%(\\\)\@<!\$" end="\$" skip="\\\$" keepend contains=@tex
  syn region MarkdownTeX start="\$\$" end="\$\$" keepend contains=@tex
  syn region MarkdownTeX start="\V\\begin{\z(\.\*\)}" end="\V\\end{\z1}" keepend contains=@tex
endfunc

"------------ makeprg ------------

let s:include =<< trim END
    <style>
    body { margin: 1em 2em; }
    h1 { border-bottom: 1px solid silver; }
    h2 { border-bottom: 1px solid silver; }
    pre:has(code) { background-color:\#eeeeee; padding:1em; }
    table { border-collapse: collapse; }
    thead { border-bottom: 1px solid gray; }
    th, td { padding: 0.2em 1em; }
    </style>
END

aug pandoc
  au! filetype markdown let &l:makeprg="pandoc -s -t html -f gfm --katex -M document-css=false "
        \ .. "-V header-includes='" .. s:include->join("") .. "' % -o %.html"
aug end

"------------ csv pretty print ------------

com -nargs=1 -complete=file -bang CsvPretty call s:csv_pretty("<mods>", "<bang>", "<args>")

func s:csv_pretty(mods, bang, path) abort
  if !filereadable(a:path)
    echohl ErrorMsg | echo "Not a readable file " .. a:path | echohl None
    return
  endif

  try
    silent execute a:mods .. " new" .. a:bang
  catch
    echohl ErrorMsg | echo v:exception | echohl None
    return
  endtry

  setl buftype=nofile noswapfile nowrap
  let undolevels = &l:undolevels
  setl undolevels=-1

  "
  " Pandoc only accepts UTF-8,
  " so load the file into the vim buffer and pass it to pandoc.
  "
  silent execute "r " .. a:path
  silent 1delete
  silent execute "%!pandoc -f csv -t plain"

  let &l:undolevels = undolevels
endfunc
