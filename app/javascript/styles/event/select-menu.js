document.addEventListener('turbolinks:load', () => {
  // fix select-menu selected to button text on page reload
  $('.js-navigation-item.selected').trigger('click');
});
