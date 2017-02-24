#!/usr/bin/env bash

ttl="$1"
dsc="$2"
key="$3"
cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
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
    a           {/*text-decoration:none;*/}

    /* Headings */
    h1, h2      {font-size: medium; margin: 0.67em 0 0.67em 0;}
    h2          {font-weight: initial;}

    /* Paragraphs */
    p, .preview {max-width: 79ch; text-align: justify;}
    .preview    {padding-left: 4ch; opacity: 0.7;}

    /* Menus */
    ul          {padding-left: 0;}
    ul#menu li  {display: inline;}

    /* Decorations */
    ul#menu li:before           {content: '［';}
    ul#menu li::after           {content: '］　';}
    ul#menu li:last-child:after {content: '］';}

    /* Accessibility */
    .hidden {position:absolute; left:-1000px; top:auto; width:1px; height:1px; overflow:hidden;}
</style>
</head>
<body>

<nav>
    <div class="hidden"><a href="#content">Skip to content</a></div>
    <ul id="menu">
      <li><a href="/">Home</a></li>
      <li><a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub Issues</a></li>
    </ul> 
</nav>

<hr>

<main id="content">
EOF
