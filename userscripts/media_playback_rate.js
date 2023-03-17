// ==UserScript==
// @name        media playbackRate + / -
// @namespace   Violentmonkey Scripts
// @match       *://*/*
// @grant       none
// @version     1.0
// @author      -
// @description 17.3.2023, 18:04:04
// ==/UserScript==

{
    const d = document.createElement('div');
    d.style.zIndex = 999999;
    d.style.border = '1px solid black';
    d.style.background = 'white';
    d.style.fontSize = '2em';
    d.style.position = 'fixed';
    d.style.top = '0';
    d.style.right = '0';
    d.style.display = 'none';
    document.body.appendChild(d);

    let to = -1;

    const show = (v) => {
        clearTimeout(to);

        d.innerHTML = v.toFixed(1) + 'x';
        d.style.display = 'block';

        to = setTimeout(() => {
            d.style.display = 'none';
        }, 300);
    }

    document.addEventListener('keydown', (e) => {
        if (e.key !== '+' && e.key !== '-') {
            return;
        }

        const change = e.key === '+' ? 0.1 : -0.1;

        [...document.querySelectorAll('video'), ...document.querySelectorAll('audio')]
            .forEach((el) => {
                el.playbackRate += change;
                show(el.playbackRate);
            });
    });
}