#!/bin/bash
cd $(git rev-parse --show-toplevel)
git diff --cached --name-only --diff-filter=ACMRT | {
  rc=0
  while read i
  do
    case "$i" in
      *\.[ch])
        clang-format --Werror --dry-run "$i" || rc=1
        ;;
      *\.rs)
        rustfmt --check "$i" || rc=1
        ;;
      *\.py)
        ruff check --no-cache "$i" || rc=1
        ruff format --no-cache --check "$i" || rc=1
        ;;
      *)
        ;;
    esac
  done
  exit $rc
}
