/* Web Book Reader client enhancements (zero external dependencies) */
(function () {
  "use strict";

  var html = document.documentElement;
  var lang = (html.getAttribute("lang") || "en").toLowerCase();
  var isEs = lang.indexOf("es") === 0;

  /* 1. Theme Persistence */
  var themeBtn = document.getElementById("theme-toggle");
  if (themeBtn) {
    var updateThemeBtn = function (theme) {
      themeBtn.setAttribute(
        "aria-label",
        isEs
          ? theme === "dark" ? "Cambiar a tema claro" : "Cambiar a tema oscuro"
          : theme === "dark" ? "Switch to light theme" : "Switch to dark theme"
      );
      themeBtn.textContent = theme === "dark" ? "\u2600" : "\u263E";
    };
    updateThemeBtn(html.getAttribute("data-theme") || "dark");
    themeBtn.addEventListener("click", function () {
      var next = html.getAttribute("data-theme") === "dark" ? "light" : "dark";
      html.setAttribute("data-theme", next);
      try {
        localStorage.setItem("dsin-reader-theme", next);
      } catch (e) {}
      updateThemeBtn(next);
    });
  }

  /* 2. Mobile Sidebar Drawer */
  var tocToggle = document.getElementById("toc-toggle");
  var sidebar = document.getElementById("reader-sidebar");
  var backdrop = document.getElementById("sidebar-backdrop");
  var setSidebarOpen = function (open) {
    if (!sidebar || !tocToggle) return;
    sidebar.classList.toggle("open", open);
    tocToggle.setAttribute("aria-expanded", open ? "true" : "false");
    if (backdrop) backdrop.hidden = !open;
  };
  if (tocToggle && sidebar) {
    tocToggle.addEventListener("click", function () {
      setSidebarOpen(!sidebar.classList.contains("open"));
    });
    if (backdrop) {
      backdrop.addEventListener("click", function () {
        setSidebarOpen(false);
      });
    }
    document.addEventListener("keydown", function (ev) {
      if (ev.key === "Escape") setSidebarOpen(false);
    });
  }

  /* 3. Persistent Full-Book Sidebar TOC from Pandoc sitemap.json */
  var sidebarToc = document.getElementById("sidebar-toc");
  var currentFile = window.location.pathname.split("/").pop() || "index.html";

  var renderSitemapList = function (node) {
    var ul = document.createElement("ul");
    var children = Array.isArray(node) ? node : (node.subsections || []);
    children.forEach(function (item) {
      var sec = item.section || item;
      var lvl = parseInt(sec.level || "1", 10);
      if (lvl > 2) return;
      var li = document.createElement("li");
      if (sec.path) {
        var a = document.createElement("a");
        a.href = sec.path;
        var num = sec.number ? sec.number + " " : "";
        a.textContent = num + (sec.title || sec.path);
        var cleanPath = sec.path.split("#")[0];
        if (cleanPath === currentFile && lvl === 1) {
          a.classList.add("active");
          a.setAttribute("aria-current", "page");
        }
        li.appendChild(a);
      }
      if (item.subsections && item.subsections.length > 0 && lvl < 2) {
        var sub = renderSitemapList(item.subsections);
        if (sub.children.length > 0) {
          li.appendChild(sub);
        }
      }
      ul.appendChild(li);
    });
    return ul;
  };

  if (sidebarToc) {
    fetch("./sitemap.json")
      .then(function (resp) {
        return resp.ok ? resp.json() : null;
      })
      .then(function (data) {
        if (!data) return;
        var tree = renderSitemapList(data);
        if (tree.children.length > 0) {
          sidebarToc.innerHTML = "";
          sidebarToc.appendChild(tree);
          var activeLink = sidebarToc.querySelector("a.active");
          if (activeLink && activeLink.scrollIntoView) {
            activeLink.scrollIntoView({ block: "nearest" });
          }
        }
      })
      .catch(function () {
        /* Keep server-rendered TOC fallback if sitemap fetch is unavailable */
      });
  }

  /* 4. Code Block Copy Buttons */
  var copyLabel = isEs ? "Copiar" : "Copy";
  var copiedLabel = isEs ? "\u00a1Copiado!" : "Copied!";
  var codeBlocks = document.querySelectorAll("div.sourceCode, .reader-content > pre");
  codeBlocks.forEach(function (block) {
    var pre = block.tagName === "PRE" ? block : block.querySelector("pre");
    if (!pre) return;
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.textContent = copyLabel;
    btn.addEventListener("click", function () {
      var text = pre.innerText || pre.textContent || "";
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () {
          btn.textContent = copiedLabel;
          setTimeout(function () {
            btn.textContent = copyLabel;
          }, 1500);
        });
      }
    });
    block.appendChild(btn);
  });
})();
