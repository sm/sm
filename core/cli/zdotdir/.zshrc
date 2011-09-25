[[ -s ~/.zshrc ]] && source ~/.zshrc || true

source ${sm_path}/core/sm/shell/core/initialize
__sm.includes include api/vcs

fail() { backtrace "$*" no_exit ; return 0 ; }
error() { printf "\nERROR: $*\n" >&2 ; return 0 ; }
exit() { builtin exit 0 ; }

TRAPZERR()
{
  backtrace "A command has returned error code ($?) without being handled." no_exit
  return 0
}

typeset -gx PS1
PS1='(sm) [ret=%?] %d > '
