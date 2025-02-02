syn match HyperLink "\w\+:\/\/[^[:space:]]\+" contains=@NoSpell
syn match ModeLine "^\(vim\|vi\|ex\):.*\%$" contains=@NoSpell
syn match ModeLine "\%^\(vim\|vi\|ex\):.*$" contains=@NoSpell
hi def link HyperLink Statement
