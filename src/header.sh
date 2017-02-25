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
        body    {font-family: font-family: 'Open Sans',Arial,sans-serif; font-size: 15px; max-width: 79ch; opacity: 0.85;}
        a       {text-decoration: none; color: #4078c0;}

        /* Headings */
        h2      {font-size: medium; margin: 0.67em 0 0.67em 0;}
        h2      {font-weight: initial;}
        h1      {font-size: large;text-align: center;}

        /* Paragraphs */
        article .preview, article hr    {margin-left: 4ch}
        article .preview                {max-height: 20vw; overflow:hidden; opacity: 0.9;}
        #content hr                     {opacity: 0.3;}

        /* Menu */
        ul  {padding-left: 0;}
        ul#menu li:before          {content: '［';}
        ul#menu li:after           {content: '］';}

            /* Centered */
                ul#menu                         {text-align: center; margin: 0;}
                ul#menu li                      {display: block;}
                ul#menu li:not(last-child)      {padding: 0.2em 0 0.2em 0;}

            /* Not centered */
                /* ul#menu li                   {display: inline;} */
                /* ul#menu li:not(last-child)   {padding-right: 1ch;} */

        /* Mobile */
        @media (max-width: 65ch) { pre {overflow: scroll;} }

        /* Accessibility */
        .hidden {position: absolute; opacity:0;}
        .hidden:active, .hidden:focus {opacity:1;}
    </style>
</head>
<body>

<a href="#content" class="hidden" tabindex="1">Skip to content</a></div>
<nav>
    <ul id="menu">
        <li>$home</li>
        <li><a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub Issues</a></li>
    </ul> 
    <hr>
</nav>

<main id="content">
EOF
