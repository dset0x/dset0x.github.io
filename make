#!/bin/sh

echo > index.tmp
for j in *.txt; do
    i="${j%.*}"
    txt2html -ah header.html -pp top.html --outfile $i.html --prebegin 0 --prewhite 4 --titlefirst --underline_delimiter '' --bold_delimiter '' --italic_delimiter '' --short_line_length 80 $i.txt

    echo "<p><a href=\"/$i.html\">$(head -1 "$i.txt")</a></p>" >> index.tmp
done

txt2html -ah header.html -pp top.html --outfile index.html --prebegin 1 --prewhite 4 --titlefirst --underline_delimiter '' --bold_delimiter '' --italic_delimiter '' --short_line_length 80 --append_file index.tmp index.txt

rm index.tmp
