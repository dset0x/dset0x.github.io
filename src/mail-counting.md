2017-07-26T19:00 linux,mail,client,count
# Resolving unread mail count with different mail clients

While looking for a new MUA, I've had to come up with different ways for displaying an unread mail count on my desktop.

## notmuch

Naturally, `notmuch` is the easiest, as long as you've finalized your policy as to _what_ consitutes new mail.

    notmuch search tag:inbox and <OTHER CONDITIONS> | wc -l

## claws

`claws` has excellent command line switches for just about everything.

    claws-mail --status-full | awk '/INBOX$/ { sum+=$2 } END { print sum; }'",

## evolution

`evolution` doesn't have a good command line interface. One has to go through its cache, which seems to be kept up-to-date.

    for i in ~/.cache/evolution/mail/*; do
        sqlite3 "$i/folders.db" "select count(*) read from INBOX where read == 0";
    done | awk '{ sum += $1; } END { print sum; }'")

### "Work offline" status

It's easy to flip the "work offline" switch in evolution without noticing. Luckily you can get its value easily.

    gsettings get org.gnome.evolution.shell start-offline
