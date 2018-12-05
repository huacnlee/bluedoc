import ClipboardJS from "clipboard"

document.addEventListener("turbolinks:load", () => {
  const clipboard = new ClipboardJS("clipboard-copy");
  clipboard.on("success", (e) => {
    const $target = $(e.trigger);
    let $tipTarget = $(e.trigger);

    // data-clipboard-tooltip-target
    if ($target.attr("data-clipboard-tooltip-target")) {
      $tipTarget = $($target.attr("data-clipboard-tooltip-target"));
    }
    let messge = "Copy successed";
    // data-clipboard-message="Copy successed"
    if ($target.attr("data-clipboard-message")) {
      messge = $target.attr("clipboard-success-text");
    }

    // show tooltip, and deplay 5s to remove tooltip
    $tipTarget.addClass("tooltipped tooltipped-sticky tooltipped-s");
    $tipTarget.attr("aria-label", messge);
    setTimeout(() => $tipTarget.removeClass("tooltipped"), 5000)
  })
});