import "tocbot/dist/tocbot"

export default class BodyToc {
  static init() {
    // https://tscanlin.github.io/tocbot/#options
    tocbot.init({
      tocSelector: '.doc-body-toc',
      contentSelector: '.markdown-with-toc',
      headingSelector: 'h1, h2, h3, h4, h5',
      headingsOffset: 10,
      includeHtml: true,
      scrollSmooth: false,
    });
  }
}
