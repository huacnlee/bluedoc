document.addEventListener("turbolinks:load", () => {
  $("auto-complete").on("autocomplete:dismiss", (e) => {
    const $container = $(e.delegateTarget);
    const $list = $("#" + $container.attr("aria-owns"));
    $list.empty();
  });

  $("auto-complete").on("keyup", "input[aria-autocomplete=list]", (e) => {
    const $input = $(e.currentTarget);
    const $container = $(e.delegateTarget);
    const $list = $("#" + $container.attr("aria-owns"));
    const remoteURL = $container.attr("src");

    $container.addClass("is-auto-complete-loading");

    $.ajax({
      url: remoteURL,
      method: "GET",
      data: {
        q: $input.val()
      },
      success: (html) => {
        $container.removeClass("is-auto-complete-loading");

        $list.html(html);
        if ($("li", $list).size == 0) {
          $container.trigger("autocomplete:dismiss");
        }
      }
    });
  });

  $("auto-complete").on("click", ".autocomplete-item", (e) => {
    const $item = $(e.currentTarget);
    const $container = $(e.delegateTarget);
    const $input = $("input", $container);
    $input.val($item.attr("data-value"));
    $container.trigger("autocomplete:dismiss");
  })
})