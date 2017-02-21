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
    body {font-family: monospace;}
    h1, h2 {font-size:medium; margin: 0.67em 0 0.67em 0;}
    h2 {font-weight: initial;}
    p {width: 79ch;}
    .preview {padding-left: 4ch; opacity: 0.7; width: 79ch;}
    body {background-color: #F3F3F3;
          background-image: url('/carrot.png');
          background-position: right bottom;
          background-repeat: no-repeat;
          background-attachment: fixed;

          display: flex;
          min-height: 98vh;
          flex-direction: column;
      }
</style>
</head>
<body>
<div id="nav">
<a href="/">Home</a> |
GitHub {
    <a href="https://github.com/search?o=desc&q=author:dset0x+&s=committer-date&type=Commits&utf8=✓">Commits</a>,
    <a href="https://github.com/search?o=desc&q=author:dset0x+&s=created&type=Issues&utf8=✓">Issues</a>
}
<hr>
</div>
<div id="content">
EOF
