#!/usr/bin/env bash

typ="$1"  # notes|article|advice|astro
ttl="$2"
dsc="$3"
key="$4"

notes='<a href="/">Notes</a>'
advice='<a href="/pages/advice.html">Advice</a>'
astro='<a href="/pages/astro.html">Astro</a>'
declare "$typ"="${typ^}"

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
        html        {background-color: #fff;}
        body        {margin: auto; max-width: 6.67in; font-size: 11pt; padding: 0 1em 1em 1em; opacity: .8;}
        hr          {border: 0; border-top: 1px solid #c6c5c6;}

        a           {text-decoration: none;}
        a:link      {color: #3189c5;}
        a:visited   {color: #a131c5;}
        a:hover     {text-decoration: underline;}

        h1, h2      {opacity: .8;}
        h1          {font-size: x-large;}
        h2          {font-size: large;}

        .preview    {max-height: 20vw; margin-left: 4ch; overflow: hidden;}
        pre         {font-size: 10pt; background-color: #eee; padding: .5em; overflow: auto;}

        nav         {display: inline-block; width: 100%;}
        #menu       {float: right;}
        #menu li    {text-align: right; display: block; padding-top: 0.4em;}
        #menu div   {border-bottom: #c6c5c6 1px solid; width: 9em;}

        .skip {position: absolute; opacity:0; pointer-events: none;}
        .skip:active, .skip:focus {opacity:1;}
    </style>
</head>
<body>

<a href="#content" class="skip" tabindex="1">Skip to content</a>
<nav>
    <ul id="menu">
        <li><div>$notes</div></li>
        <li><div>$advice</div></li>
        <li><div>$astro</div></li>
        <li><div><a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub</a></div></li>
    </ul>
</nav>

<main id="content">
EOF

cat <<EOF > /dev/null
    CONTINUE READING
        article .cont       {position: absolute; bottom: -0.4em; right: 0; background: #fffdff; font-size: small; padding-left: 1ch; z-index: 2;}
        @media (max-width: 65ch) {
            .cont {display: none;}
        }
        pre, article .preview, article .cont_box {margin-left: 4ch;}

    FOOTER

        html {
          height: 100%;
          box-sizing: border-box;
        }

        *,
        *:before,
        *:after {
          box-sizing: inherit;
        }

        body {
          position: relative;
          padding-bottom: 6rem;
          min-height: 100%;
        }

        footer {
          position: absolute;
          right: 0;
          left: 0;
          bottom: 0;
          padding: 0.5em;
          background-color: #efefef;
          text-align: center;
        }

    INLINE MENU

        ul#menu li                   {display: inline;}
        ul#menu li:not(last-child)   {padding-right: 1ch;}
EOF
