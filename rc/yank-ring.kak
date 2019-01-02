declare-option -hidden str-list yank_ring
declare-option -docstring 'Maximum number of entries in the Yank Ring' int yank_ring_size 60

define-command yank-ring -docstring 'Open the Yank Ring to copy a previous yank' %{ evaluate-commands %sh{
  eval "set -- $kak_opt_yank_ring"
  if test $# -gt 0; then
    printf 'yank-ring-\n'
  else
    printf 'fail Yank Ring is empty\n'
  fi
}}

define-command -hidden yank-ring- %{
  select- %opt(yank_ring) %{
    evaluate-commands set-register dquote %arg(1)
  }
  execute-keys '<tab>'
}

define-command -hidden yank-ring-enable %{
  hook -group yank-ring window NormalKey '[ydc]' %{
    set-option -add global yank_ring "%val(reg_dquote)"
    yank-ring-self-update
  }
}

define-command -hidden yank-ring-self-update %{
  yank-ring-self-update- %opt(yank_ring)
}

define-command -hidden yank-ring-self-update- -params .. %{ evaluate-commands %sh{
  if test $# -gt $kak_opt_yank_ring_size; then
    printf 'set-option global yank_ring\n'
    length=$#
    index=$((length - kak_opt_yank_ring_size + 1))
    while test $index -le $length; do
      printf 'set-option -add global yank_ring %%arg(%d)\n' $index
      index=$((index + 1))
    done
  fi
}}

hook -group yank-ring global WinCreate .* %{
  yank-ring-enable
}
