document.addEventListener('turbolinks:load', () => {
  if ($(window).width() > 768) {
    $('details.js-menu').attr('open', 'open');
  }
  $(window).resize(() => {
    if ($(window).width() > 768) {
      $('details.js-menu').attr('open', 'open');
    } else {
      $('details.js-menu').removeAttr('open');
    }
  });
  $('details.js-menu').on('tap', 'a.menu-item', (event) => {
    if ($(window).width() <= 768) {
      $('details.js-menu').removeAttr('open');
    }
  });
});
