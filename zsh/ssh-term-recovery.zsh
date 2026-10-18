# Recover the terminal after an SSH session dies abruptly.
#
# A remote TUI (opencode, nvim, htop) switches the local terminal to the
# alternate screen and enables mouse / application-cursor / bracketed-paste
# modes via escape sequences. If the SSH connection drops (closed laptop, dead
# wifi) those sequences are never sent back, and OpenSSH only restores termios
# on exit, not these modes. The terminal is left in the alternate screen with
# the modes still on, which is why control/arrow keys misbehave until you run
# `tput reset; tput rmcup`.
#
# Wrapping ssh lets us re-arm a sane terminal the moment it returns, for any
# exit reason. The sequences are idempotent, so this is invisible after a clean
# exit and only fixes things when they were actually left broken.
ssh() {
  command ssh "$@"
  local ret=$?

  # Only touch the terminal when attached to a real tty.
  [[ -t 1 ]] || return $ret

  printf '\e[?1049l'   # leave the alternate screen buffer (== tput rmcup)
  printf '\e[?1000l'   # X11 mouse tracking off
  printf '\e[?1002l'   # button-event mouse tracking off
  printf '\e[?1003l'   # any-event mouse tracking off
  printf '\e[?1006l'   # SGR extended mouse coords off
  printf '\e[?2004l'   # bracketed paste off
  printf '\e[?1l'      # application cursor keys off
  printf '\e[?7h'      # re-enable line wrap (some TUIs leave it off)
  printf '\e[0m'       # reset colors / attributes

  return $ret
}

# Belt-and-suspenders: also re-assert sane modes on every prompt. This catches
# a stuck terminal even when the drop happened outside a wrapped ssh call (e.g.
# a crashed local TUI). At a prompt you are never legitimately in the alternate
# screen, and zle re-enables bracketed paste after precmd, so this is a no-op
# unless something left a mode on.
# autoload -Uz add-zsh-hook
# function _ssh_term_recovery_precmd() {
#   printf '\e[?1049l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?2004l\e[?1l'
# }
# add-zsh-hook precmd _ssh_term_recovery_precmd
