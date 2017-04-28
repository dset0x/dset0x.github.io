2017-04-28T23:48
# (Mis)using s6 to run complementary desktop applications

> [s6](http://www.skarnet.org/software/s6/index.html) is a small suite of
programs for UNIX, designed to allow process supervision

Over the years, I have started accumulating desktop applications I want running in the background. In fact, those are:

* `artha`
* `keepassxc`
* `urxvtd`
* `compton` (along with `ambient-dim.sh`)
* `mpd`

I recently realized that it would make sense to group and supervise these programs for a number of reasons:

* `ambient-dim.sh` depends on `compton`. Execution order doesn't matter, but one is useless without the other.
* These are "services" as far as I'm concerned. For example, my desktop isn't functional without `urxvrd` so I can't afford to lose it.
* Some of these applications log to stdout/stderr, but currently, they all end up in the same file.

`supervisord` turned out to be a pain as one has to edit some funky config file to manage services is not the way I'm used to doing things at all with `OpenRC`. And so, I found `s6` which is beautifully simple and uses structured directories instead. I won't go through many details as `s6` website contains all you need to know. Read it carefully though: the design is simple, but unforgiving to those who don't understand it.

All I needed to get things running was a directory per service:

    ~/.services/enabled
    ├── ambient -> ../available/ambient
    ├── artha -> ../available/artha
    ├── keepassxc -> ../available/keepassxc
    ├── mpd -> ../available/mpd
    └── urxvtd -> ../available/urxvtd

Each of which contains a `run` file that is responsible for bringing up the service. For example:

    #!/bin/sh
    trap 'kill $(jobs -p)' EXIT
    exec 2>&1

    ~/src/compton/compton --dbus &
    ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0 &

    wait

Executing `s6-svscan ~/.services/enabled` results in the following process tree:

    s6-svscan ~/.services/enabled
    ├─ s6-supervise mpd
    │  └─ mpd --no-daemon
    ├─ s6-supervise artha
    │  └─ run
    ├─ s6-supervise ambient
    │  └─ /bin/sh ./run
    │     ├─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │     │  └─ ffmpeg -hide_banner -f video4linux2 -s 640x480 -i /dev/video0 -filter:v fps=fps=30, showinfo -f null -
    │     │     └─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │     │        ├─ /bin/bash ~/src/compton/dbus-examples/ambient-dim.sh /dev/video0
    │     │        └─ grep -Po (?<=mean:\[)[0-9]*
    │     └─ ~/src/compton/compton --dbus
    ├─ s6-supervise keepassxc
    │  └─ keepassxc
    └─ s6-supervise urxvtd
       └─ urxvtd -q -o

Bringing `dbus` and `ambient-dim.sh` down is a matter of calling:

    s6-svc -d ~/.services/enabled/ambient

No fiddling with `pkill` or dealing with accidentally running multiple instances of one thing.

---

## Replacing `OpenRC` with `s6`

S\. Gilles has some notes on replacing `OpenRC` with `s6` [on his phlog](gopher://sdf.org/0/users/sgilles/phlog/2017-01-22_setting_up_s6.txt). I feel that this would be more effort to setup and maintain for a desktop-type system than `OpenRC`, but useful on low-end, limited-purpose systems.
