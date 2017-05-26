2017-04-28T23:48 gentoo,s6,desktop,openrc
# (Mis)using s6 to run complementary desktop applications

> [s6](http://www.skarnet.org/software/s6/index.html) is a small suite of programs for UNIX, designed to allow process supervision

## Motivation and reasoning

1. Over the years, I have started accumulating applications that I rely on running in the background. In fact, those are:

    * `artha`
    * `keepassxc`
    * `urxvtd`
    * `compton` (along with `ambient-dim.sh`)
    * `mpd`
    * `blueman`
    * `moltengamepad`
    * some ssh mount
    * `mpd`
    * `transmission`
    * `viber`

2. Why supervise (at user-level)?

    * They crash. Proprietary applications like Viber I'd rather restart than fix.
    * They don't belong in my system's boot process.
    * These are "services" as far as I'm concerned. For example, my desktop isn't functional without `urxvrd` so I can't afford it being down.
    * Some of these applications log to stdout/stderr, but if you run them from `~/.xinitrc`, you can't tell what's outputting what (although, yes, you can manually use a logger like `s6-log`).

3. Why not `supervisord`?

    `supervisord` turned out to be a pain to use as one has to edit some lengthy config file to manage services. This is not the way I'm used to doing things at all with `OpenRC`. `s6` on the uses structured directories and supports logging out of the box.

## Setup

### Service groups

You will notice that some of these applications (eg `mpd`) should only ever be ran once, while others are tied to the `X` session. For that, I use two supervision trees, one of which is executed in `~/.xinitrc` so that `$DISPLAY` is set.

All I needed to get things running was a directory per service:

    $ tree -L 4 ~/.services
    ~/.services
    ├── available
    │   ├── ambient
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run
    │   ├── artha
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run -> /usr/bin/artha
    │   ├── blueman
    │   │   ├── finish
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run
    │   ├── compton
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run
    │   ├── keepassxc
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run
    │   ├── moltengamepad
    │   │   ├── run
    │   ├── mount-semiphoto
    │   │   ├── run
    │   ├── mpd
    │   │   ├── run
    │   ├── transmission
    │   │   ├── run
    │   ├── urxvtd
    │   │   ├── log
    │   │   │   └── run
    │   │   └── run
    │   └── viber
    │       ├── log
    │       │   └── run
    │       └── run
    ├── tty
    │   ├── moltengamepad -> ../available/moltengamepad
    │   ├── mount-semiphoto -> ../available/mount-semiphoto
    │   ├── mpd -> ../available/mpd/
    │   └── transmission -> ../available/transmission
    └── xorg
        ├── ambient -> ../available/ambient
        ├── artha -> ../available/artha
        ├── blueman -> ../available/blueman
        ├── compton -> ../available/compton
        ├── keepassxc -> ../available/keepassxc
        ├── urxvtd -> ../available/urxvtd
        └── viber -> ../available/viber


### run

Each of which contains a `run` file that is responsible for bringing up the service. For example:

    #!/bin/sh
    exec 2>&1
    exec urxvtd -q -o

Note that they must all run in the foreground, for example you need to use `-f` with `sshfs`.

### log

If you want a service to be logged, you let `s6-svscan` know that by creating a `log` directory. That will pipe `run`'s `stdout` to `log/run`'s `stdin`.

A simple `log/run` that logs everything with a human-readable timestamp to the current directory would be:

    #!/bin/sh
    s6-log T ./

### Running all `Xorg`-tied applications

I prepare and supervise a supervision directory tree for a given `$DISPLAY` like so:

    mkdir -p "/tmp/services-$DISPLAY"
    cp -Lr ~/.services/xorg/* "/tmp/services-$DISPLAY/"
    s6-svscan /tmp/services-$DISPLAY &!  # zshism

This results in the following process tree:

    s6-svscan /tmp/services-:0
    ├─ s6-supervise artha
    │  └─ run
    ├─ s6-supervise artha/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise viber
    │  └─ /opt/viber/Viber
    │     └─ Viber
    ├─ s6-supervise viber/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise ambient
    │  └─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │     └─ ffmpeg -hide_banner -f video4linux2 -s 640x480 -i /dev/video0 -filter:v fps=fps=30, showinfo -f null -
    │        └─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │           ├─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │           └─ grep -Po (?<=mean:\[)[0-9]*
    ├─ s6-supervise ambient/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise compton
    │  └─ ~/src/compton/compton --dbus
    ├─ s6-supervise compton/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise keepassxc
    │  └─ keepassxc
    ├─ s6-supervise keepassxc/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise blueman
    │  └─ python3.4 /usr/bin/blueman-applet
    ├─ s6-supervise blueman/log
    │  └─ /bin/sh ./run
    │     └─ s6-log T ./
    ├─ s6-supervise urxvtd
    │  └─ urxvtd -q -o
    └─ s6-supervise urxvtd/log
    └─ /bin/sh ./run
       └─ s6-log T ./

`~/.services/tty` does not need this preparation as there will only ever be one `s6-svscan` for all of its contents.

## Management

Bringing any service down is a matter of calling:

    s6-svc -d /tmp/services-:0/compton

No fiddling with `pkill` or dealing with accidentally running multiple instances of one thing.

## Exiting

Given that I run s6-svscan through `~/.xinitrc`, upon leaving X, the unthinkable is done: the supervisor is brought down. After all, the majority of these applications are reliant on X running. However, `s6` is designed with one purpose in life:

> The services must remain up at all costs.

Therefore, one needs to explicitly ask all instances `s6-supervise` to end the services. To do that I append the following _after_ my WM in `~/.xinitrc`:

    for svc in "/tmp/services-$DISPLAY"/*; do s6-svc -d "$svc"; done
