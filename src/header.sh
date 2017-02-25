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
        html        {background-color: #fffdff;}
        body        {font-family: sans-serif; max-width: 79ch; opacity: 0.85;}
        hr          {opacity: 0.2;}

        /* Links */
        a           {text-decoration: none;}
        a:link      {color: #3189c5;}
        a:visited   {color: #a131c5;}
        a:hover     {text-decoration: underline;}

        /* Headings */
        h2          {font-size: medium; margin: 0.67em 0 0.67em 0; font-weight: initial;}
        h1          {font-size: large; text-align: center;}

        /* Previews */
        article {position: relative;}
        article .preview {max-height: 20vw; overflow:hidden; opacity: 0.9; margin-left: 4ch; text-align: justify;}
        article .cont_box {margin-left: 4ch;}
        article .cont {position: absolute; bottom: -0.4em; right: 0; background: #fffdff; font-size: small; padding-left: 1ch; z-index: 1;}

        /* Menu */
        ul                              {padding-left: 0;}
        ul#menu                         {text-align: right; margin-right: 0;}
        ul#menu li                      {display: block;}
        ul#menu li:not(last-child)      {padding: 0.2em 0 0.2em 0;}
        ul#menu hr                      {width: 20ch; margin-right: 0; margin-top: 0; margin-bottom: 0;}

        /*
        ul#menu li                   {display: inline;}
        ul#menu li:not(last-child)   {padding-right: 1ch;}
        */

        /* Mobile */
        @media (max-width: 65ch) {
            pre {overflow: scroll;}
            .cont_box {display: none;}
        }

        /* Skip to content */
        .skip {position: absolute; opacity:0; pointer-events: none;}
        .skip:active, .skip:focus {opacity:1;}
    </style>
</head>
<body>

<a href="#content" class="skip" tabindex="1">Skip to content</a></div>
<nav>
    <ul id="menu">
        <li>$home</li>
        <hr>
        <li><a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub Issues</a></li>
        <hr>
    </ul> 
    <hr>
</nav>

<main id="content">
EOF
