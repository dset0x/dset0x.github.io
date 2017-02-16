#!/bin/sh
for j in *.txt; do
    i="${j%.*}"
    txt2html -ah header.html -pp top.html --outfile $i.html --prebegin 1 --prewhite 4 --titlefirst --underline_delimiter '' --bold_delimiter '' --italic_delimiter '' --short_line_length 80 $i.txt
done
