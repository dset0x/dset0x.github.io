2017-02-25T16:02 mutt,notmuch,neomutt,addresses,address_book
Extracting all known addresses from notmuch for use with mutt
===========================================

Retrieving all known addresses from notmuch's index turned out to be more
difficult than I had initially assumed. I needed to search not only
recipients, but senders as well, due to mailing lists and such. Don't forget
that mutt skips the first line of the addresses.

    #!/bin/bash
    (parallel notmuch address {} '\*' ::: \
        '--output=sender' '--output=recipients') | \
        grep -Pi "$1" | \
        awk '\
    BEGIN {print}
    />$/ {
        s=$NF;
        sub(/^</, "", s);
        sub(/>$/, "", s);
        printf("%s\t", s);
        for (i = 1; i < NF; i++)
            printf("%s ", $i);
        printf("\n")
    }
    ' | sort | uniq

This method is unfortunately quite slow, whether you use `parallel` or not.
You are hitting the same database after all.