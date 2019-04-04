document.addEventListener('turbolinks:load', () => {
  $('body').on('click', '.notice .js-notice-close', (e) => {
    const $container = $(e.currentTarget).closest(".notice");
    $container.fadeOut().remove();
  });
  setTimeout(() => {
    const noticeEle = document.querySelector('.navbar-notice .notice');
    if (noticeEle) {
      noticeEle.remove();
    }
  }, 10000);
});
