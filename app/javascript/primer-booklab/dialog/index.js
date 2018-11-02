document.addEventListener("turbolinks:load", () => {
  $("details").on("click", "button[data-close-dialog]", (e) => {
    $container = $(e.delegateTarget);
    $container.removeAttr("open");
  });
})
