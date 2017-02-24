#!/usr/bin/env bash

ttl="$1"
dsc="$2"
key="$3"
cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
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
    body {font-family:sans-serif;}
    h1, h2 {font-size:medium; margin: 0.67em 0 0.67em 0;}
    h2 {font-weight: initial;}
    p, .preview {max-width: 79ch; text-align: justify;}
    pre {font-size:medium}
    .preview {padding-left: 4ch; opacity: 0.7;}
</style>
</head>
<body>
<nav>
<a href="/">Home</a> |
<a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">GitHub Issues</a>
</nav>
<hr>

<main>
EOF
