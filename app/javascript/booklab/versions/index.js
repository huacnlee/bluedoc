const htmlDiff = require("htmldiff/src/htmldiff.js");

document.addEventListener('turbolinks:load', () => {
  if ($(".version-sidebar").length === 0) {
    return;
  }

  const contentView = $(".version-preview");
  const diffView = $(".version-diff");
  const toggleInput = $("#version-diff-toggle")[0];

  const renderDiff = () => {
    if (toggleInput.checked) {
      const currentHTML = $(".version-preview .markdown-body").html();
      const previousHTML = $("#previus-version-content").html();
      const diffHTML = htmlDiff(previousHTML, currentHTML);
      $(".version-diff .markdown-body").html(diffHTML);
    }
  }

  // Toggle Diff mode
  $("#version-diff-toggle").on("click", (e) => {
    if (toggleInput.checked) {
      contentView.hide();
      diffView.show();
      renderDiff();
    } else {
      contentView.show();
      diffView.hide();
    }
  })

  // listen diff render event
  $(".version-preview").on("render:diff", renderDiff);
  $(".version-preview").trigger("diff");
})