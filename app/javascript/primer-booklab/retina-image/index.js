// Resize image to 50% size for Retina Display
document.addEventListener("turbolinks:load", () => {
  const bindMarkdownBodyImageToRetina = () => {
    $(".markdown-body img:not(.plantuml-image,.tex-image)").on("load", (e) => {
      const img = e.delegateTarget;
      if (!img.getAttribute("width") && img.naturalWidth) {
        const width = img.naturalWidth;
        img.setAttribute("width", width / 2);
      }
    })
  }

  bindMarkdownBodyImageToRetina();
  // after xhr: true success, bind event again.
  document.addEventListener("ajax:success", () => {
    bindMarkdownBodyImageToRetina();
  });
})