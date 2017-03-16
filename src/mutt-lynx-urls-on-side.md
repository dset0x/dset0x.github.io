2017-02-21T23:11 lynx,mutt,neomutt,terminal,linux
Getting lynx to print URLs of HTML messages on the side
========================================

Reading HTML e-mail in the terminal can be a bit of a pain. `lynx` does a fine
job at dumping them, but actually opening the URLs from it is cumbersome as
they are placed at the very end of the message.

Luckily, there's nothing a little bit of perl can't fix.

`~/.mutt/link-columns.pl`:

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use open qw(:std :utf8);

    my @lines;
    my @links;

    while (<STDIN>) {
        chomp($_);
        push @lines, $_;
        if ($_ =~ /^ *([0-9]+)\. (.*)/) {
            $links[$1] = $2;
        }
    }

    for my $line (@lines) {
        last if ($line eq "References");
        print $line;
        my $first = 1;
        while ($line =~ /\[([0-9]+)\]/g) {
            if ($first == 0) {
                print "\n" . " " x 80;
            } else {
                print " " x (80 - length($line));
                $first = 0;
            }
            printf "[%s] %s", $1, $links[$1]
        }
        printf "\n"
    }

Then put the following entry in your `~/.mailcap`:
    text/html; sh -c "lynx -dump -force_html -assume_charset=utf-8 -display_charset=utf-8 '%s' | uniq | ~/.mutt/link-columns.pl"; copiousoutput; description=HTML Text; nametemplate=%s.html

Now your spammy e-mail can look like [this](/opt/mutt-lynx-urls-on-side.png) too!
