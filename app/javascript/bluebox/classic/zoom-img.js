import Zooming from 'zooming';

document.addEventListener('turbolinks:load', () => {
  const zooming = new Zooming({
    customSize: "50%",
    transitionDuration: 0.2,
    bgColor: "#fff",
  });
  zooming.listen('.markdown-body img');
});
