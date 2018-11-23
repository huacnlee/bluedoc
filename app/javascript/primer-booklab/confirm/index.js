document.addEventListener("turbolinks:load", () => {
  // confirm input form
  $("input[confirm-for]").on("keyup", (e) => {
    $input = $(e.currentTarget);
    console.log($input);
    let confirmForId = $input.attr("confirm-for");
    if (confirmForId.indexOf("#") === -1) {
      confirmForId = "#" + confirmForId;
    }
    $triggerButton = $(confirmForId);
    $confirmValue = $input.attr("confirm-value").trim();
    if ($input.val().trim() === $confirmValue) {
      $triggerButton.removeAttr("disabled");
    } else {
      $triggerButton.attr("disabled", "");
    }
  })
});
