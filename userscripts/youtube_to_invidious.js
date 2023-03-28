// ==UserScript==
// @name        youtube to invidious
// @namespace   Violentmonkey Scripts
// @match       https://www.youtube.com/*
// @grant       none
// @version     1.0
// @author      -
// ==/UserScript==


document.location.href = document.location.href.replace(/https?:\/\/(www.)?youtube.com\//, 'http://invidious.localhost/');