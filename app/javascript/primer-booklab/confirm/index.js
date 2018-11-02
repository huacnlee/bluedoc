document.addEventListener("turbolinks:load", () => {
  const $dialog = $(`
  <details-dialog id="global-confirm-dialog" class="Box Box--overlay d-flex flex-column anim-fade-in fast">
    <div class="Box-header">
      <h3 class="Box-title">Confirm</h3>
    </div>
    <div class="Box-body overflow-auto">
    </div>
    <div class="Box-footer">
      <button type="button" autofocus class="btn btn-ok primary">Ok</button>
      <button type="button" data-close-dialog class="btn btn-cancel">Cancel</button>
    </div>
  </details>`);

  $dialog.on("click", ".btn-cancel", (e) => {
    e.preventDefault();
    $dialog.remove();
  });

  function confirmAction(link) {
    if (link.data("confirm") == undefined){
      return true;
    }

    $dialog.remove();
    $("body").append($dialog);
    $($dialog, ".Box-body").html(link.data("confirm"));
    $dialog.once("click", ".btn-ok", () => {
      $dialog.hide();
      Rails.fire(link, 'confirm:complete', [true]);
      return false;
    });
  }

  Rails.confirm = function(message, element) {
    let $element = $(element)
    confirmAction($element);
    return false;
  }

  // Rails.handleConfirm = (e) => {
  //   Rails.stopEverything(e);
  //
  //   confirmAction(link);
  //   return false;
  // }
});
