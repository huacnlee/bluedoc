document.addEventListener("turbolinks:load", () => {
  $("details").on("click", "[data-close-dialog]", (e) => {
    $container = $(e.delegateTarget);
    $container.removeAttr("open");
  });

  $("details").on("mousedown", (e) => {
    $("details").removeAttr("open");
  })
})
