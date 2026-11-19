/* Score a scroll progress bar in the header's top border. */
(function () {
  "use strict";

  var bar = document.querySelector("[data-scroll-progress]");
  if (!bar) return;

  var ticking = false;

  function update() {
    ticking = false;

    var doc = document.documentElement;
    var viewport = window.innerHeight;
    var scrollable = doc.scrollHeight - viewport;

    var progress = 0;
    if (scrollable > 0) {
      progress = Math.min(1, Math.max(0, window.pageYOffset / scrollable));
    }

    bar.style.transform = "scaleX(" + progress + ")";
  }

  function onScroll() {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(update);
  }

  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll);
  window.addEventListener("load", update);

  // Handle a restored scroll position on reload.
  update();
})();
