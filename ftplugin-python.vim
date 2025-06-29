if !executable("ruff") | finish | endif

command -buffer -nargs=0 RuffFormatBuffer call s:fmt("ruff format -n - --stdin-filename " .. expand("%"))

func s:search_up(start_directory, targets) abort
  let sep = (!exists("+shellslash") || &shellslash) ? "/" : "\\"
  let cur = a:start_directory->fnamemodify(":p")
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

aug ruff
  au! bufwritepost <buffer> call s:ruff_check()
  if !empty(s:search_up(expand("%:p:h"), [".ruff.toml", "ruff.toml"]))
    au! bufwritepre <buffer> call s:fmt("ruff format -n - --stdin-filename " .. expand("<afile>"))
  endif
aug end

func s:fmt(cmd) abort
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

func s:ruff_check() abort
  if exists("b:ruff_job") && job_status(b:ruff_job) == "run"
    call job_setoptions(b:ruff_job, #{out_cb:{ ch, msg -> 0 }, exit_cb: {job, status -> 0 }})
    call job_stop(b:ruff_job)
  endif

  " use winnr() instread of bufwinnr(), because multiple windows maybe tied with the same buffer.
  " save winnr into variable to use in lambda for out_cb.
  let l:winnr = winnr()

  call setloclist(l:winnr, [], "r", #{ title: "ruff", lines:[] })

  let b:ruff_job = job_start(
        \ ["ruff", "check", "-n", "-", "--stdin-filename", expand("<afile>")],
        \ #{
        \   in_io : "buffer",
        \   in_buf : str2nr(expand("<abuf>")),
        \   err_io : "out",
        \   out_mode : "nl",
        \   out_cb : {ch, msg -> setloclist(l:winnr, [], "a", #{ lines : [msg], efm: "%f:%l:%c: %m" }) },
        \   exit_cb : {job, status -> s:notify(status ? "ruff:" .. status : "") },
        \ })
endfunc

func s:notify(message) abort
  if exists("s:popup") && index(popup_list(), s:popup) != -1
    call popup_close(s:popup)
  endif
  if empty(a:message)
    return
  endif
  let s:popup = popup_notification(a:message,
        \ #{ line:&lines , col: &columns - 1 - len(a:message) })
endfunc
