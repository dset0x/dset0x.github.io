2017-02-27T21:52 zsh,buffer
Converting zsh buffer contents to a function
=========================

I sometimes find myself trying out different varations of a command until I manage get it to work the way I intended to. This involves a lot of jumping back and forth between words in my previous buffer. With a really simple function you can decrease the amount of jumping around the command line.

    funcify() {
        BUFFER="(){$BUFFER} "
        zle end-of-line
    }
    zle -N funcify
    bindkey '\ez' funcify

Let's say you're working on the following command:

    $ sed "s/foo/bar/g" foo.txt | grep -P "baz" | sort -zr

Naturally, you keep getting the regexes wrong. Just ^P and change "foo" to "$1" and "baz" to "$2". Then do <esc-z> to call `funcify`. You will end up with this anonymous function:

    $ (){sed "s/$1/bar/g" foo.txt | grep "$2" | sort -zr}

Whatever you type next to it becomes its arguments and you can experiment more easily now! In other words you've pushed the arguments you're interested in changing to the end.

    $ (){sed "s/$1/bar/g" foo.txt | grep "$2" | sort -zr} FOO BAZ
