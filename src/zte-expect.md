2017-02-26T00:20 zte,script,expect,password
Logging into a ZTE H168N with the help of expect
========================================

Jalal Sela already took the time to break into a sibling of this router on his
[blog](https://jalalsela.wordpress.com/2014/10/31/hacking-zte-router-zxhn-h108n/). Having shell access to my router turned out to be more handy than I had anticipated.

Of course you can have dropbear on it, but I've yet to dare edit `rcS` on it
(although I suppose it gets overwritten on reboot anyway).

    #!/usr/bin/expect -f

    spawn telnet 192.168.2.254 23

    expect Username: { send "root\r" }
    expect Password: { send "public\r" }

    expect >         { send "enable\r" }
    expect Password: { send "zte\r" }

    expect "#"       { send "shell\r" }
    expect Login:    { send "root\r" }
    expect Password: { send "root\r" }

    interact