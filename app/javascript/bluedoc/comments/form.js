export default class CommentForm {
  static init() {
    if ($(".new_comment").length === 0) {
      return;
    }

    const $form = $(".new_comment");

    // close reply
    $(".in-reply-info", $form).on("click", ".close", (e) => {
      const $info = $(e.delegateTarget);
      $info.html("");
      $("input[name='comment[parent_id]']", $form).val("");
      return false;
    });
  }
}