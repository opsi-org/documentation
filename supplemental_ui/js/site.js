! function () {
    "use strict";
    const urlParams = new URLSearchParams(window.location.search);
    console.info(urlParams)
    const searchStr = urlParams.get("search");
    console.log("searchStr: ", searchStr);
    if (searchStr && searchStr != null) {
        searchWord(searchStr);
    }

    var e, o, r, v = /^sect(\d)$/,
        i = document.querySelector(".nav-container"),
        a = document.querySelector(".nav-toggle"),
        c = i.querySelector(".nav"),
        s = (a.addEventListener("click", function (e) {
            if (a.classList.contains("is-active")) return l(e);
            d(e);
            var e = document.documentElement,
                t = (e.classList.add("is-clipped--nav"), a.classList.add("is-active"), i.classList.add("is-active"), c.getBoundingClientRect()),
                n = window.innerHeight - Math.round(t.top);
            Math.round(t.height) !== n && (c.style.height = n + "px");
            e.addEventListener("click", l)
        }), i.addEventListener("click", d), i.querySelector("[data-panel=menu]"));

    function t() {
        var e, t, n = window.location.hash;
        if (n && (n.indexOf("%") && (n = decodeURIComponent(n)), !(e = s.querySelector('.nav-link[href="' + n + '"]')))) {
            n = document.getElementById(n.slice(1));
            if (n)
                for (var i = n, a = document.querySelector("article.doc");
                    (i = i.parentNode) && i !== a;) {
                    var c = i.id;
                    if ((c = !c && (c = v.test(i.className)) ? (i.firstElementChild || {}).id : c) && (e = s.querySelector('.nav-link[href="#' + c + '"]'))) break
                }
        }
        if (e) t = e.parentNode;
        else {
            if (!r) return;
            e = (t = r).querySelector(".nav-link")
        }
        t !== o && (u(s, ".nav-item.is-active").forEach(function (e) {
            e.classList.remove("is-active", "is-current-path", "is-current-page")
        }), t.classList.add("is-current-page"), p(o = t), h(s, e))
    }

    function p(e) {
        for (var t, n = e.parentNode; !(t = n.classList).contains("nav-menu");) "LI" === n.tagName && t.contains("nav-item") && t.add("is-active", "is-current-path"), n = n.parentNode;
        e.classList.add("is-active")
    }

    function n() {
        var e, t, n, i;
        this.classList.toggle("is-active") && (e = parseFloat(window.getComputedStyle(this).marginTop), t = this.getBoundingClientRect(), n = s.getBoundingClientRect(), 0 < (i = (t.bottom - n.top - n.height + e).toFixed()) && (s.scrollTop += Math.min((t.top - n.top - e).toFixed(), i)))
    }

    function l(e) {
        d(e);
        e = document.documentElement;
        e.classList.remove("is-clipped--nav"), a.classList.remove("is-active"), i.classList.remove("is-active"), e.removeEventListener("click", l)
    }

    function d(e) {
        e.stopPropagation()
    }

    function h(e, t) {
        var n = e.getBoundingClientRect(),
            i = n.height,
            a = window.getComputedStyle(c);
        "sticky" === a.position && (i -= n.top - parseFloat(a.top)), e.scrollTop = Math.max(0, .5 * (t.getBoundingClientRect().height - i) + t.offsetTop)
    }

    function u(e, t) {
        return [].slice.call(e.querySelectorAll(t))
    }
    s && (e = i.querySelector("[data-panel=explore]"), o = s.querySelector(".is-current-page"), (r = o) ? (p(o), h(s, o.querySelector(".nav-link"))) : s.scrollTop = 0, u(s, ".nav-item-toggle").forEach(function (e) {
        var t = e.parentElement,
            e = (e.addEventListener("click", n.bind(t)), function (e, t) {
                e = e.nextElementSibling;
                return (!e || !t || e[e.matches ? "matches" : "msMatchesSelector"](t)) && e
            }(e, ".nav-text"));
        e && (e.style.cursor = "pointer", e.addEventListener("click", n.bind(t)))
    }), e && e.querySelector(".context").addEventListener("click", function () {
        u(c, "[data-panel]").forEach(function (e) {
            e.classList.toggle("is-active")
        })
    }), s.addEventListener("mousedown", function (e) {
        1 < e.detail && e.preventDefault()
    }), s.querySelector('.nav-link[href^="#"]') && (window.location.hash && t(), window.addEventListener("hashchange", t)))
}();
! function () {
    "use strict";
    var e = document.querySelector("aside.toc.sidebar");
    if (e) {
        if (document.querySelector("body.-toc")) return e.parentNode.removeChild(e);
        var l = parseInt(e.dataset.levels || 2, 10);
        if (!(l < 0)) {
            for (var u = "article.doc", f = document.querySelector(u), m = [], t = 0; t <= l; t++) {
                var o = [u];
                if (t) {
                    for (var n = 1; n <= t; n++) o.push((2 === n ? ".sectionbody>" : "") + ".sect" + n);
                    o.push("h" + (t + 1) + "[id]")
                } else o.push("h1[id].sect0");
                m.push(o.join(">"))
            }
            r = m.join(","), i = f.parentNode;
            var d, c = [].slice.call((i || document).querySelectorAll(r));
            if (!c.length) return e.parentNode.removeChild(e);
            var a = {},
                s = c.reduce(function (e, t) {
                    var o = document.createElement("a"),
                        n = (o.textContent = t.textContent, a[o.href = "#" + t.id] = o, document.createElement("li"));
                    return n.dataset.level = parseInt(t.nodeName.slice(1), 10) - 1, n.appendChild(o), e.appendChild(n), e
                }, document.createElement("ul")),
                i = e.querySelector(".toc-menu"),
                r = (i || ((i = document.createElement("div")).className = "toc-menu"), document.createElement("h3")),
                e = (r.textContent = e.dataset.title || "Contents", i.appendChild(r), i.appendChild(s), !document.getElementById("toc") && f.querySelector("h1.page ~ :not(.is-before-toc)"));
            e && ((r = document.createElement("aside")).className = "toc embedded", r.appendChild(i.cloneNode(!0)), e.parentNode.insertBefore(r, e)), window.addEventListener("load", function () {
                p(), window.addEventListener("scroll", p)
            })
        }
    }

    function p() {
        var n, i, t, e = window.pageYOffset,
            o = 1.15 * h(document.documentElement, "fontSize"),
            r = f.offsetTop;
        if (e && window.innerHeight + e + 2 >= document.documentElement.scrollHeight) return d = Array.isArray(d) ? d : Array(d || 0), n = [], i = c.length - 1, c.forEach(function (e, t) {
            var o = "#" + e.id;
            t === i || e.getBoundingClientRect().top + h(e, "paddingTop") > r ? (n.push(o), d.indexOf(o) < 0 && a[o].classList.add("is-active")) : ~d.indexOf(o) && a[d.shift()].classList.remove("is-active")
        }), s.scrollTop = s.scrollHeight - s.offsetHeight, void(d = 1 < n.length ? n : n[0]);
        Array.isArray(d) && (d.forEach(function (e) {
            a[e].classList.remove("is-active")
        }), d = void 0), c.some(function (e) {
            if (e.getBoundingClientRect().top + h(e, "paddingTop") - o > r) return !0;
            t = "#" + e.id
        }), t ? t !== d && (d && a[d].classList.remove("is-active"), (e = a[t]).classList.add("is-active"), s.scrollHeight > s.offsetHeight && (s.scrollTop = Math.max(0, e.offsetTop + e.offsetHeight - s.offsetHeight)), d = t) : d && (a[d].classList.remove("is-active"), d = void 0)
    }

    function h(e, t) {
        return parseFloat(window.getComputedStyle(e)[t])
    }
}();
! function () {
    "use strict";
    var o = document.querySelector("article.doc"),
        t = document.querySelector(".toolbar");

    function i(e) {
        return e && (~e.indexOf("%") ? decodeURIComponent(e) : e).slice(1)
    }

    function r(e) {
        if (e) {
            if (e.altKey || e.ctrlKey) return;
            window.location.hash = "#" + this.id, e.preventDefault()
        }
        window.scrollTo(0, function e(t, n) {
            return o.contains(t) ? e(t.offsetParent, t.offsetTop + n) : n
        }(this, 0) - t.getBoundingClientRect().bottom)
    }
    window.addEventListener("load", function e(t) {
        var n, o;
        (n = i(window.location.hash)) && (o = document.getElementById(n)) && (r.bind(o)(), setTimeout(r.bind(o), 0)), window.removeEventListener("load", e)
    }), Array.prototype.slice.call(document.querySelectorAll('a[href^="#"]')).forEach(function (e) {
        var t, n;
        (t = i(e.hash)) && (n = document.getElementById(t)) && e.addEventListener("click", r.bind(n))
    })
}();
! function () {
    "use strict";
    var t, e = document.querySelector(".page-versions .version-menu-toggle");
    e && (t = document.querySelector(".page-versions"), e.addEventListener("click", function (e) {
        t.classList.toggle("is-active"), e.stopPropagation()
    }), document.documentElement.addEventListener("click", function () {
        t.classList.remove("is-active")
    }))
}();
! function () {
    "use strict";
    var t = document.querySelector(".navbar-burger");
    t && t.addEventListener("click", function (t) {
        t.stopPropagation(), document.documentElement.classList.toggle("is-clipped--navbar"), this.classList.toggle("is-active");
        t = document.getElementById(this.dataset.target); {
            var e;
            t.classList.toggle("is-active") && (t.style.maxHeight = "", e = window.innerHeight - Math.round(t.getBoundingClientRect().top), parseInt(window.getComputedStyle(t).maxHeight, 10) !== e && (t.style.maxHeight = e + "px"))
        }
    }.bind(t))
}();
! function () {
    "use strict";
    var o = /^\$ (\S[^\\\n]*(\\\n(?!\$ )[^\\\n]*)*)(?=\n|$)/gm,
        s = /( ) *\\\n *|\\\n( ?) */g,
        l = / +$/gm,
        d = (document.getElementById("site-script") || {
            dataset: {}
        }).dataset;
    [].slice.call(document.querySelectorAll(".doc pre.highlight, .doc .literalblock pre")).forEach(function (e) {
        var t, n, c, i;
        if (e.classList.contains("highlight"))(a = (t = e.querySelector("code")).dataset.lang) && "console" !== a && ((c = document.createElement("span")).className = "source-lang", c.appendChild(document.createTextNode(a)));
        else {
            if (!e.innerText.startsWith("$ ")) return;
            var a = e.parentNode.parentNode;
            a.classList.remove("literalblock"), a.classList.add("listingblock"), e.classList.add("highlightjs", "highlight"), (t = document.createElement("code")).className = "language-console hljs", t.dataset.lang = "console", t.appendChild(e.firstChild), e.appendChild(t)
        }(a = document.createElement("div")).className = "source-toolbox", c && a.appendChild(c), window.navigator.clipboard && ((n = document.createElement("button")).className = "copy-button", n.setAttribute("title", "Copy to clipboard"), "svg" === d.svgAs ? ((c = document.createElementNS("http://www.w3.org/2000/svg", "svg")).setAttribute("class", "copy-icon"), (i = document.createElementNS("http://www.w3.org/2000/svg", "use")).setAttribute("href", window.uiRootPath + "/img/octicons-16.svg#icon-clippy"), c.appendChild(i), n.appendChild(c)) : ((i = document.createElement("img")).src = window.uiRootPath + "/img/octicons-16.svg#view-clippy", i.alt = "copy icon", i.className = "copy-icon", n.appendChild(i)), (c = document.createElement("span")).className = "copy-toast", c.appendChild(document.createTextNode("Copied!")), n.appendChild(c), a.appendChild(n)), e.appendChild(a), n && n.addEventListener("click", function (e) {
            var t = e.innerText.replace(l, "");
            "console" === e.dataset.lang && t.startsWith("$ ") && (t = function (e) {
                var t, n = [];
                for (; t = o.exec(e);) n.push(t[1].replace(s, "$1$2"));
                return n.join(" && ")
            }(t));
            window.navigator.clipboard.writeText(t).then(function () {
                this.classList.add("clicked"), this.offsetHeight, this.classList.remove("clicked")
            }.bind(this), function () {})
        }.bind(n, t))
    })
}();

function searchWord(searchText) {
    let cont = document.querySelector("article");
    let pattern = new RegExp("(" + searchText + ")", "gi");

    let links = document.querySelectorAll(".xref");
    let hrefs = []
    for (var i = 0; i < links.length; i++) {
        hrefs.push(links[i].href)
    }
    cont.innerHTML = cont.innerHTML.replace(pattern, "<mark>$1</mark>");

    let new_links = document.querySelectorAll(".xref");
    for (var i = 0; i < links.length; i++) {
        new_links[i].href = hrefs[i]
    }

    let scrollPos = document.querySelector("mark").offsetTop - 500;
    window.scroll({
        top: scrollPos,
        behavior: "auto"
    });

   

}