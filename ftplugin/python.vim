if filereadable("makefile") || filereadable("Makefile") | finish | endif

let s:cmd = []
let s:efm = []

if executable("pyright")
  call add(s:cmd, "pyright $*")
  call add(s:efm, "%f:%l:%c - %m")
endif

if executable("ruff")
  call add(s:cmd, "ruff check --output-format concise --exclude '.*' $*")
  call add(s:cmd, "ruff format --check --exclude '.*' $*")
  call add(s:efm, "%f:%l:%c: %m")
  call add(s:efm, "%+G%f:cell %m") " for ipynb
  call add(s:efm, "%+GWould reformat: %f")
endif

if !empty(s:cmd)
  let &l:makeprg = "{ set -x; " .. join(s:cmd, "; ") .. "; }"
  let &l:errorformat = join(s:efm, ",")
endif

unlet s:cmd s:efm
