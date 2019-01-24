# Options

declare-option -hidden str-list yank_ring_history
declare-option -hidden int yank_ring_index
declare-option -hidden int yank_ring_time_stamp 1
declare-option -hidden str yank_ring_last_command
declare-option -docstring 'Maximum number of entries in the Yank Ring' int yank_ring_size 60

# Commands

define-command yank-ring-previous -docstring 'Cycle backward through the Yank Ring' %{
  yank-ring-index %sh(echo $((kak_opt_yank_ring_index + 1)))
}

define-command yank-ring-next -docstring 'Cycle forward through the Yank Ring' %{
  yank-ring-index %sh(echo $((kak_opt_yank_ring_index - 1)))
}

define-command yank-ring-open -docstring 'Open the Yank Ring to copy a previous yank' %{ evaluate-commands %sh{
  eval "set -- $kak_opt_yank_ring_history"
  if test $# -gt 0; then
    printf 'yank-ring-open-\n'
  else
    printf 'fail Yank Ring is empty\n'
  fi
}}

# Hooks

define-command -hidden yank-ring-enable %{
  hook -group yank-ring window NormalKey '[ydc]' %{
    set-option global yank_ring_history "%val(reg_dquote)" %opt(yank_ring_history)
    yank-ring-self-update
  }
  hook -group yank-ring window NormalKey 'p|P|<a-p>|<a-P>|R|<a-R>' %{
    set-option window yank_ring_index 0
    set-option window yank_ring_last_command %val(hook_param)
    set-option window yank_ring_time_stamp %val(timestamp)
  }
}

# Implementation

# Cycle through the Yank Ring
define-command -hidden yank-ring-index -params 1 %{
  yank-ring-index- %arg(1) %opt(yank_ring_history)
}

define-command -hidden yank-ring-index- -params .. %{ evaluate-commands %sh{
  index=$1
  shift
  # Rest arguments are yank registers
  # Rest = $@
  # Guards
  if test $kak_opt_yank_ring_time_stamp != $kak_timestamp; then
    printf 'fail Yank Ring: Paste’s time-stamp out-of-date\n'
    exit
  fi
  if test -z "$kak_opt_yank_ring_last_command"; then
    printf 'fail Yank Ring: No previous paste\n'
    exit
  fi
  # Functions
  modulo() {
    dividend=$1
    divisor=$2
    printf $((((dividend % divisor) + divisor) % divisor))
  }
  # Replace selections according the previous paste command
  case $kak_opt_yank_ring_last_command in
    'p'|'P'|'R') command='R' ;;
    '<a-p>'|'<a-P>'|'<a-R>') command='<a-R>' ;;
  esac
  # Get corresponding register index from the Yank Ring
  index=$(modulo $index $#)
  # (index) + (one-based-numbering) + (skip-index-parameter)
  argument=$((index + 1 + 1))
  printf '
    set-option window yank_ring_index %d
    evaluate-commands -save-regs %%(") %%{
      evaluate-commands set-register dquote %%arg(%d)
      execute-keys uU%s
    }
    set-option window yank_ring_time_stamp %%val(timestamp)
  ' $index $argument $command
  if test $index = 0; then
    printf '
      echo -markup {Information} Yank Ring wrapped around itself
    '
  fi
}}

# Open the Yank Ring to copy a previous yank
define-command -hidden yank-ring-open- %{
  select- %opt(yank_ring_history) %{
    evaluate-commands set-register dquote %arg(1)
  }
  execute-keys '<tab>'
}

# Update Yank Ring history
define-command -hidden yank-ring-self-update %{
  yank-ring-self-update- %opt(yank_ring_history)
}

define-command -hidden yank-ring-self-update- -params .. %{ evaluate-commands %sh{
  if test $# -gt $kak_opt_yank_ring_size; then
    printf 'set-option global yank_ring_history\n'
    length=$#
    index=$((length - kak_opt_yank_ring_size + 1))
    while test $index -le $length; do
      printf 'set-option -add global yank_ring_history %%arg(%d)\n' $index
      index=$((index + 1))
    done
  fi
}}

# Run

hook -group yank-ring global WinCreate .* %{
  yank-ring-enable
}
