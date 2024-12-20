2017-02-21T11:23 weechat,linux,memory_leak,script
# Monitoring memory usage for weechat script leaks

I was recently dealing with a memory leak within a script in `weechat`. I
needed a quick and dirty way of figuring out which script was causing the
trouble.

Of course it makes no sense to use `awk` for this, but what the heck. This
script unloads all weechat scripts, then loads them one at a time whenever
passed a line.

    #!/usr/bin/env awk -f

    function load(scr) {
        print strftime("%s"), scr
        system("echo -e \*/script load "scr" > ~/.weechat/weechat\_fifo_$(pgrep --exact weechat)")
    }

    function unload(scr) {
        system("echo -e \*/script unload "scr" > ~/.weechat/weechat\_fifo_$(pgrep --exact weechat)")
    }

    BEGIN {
        "echo ~/.weechat/**/autoload/*" | getline script_paths_str
        split(script_paths_str, script_paths, " ")
        for(idx in script_paths) {
            len = split(script_paths[idx], _, "/")
            script_names[idx] = _[len]
            unload(script_names[idx])
        }
    }

    // {
        if(NR>=1) {
            if(cur_script != "") {
                    unload(cur_script)
            }

            cur_script = script_names[NR+1]
            load(cur_script)
        }
    }

    END {
        for(idx in script_names) {
            load(script_names[idx])
        }
    }


We can go ahead and load one script every one hour:

    $ while :; do echo 1; sleep 1h; done | ./above_script.awk > /tmp/events


Now we have a bunch of timestamped events, but we'd like to frequently check
memory usage too. Let's have another loop do that for us.

    $ while :; do echo $(date +%s) $(ps -q $(pgrep --exact weechat) -o rss,vsz | tail -n 1) >> /tmp/mem; sleep 5s; done


Now to graph everything into a readable image we can use `gnuplot`:

    #!/bin/bash
    {
        cat <<EOF
        set term png small size 1900,600
        set output "/tmp/mem-graph.png"

        set ylabel "RSS (mb)"
        set y2label "VSZ (mb)"

        set ytics nomirror
        set y2tics nomirror in
        set grid ytics lc rgb "#bbbbbb" lw 1 lt 0

        set yrange [230.000:*]
        set y2range [90.000:*]

        set tic scale 0
        set xtics format " "
        set xtics rotate by 45 offset -0.8,-9.8
        set bmargin 11

    EOF
        cat /tmp/events | while read date ev_name; do
            echo "set arrow from $date, graph 0 to $date, graph 1 nohead"
            echo "set xtics add (\""$ev_name"\" $date)"
        done

        cat <<EOF
        plot "< uniq -f 0 /tmp/mem" using 1:(\$3/1000) with lines axes x1y1 title "VSZ", \
             "< uniq -f 0 /tmp/mem" using 1:(\$2/1000) with lines axes x1y2 title "RSS"
    EOF
    } | gnuplot


What's handy about this setup is that we can kill any script for any reason
without losing data. In fact we can stop the first one and load whichever
scripts we want, as long as we maintain `/tmp/events`.

Of course you can run the `gnuplot` script on a remote box as long as you have
access to the two logfiles.

    $ rifle /tmp/mem-graph.png
