document.addEventListener('turbolinks:load', () => {
  $('.notice').on('click', '.js-notice-close', (e) => {
    const $container = $(e.delegateTarget);
    $container.remove();
  });
});
