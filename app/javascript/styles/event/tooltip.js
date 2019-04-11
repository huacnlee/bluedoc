import Tooltip from 'tooltip.js';

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll("[data-toggle='tooltip']").forEach(el => {
    new Tooltip(el, {
      placement: "top",
      trigger: "hover",
      title: el.getAttribute("title"),
    });
    el.removeAttribute("title");
  })
})
