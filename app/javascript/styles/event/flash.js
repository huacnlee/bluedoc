document.addEventListener('turbolinks:load', () => {
  $('.flash').on('click', '.js-flash-close', (e) => {
    $container = $(e.delegateTarget);
    $container.remove();
  });
});

document.addEventListener('turbolinks:load', () => {
  $('.notice').on('click', '.js-notice-close', (e) => {
    $container = $(e.delegateTarget);
    $container.remove();
  });
});
