document.addEventListener('turbolinks:load', () => {
  $('.notice').on('click', '.js-notice-close', (e) => {
    const $container = $(e.delegateTarget);
    $container.remove();
  });
  setTimeout(() => {
    const noticeEle = document.querySelector('.navbar-notice .notice');
    if (noticeEle) {
      noticeEle.remove();
    }
  }, 3000);
});
