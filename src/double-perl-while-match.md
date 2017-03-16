2017-02-25T14:02 perl,infinite_loop,regex_match,nested_while
Confusing perl with nested while matches
========================================

Nesting while loops that match against the same string will throw perl into an
infinite loop.

    my $s = "aabb";
    while ( $s =~ /a/g ) {
        my $first = $-[0];
        while ( $s =~ /b/g ) {
            print "$first $-[0]\n";
        }
    }

Produces the following:

    0 2
    0 3
    0 2
    0 3
    0 2
    0 3
    0 2
    0 3
    0 2
    0 3
    [...]

 I have not looked into why this happens, but I assume that these while loops
 share a pointer onto said string. You can work around this by using a copy of
 the string.