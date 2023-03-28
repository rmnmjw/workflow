// ==UserScript==
// @name        invidious remove clickbait
// @namespace   Violentmonkey Scripts
// @match       http://invidious.localhost/*
// @grant       none
// @version     1.0
// @author      -
// @description 20.3.2023, 08:01:41
// ==/UserScript==

// THANKS: https://github.com/pietervanheijningen/clickbait-remover-for-youtube

[...document.getElementsByTagName('img')]
    .forEach(el => {
        if (!el.src.match(/\/vi\/.*\/(hq1|hq2|hq3|hqdefault|mqdefault|hq720).jpg?.*/)) {
            return;
        }

        let url = el.src.replace(/(hq1|hq2|hq3|hqdefault|mqdefault|hq720).jpg/, 'hq1.jpg');
        if (!url.match('.*stringtokillcache')) {
            url += '?stringtokillcache'
        }

        el.src = url;
    });