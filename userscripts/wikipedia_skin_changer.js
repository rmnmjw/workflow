// ==UserScript==
// @name         Wikipedia Skin Changer
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Changes the skin of Wikipedia
// @match        https://*.wikipedia.org/*
// @match        https://*.wikimedia.org/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    const SKIN = 'vector';

    {
        const url = new URL(document.location.href);
        if (url.searchParams.get('useskin') !== SKIN) {
            url.searchParams.set('useskin', SKIN);
            document.location.href = url.href;
        }
    }

    const treeWalker = document.createTreeWalker(document.body, NodeFilter.SHOW_ELEMENT);

    let c = treeWalker.currentNode;

    while (c) {
        if (c.nodeName !== 'A' || c.href.trim() === '') {
            c = treeWalker.nextNode();
            continue;
        }

        const url = new URL(c.href);

        if (!url.hostname.endsWith('wikipedia.org') && !url.hostname.endsWith('wikimedia.org')) {
            c = treeWalker.nextNode();
            continue;
        }

        if (url.searchParams.get('useskin') === SKIN) {
            c = treeWalker.nextNode();
            continue;
        }
        url.searchParams.set('useskin', SKIN);
        c.href = url.href;

        c = treeWalker.nextNode();
    }

})();