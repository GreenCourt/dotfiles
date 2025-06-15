com -nargs=1 -complete=file -bang CsvPretty call s:csv_pretty("<mods>", "<bang>", "<args>")

func s:csv_pretty(mods, bang, path) abort
  if !filereadable(a:path)
    echohl ErrorMsg | echo "Not a readable file." | echohl None
    return
  endif

  if getfsize(a:path) > 10 * 1024 * 1024
    echohl ErrorMsg | echo "Too large file." | echohl None
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

  " To detect file encoding using &fileencodings of vim,
  " load the file into the vim buffer.
  silent execute "r " .. a:path
  1delete
  silent execute "%!pandoc -f csv -t plain"
  call append(0, a:path) " put filename on top

  let &l:undolevels = undolevels
  call cursor(1, 1)
endfunc
