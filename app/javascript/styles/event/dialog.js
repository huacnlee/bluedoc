document.addEventListener('turbolinks:load', () => {
  $('details').on('click', '[data-close-dialog]', (e) => {
    $container = $(e.delegateTarget);
    $container.removeAttr('open');
  });
});

document.addEventListener('turbolinks:before-cache', () => {
  $('details').removeAttr('open');
});
