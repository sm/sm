# Variables

## Colors

- `sm_use_colors`  - `0`/`1` specifies if colors should be used
- `sm_color_red`   - code for `red` if colors enabled
- `sm_color_green` - code for `green` if colors enabled
- `sm_color_reset` - code for resetting color if colors enabled

## Steps

- `log_step_succ_char`  - character to display on success `V`/`✔`
- `log_step_fail_char`  - character to display on failure `X`/`✘`
- `log_step_empty_char` - character to display on start of step, usually a space

# Streams

- `5` - saved colored stdout
- `6` - saved colored stderr
- `7` - saved default stdout
- `8` - saved default stderr
- `9` - saved default stdin

Streams `3` and `4` are left for extensions.
Streams `1` and `2` are colored if colors should be used.
To force colored/default stdout/stderr use streams `5`-`8`.
To force default stdin use stream `9`.

# Functions

## __sm.log.step.tree

Run a command and display it's status, build tree if nested in functions.

    __sm.log.step.tree "{message}" {command} ...

- `{message}` - Text to display
- `{command}` - Command to run
- returns return status of the `{command}`
