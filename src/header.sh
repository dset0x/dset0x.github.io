#!/usr/bin/env bash

typ="$1"
ttl="$2"
dsc="$3"
key="$4"

case "$typ" in
    'home')
        home='Home'
        ;;
    *)
        home='<a href="/">Home</a>'
        ;;
esac

cat <<EOF
<!DOCTYPE html>
<html lang="en" xml:lang="en">
<head>
    <title>$ttl</title>
    <meta charset="utf-8">
    <meta name="description" content="$dsc">
    <meta name="keywords" content="$key">
    <meta name="author" content="Dimitrios Semitsoglou-Tsiapos">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico"/>
    <link rel="alternate" type="application/rss+xml" title="When software gets in the way" href="/feed.xml" />
    <style>
        /* General */
        body        {font-family: sans-serif;}
        a           {text-decoration: none;}

        /* Headings */
        h1, h2      {font-size: medium; margin: 0.67em 0 0.67em 0;}
        h2          {font-weight: initial;}

        /* Paragraphs */
        p, article          {max-width: 79ch;}
        article .preview, article hr    {margin-left: 4ch}
        article .preview    {max-height: 20vw; overflow:hidden; opacity: 0.7;}
        article hr {opacity: 0.3;}

        /* Menus */
        ul          {padding-left: 0;}
        ul#menu li  {display: inline;}

        /* Decorations */
        ul#menu li:before          {content: '［';}
        ul#menu li:after           {content: '］';}
        ul#menu li:not(last-child) {padding-right: 1ch;}

        /* Mobile */
        @media (max-width: 65ch) {
            /* Center the menu */
            ul#menu {text-align: center; margin: 0;}
            ul#menu li {display: block;}
            ul#menu li:not(last-child) {padding: 0.2em 0 0.2em 0;}

            /* Scrollable */
            pre {overflow: scroll;}
        }

        /* Accessibility */
        .hidden {position:absolute; left:-1000px; top:auto; width:1px; height:1px; overflow:hidden;}
    </style>
</head>
<body>

<nav>
    <div class="hidden"><a href="#content">Skip to content</a></div>
    <ul id="menu">
        <li>$home</li>
        <li><a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub Issues</a></li>
    </ul> 
    <hr>
</nav>

<main id="content">
EOF
