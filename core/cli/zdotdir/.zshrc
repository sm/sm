[[ -s ~/.zshrc ]] && source ~/.zshrc || true

source ${sm_path}/core/sm/shell/core/initialize
__sm.includes include api/vcs

__sm.log.fail() { __sm.log.fail.no_exit "$@" ; return 0 ; }
__sm.log.errro() { __sm.log.errro.no_exit "$@" ; return 0 ; }
exit() { builtin exit 0 ; }

set -o  NO_ERR_EXIT ERR_RETURN

trap "backtrace \"A command has returned error code (\$?) without being handled.\" no_exit" ZERR

typeset -gx PS1
PS1='(sm) [ret=%?] %d > '
