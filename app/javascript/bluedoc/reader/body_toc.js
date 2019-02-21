import "tocbot/dist/tocbot"

export default class BodyToc {
  static init() {
    // https://tscanlin.github.io/tocbot/#options
    tocbot.init({
      tocSelector: '.doc-body-toc',
      contentSelector: '.markdown-with-toc',
      headingSelector: 'h1:not(:empty), h2:not(:empty), h3:not(:empty), h4:not(:empty), h5:not(:empty)',
      headingsOffset: 10,
      includeHtml: true,
      scrollSmooth: false,
    });
  }
}
