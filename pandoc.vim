let s:include =<< trim END
    <style>
    html, body { background-color: floralwhite }
    body { margin: 1em 2em; }
    h1 { border-bottom: 1px solid silver; }
    h2 { border-bottom: 1px solid silver; }
    table {
      border-collapse: collapse;
      background-color: linen;
    }
    thead {
      background-color: antiquewhite;
      border-top: 1px solid gray;
      border-bottom: 1px solid gray;
    }
    tr:last-child { border-bottom: 1px solid gray; }
    th, td { padding: 0.2em 1em; }
    td {
      border-right: 1px dashed silver;
      border-left: 1px dashed silver;
    }
    td:first-child { border-left: none; }
    td:last-child { border-right: none; }
    </style>
END

aug pandoc
  au! filetype markdown let &l:makeprg="pandoc -s -t html -f gfm --katex -M document-css=false "
        \ .. "-V header-includes='" .. s:include->join("") .. "' % -o %:r.html"
aug end

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
