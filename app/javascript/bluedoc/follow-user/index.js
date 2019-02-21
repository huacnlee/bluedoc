/*
  exports:

  - click .btn-follow-user
  - followers-count[data-login=user-slug]
*/
document.addEventListener('turbolinks:load', () => {
  $('body').on('click', '.btn-follow-user', (e) => {
    e.preventDefault();
    const btn = $(e.currentTarget);
    const userId = btn.data('id');
    const label = btn.data('label');
    const undoLabel = btn.data('undo-label');
    const followerCounter = $(`.followers-count[data-login='${userId}']`);

    if (btn.hasClass('active')) {
      $.ajax({
        url: `/${userId}/unfollow`,
        type: 'DELETE',
        success: (res) => {
          btn.removeClass('active');
          btn.text(label);
          followerCounter.text(res.count);
        },
      });
    } else {
      $.ajax({
        url: `/${userId}/follow`,
        type: 'POST',
        success: (res) => {
          btn.addClass('active').attr('title', '');
          btn.text(undoLabel);
          followerCounter.text(res.count);
        },
      });
    }
    return false;
  });
});
