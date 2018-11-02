document.addEventListener("turbolinks:load", () => {
  $(".flash").on("click", ".js-flash-close", (e) => {
    $container = $(e.delegateTarget);
    $container.remove();
  });
})