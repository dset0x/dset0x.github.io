2017-02-26T00:20 zte,script,expect,password
Logging into a ZTE H168N with the help of expect
========================================

Jalal Sela already took the time to break into a sibling of this router on his
[blog](https://jalalsela.wordpress.com/2014/10/31/hacking-zte-router-zxhn-h108n/). Having shell access to my router turned out to be more handy than I had anticipated.

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

-------

Speaking of this device, in it you will find `/var/tmp/db_backup_cfg.xml` and `/data/cfg/db_user_cfg.xml` which have the same contents, except the latter is compressed in some funny way. Here's how do decompress it:

    for offset in $(binwalk -c db_user_cfg.xml | tail -n +4 | cut -d' ' -f1); do
        printf '\x1f\x8b\x08\x00\x00\x00\x00\x00%s' "$(dd skip=$offset ibs=1 if=db_user_cfg.xml)" | gzip -dc >> out.xml;
    done
