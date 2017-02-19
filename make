#!/bin/sh

echo '<div>' > index.tmp
for j in *.txt; do
    [[ "$j" == index.txt ]] && continue
    i="${j%.*}"
    txt2html -ah header.html -pp top.html --outfile $i.html --prebegin 1 --prewhite 4 --titlefirst --underline_delimiter '' --bold_delimiter '' --italic_delimiter '' --short_line_length 80 $i.txt

    echo -e "<h2><a href=\"/$i.html\">$(head -1 "$i.txt")</a></h2>\n" >> index.tmp
done
echo '</pre>' >> index.tmp

txt2html -ah header.html -pp top.html --outfile index.html --prebegin 1 --prewhite 4 --title 'When software gets in the way' --underline_delimiter '' --bold_delimiter '' --italic_delimiter '' --short_line_length 80 --append_file index.tmp index.txt

rm index.tmp
