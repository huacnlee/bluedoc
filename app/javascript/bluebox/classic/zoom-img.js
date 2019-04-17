import Zooming from 'zooming';

document.addEventListener('turbolinks:load', () => {
  const zooming = new Zooming({});
  zooming.listen('.markdown-body img');
});
