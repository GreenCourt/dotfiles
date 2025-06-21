if !executable("ruff") | finish | endif

command -buffer -nargs=0 RuffFormatBuffer call s:fmt("ruff format -n - --stdin-filename " .. expand("%"))

func! s:search_up(targets) abort
  let sep = (!exists('+shellslash') || &shellslash) ? "/" : "\\"
  let cur = getcwd()
  while cur->fnamemodify(":h") != cur
    for t in a:targets
      if filereadable(cur .. sep .. t)
        return cur .. sep .. t
      endif
    endfor
    let cur = cur->fnamemodify(":h")
  endwhile
  return ""
endfunc

if empty(s:search_up([".ruff.toml", "ruff.toml"]))
  finish
endif

aug ruff
  au! bufwritepre <buffer> call s:fmt("ruff format -n - --stdin-filename " .. expand("<afile>"))
aug end

func! s:fmt(cmd) abort
  let buf = getline(1, "$")
  let out = systemlist(a:cmd, buf->join("\n"))

  if v:shell_error != 0 | return | endif
  if buf == out | return | endif

  defer winrestview(winsaveview())
  if line("$") > len(out)
    silent! execute (len(out)-1) .. ",$delete"
  endif
  call setline("1", out)
endfunc
    
