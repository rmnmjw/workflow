// ==UserScript==
// @name        twitter to nitter
// @namespace   Violentmonkey Scripts
// @match       https://twitter.com/*
// @match       https://nitter.net/*
// @grant       none
// @version     1.0
// @author      -
// ==/UserScript==

document.location.href = document.location.href.replace(/https?:\/\/(tw|n)itter.(com|net)\//, 'http://nitter.localhost/');