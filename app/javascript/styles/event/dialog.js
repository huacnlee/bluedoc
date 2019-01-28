document.addEventListener('turbolinks:load', () => {
  $(document).on('click', 'details [data-close-dialog]', (e) => {

    $link = $(e.currentTarget);
    $container = $link.closest("[open]");
    $container.removeAttr('open');
  });
});

document.addEventListener('turbolinks:before-cache', () => {
  $('details').removeAttr('open');
});
