2017-02-22T11:23 mutt,neomutt,mailto,handler
# Using mailto URIs with mutt postponed email

mailto:// URLs are sometimes convenient to use, but they don't fit in too well
with using a single mutt instance and having an aversion to windows popping
up.

One way to use them with mutt is to take advantage of the postponed feature.
If your `postponed` variable points to a directory you may have multiple
postponed messages.

    $ mkdir ~/.mail/postponed
    $ echo 'set postponed = "~/.mail/postponed"' >> ~/.mutt/muttrc

We can therefore generate a postponed message every time a mailto URI is
clicked. Create this script and have your applications call it for mailto://.

    #!/bin/bash

    set -eu

    uri_unescape() {
      perl -e 'use URI::Escape; print uri_unescape($ARGV[0])' "$1"
    }

    mutt_expand_path() {
        eval $(mutt -Q folder)
        val="${1/#=/$folder\/}"
        val="${val/#\~/$HOME}"
        echo "$val"
    }

    # Variables from mutt
    for var in from realname postponed signature; do
        eval $(mutt -Q "$var")
    done
    postponed=$(mutt_expand_path $postponed)
    signature=$(mutt_expand_path $signature)

    # Arguments from URI
    IFS="?" read to args <<<"$1"
    to="$(uri_unescape "${to#mailto:}")"

    for key in subject cc bcc body;
        do declare "$key"=;
    done

    for arg in ${args//&/ }; do
      key="${arg%%=*}"; key="${key,,}"
      value="$(uri_unescape "${arg#*=}")"
      [[ "$key" =~ subject|cc|bcc|body ]] && declare "$key"="$value"
    done

    # Create postponed email
    mkdir -p "$postponed"/new
    file="$postponed"/new/"$(date +%s).\
        R$(grep -ao '[0-9]' /dev/urandom | head -20 | tr -d '\n').$(hostname)"

    cat <<EOF > "$file"
    From: $realname <$from>
    To: $to
    Cc: $cc
    Bcc: $bcc
    Subject: $subject

    $body

    --
    $(cat $signature)
    EOF


You're going to have to make sure that `folder`, `realname`, `postponed` and
`sigature` expand appropariately when called via `mutt -Q`.
