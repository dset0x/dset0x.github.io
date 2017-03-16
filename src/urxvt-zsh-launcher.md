2017-03-13T14:58 urxvt,zsh,launcher
Using urxvt with zsh as a program launcher
=========================================

There's a number of window manager independant program launchers out there, but if you need to run arbitrary commands or want shell completion you might find yourself falling back to spawning a terminal every time. It's easy to create a `dmenu` replacement by adding this to your `~/.zshrc`:

    case "$ACT_AS" in
        floating-terminal)
            PS1=""

            HISTFILE=~/.histfile_float
            accept-line-custom () {
                BUFFER_ORIG="$BUFFER"
                BUFFER="(setsid $SHELL -c \"$BUFFER\" &); exit"
                zle .accept-line
            };
            zle -N accept-line-custom
            bindkey '^M' accept-line-custom

            zshaddhistory() {
                print -sr -- ${BUFFER_ORIG%%$'\n'}
                fc -p
            }

            return
        ;;
    esac

Entering this condition has a number of effects:

* The shell (and controlling terminal) to exit after the first command
* The command is wrapped in `(setsid $SHELL -c "` ... `" &)` so that it
  doesn't die with the shell and that any shell built-ins are allowed.
* The unmodified command is stored in a secondary `HISTFILE` so that we
  don't interfere with the regular one, while always presenting it cleanly (and
  calling it correctly) when looking it up.

It can do much more than what is available with other launchers:

* `cat foo > /tmp/bar`
* `arandr; libreoffice /tmp/presentation`

To run this you may call urxvt like so:

    env ACT_AS=floating-terminal urxvtc -geometry x1

----------

If you need to tell your window manager to do something special about the placement of the window as well, you may set a `name` to make it identifiable:

    env ACT_AS=floating-terminal urxvtc -name floating_terminal -geometry x1

For `awesome` v3.5.9 you would use this rule to center the window and bring it
to the top:

    {
      rule = { instance = "floating_terminal" },
      properties = { floating = true, above = true, ontop = true },
      callback = function (c) awful.placement.centered(c, nil) end
    }
