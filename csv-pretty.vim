com -nargs=1 -complete=file -bang CsvPretty call s:csv_pretty("<mods>", "<bang>", "<args>")

func s:csv_pretty(mods, bang, path) abort
  if !filereadable(a:path)
    echohl ErrorMsg | echo "Not a readable file " .. a:path | echohl None
    return
  endif

  try
    silent execute a:mods .. "enew" .. a:bang
  catch
    echohl ErrorMsg | echo v:exception | echohl None
    return
  endtry

  setl buftype=nofile noswapfile
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
