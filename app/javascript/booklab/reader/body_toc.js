export default class BodyToc {
  static init() {
    const $container = $(".doc-body-toc");
    const $markdownBody = $(".doc-main .markdown-body.markdown-with-toc");
    if ($markdownBody.length == 0) {
      return
    }

    let $bodyToc = $(".markdown-body-toc");

    if ($bodyToc.length == 0) {
      $bodyToc = $('<ul class="markdown-body-toc"></ul>');
      $container.html($bodyToc);
    }

    const lines = $markdownBody.find("h2,h3,h4,h5")
    if (lines.length == 0) {
      $container.hide();
    }
    const tocItems = [];
    lines.each((idx) => {
      const line = lines[idx];
      const depth = line.tagName.replace("H", "")
      const text = line.textContent.replace(/^#/, "")
      const link = '<a href="#'+ line.id +'" class="item-link">' + text + '</a>';
      tocItems.push('<li class="body-toc-item body-toc-item-'+ depth +'">'+ link +'</li>');
    });
    $bodyToc.html(tocItems.join(""));
  }
}
