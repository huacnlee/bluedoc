document.addEventListener("turbolinks:load", () => {
  // Rails UJS disable-with
  $("a,button[data-disable]").on("ajax:beforeSend", (event) => {
    $el = $(event.currentTarget);
    $el.attr("disabled", "disabled")
  }).on("ajax:complete", (event) => {
    $el = $(event.currentTarget);
    $el.removeAttr("disabled");
  });
})
