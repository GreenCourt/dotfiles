if !executable("ruff") | finish | endif

aug ruff
  au! bufwritepost <buffer> call s:ruff_check()
  au! bufwritepre <buffer> call s:fmt("ruff format -n -")
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
        \ ["ruff", "check", "-n", "-q",
        \  "--extension", "ipynb:python",
        \  "--config", "output-format='concise'",
        \  "-", "--stdin-filename", expand("<afile>")],
        \ #{
        \   in_io : "buffer",
        \   in_buf : str2nr(expand("<abuf>")),
        \   err_io : "out",
        \   out_mode : "nl",
        \   out_cb : {ch, msg -> setloclist(l:winnr, [], "a", #{ lines : [msg], efm: "%f:%l:%c: %m" }) },
        \   exit_cb : {job, status -> execute("echow status ? 'ruff:' .. status : ''", "") },
        \ })
endfunc
