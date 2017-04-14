2017-02-21T11:23 mpd,linux,logfiles,binary
# Removing binary data from (mpd) logfiles

I like to keep `mpd` logs around for statistics purposes.

Unfortunately I have had mpd write binary to the logfile for one reason or
another. Fear not, easy to fix.

    $ rc-service mpd stop
    $ strings -e S /var/lib/mpd/log > /var/lib/mpd/log2
    $ mv /var/lib/mpd/log{2,}
    $ rc-service mpd start

This was also a good time to remove all the client calls to bring the filesize
down from 1GiB.

    $ grep -v ': client: \[' /var/lib/mpd/log > /var/lib/mpd/log2
