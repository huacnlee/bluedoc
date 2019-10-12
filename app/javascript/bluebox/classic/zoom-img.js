class Zooming {
  constructor() {
    this.container = document.querySelector('.zoom-container');
    if (!this.container) {
      this.container = document.createElement('div');
      this.container.classList.add('zoom-container');
      document.body.appendChild(this.container);
    }
    this.container.addEventListener('click', (e) => {
      e.preventDefault();
      document.body.classList.toggle('zoom-img-in');
    });
  }

  listen(elName) {
    const els = document.querySelectorAll(elName);
    els.forEach((el) => {
      el.addEventListener('click', this.click);
    });
  }

  click = (e) => {
    e.preventDefault();
    const el = e.target;
    const newImg = document.createElement('img');
    newImg.src = el.getAttribute('src');
    this.container.innerHTML = `<div class="zoom-inner">${newImg.outerHTML}</div>`;
    document.body.classList.toggle('zoom-img-in');
    // Revert to top scroll
    setTimeout(() => {
      this.container.scrollTop = 0;
    }, 10);
  }
}

document.addEventListener('turbolinks:load', () => {
  const zooming = new Zooming();
  zooming.listen('.markdown-body img');
});
