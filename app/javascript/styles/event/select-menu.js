document.addEventListener('turbolinks:load', () => {
  // Active selected item or first item
  let selectedItem = $(".js-navigation-item.selected");
  if (selectedItem.length === 0) {
    selectedItem = $(".js-navigation-item").first();
  }
  selectedItem.trigger('click');
});

// Store current actived container
let activeContainer = null;

// Active menu
const activate = function(container) {
  // Deactivate any open menu
  if (activeContainer) {
    deactivate(activeContainer);
  }

  // Bind event listeners
  $(document).on('click.menu', onDocumentClick);
  activeContainer = container;

  document.body.classList.add('menu-active');
  container.classList.add('active');
};

// Deactivate menu
const deactivate = function(container) {
  // Unbind event listeners
  $(document).off('.menu');
  activeContainer = null;
  document.body.classList.remove('menu-active');
  container.classList.remove('active');
};

// Handle document click event
const onDocumentClick = function(event) {
  if (!activeContainer) {
    return;
  }

  if (!$(event.target).closest(activeContainer)[0]) {
    event.preventDefault();
    // If its outside, deactivate the menu
    deactivate(activeContainer);
  }
};

// Handle container click event
$(document).on('click', '.js-menu-container', function(event) {
  var container, content, target;
  container = this;
  // target is clicked
  if (target = $(event.target).closest('.js-menu-target')[0]) {
    event.preventDefault();
    if (container === activeContainer) {
      deactivate(container);
    } else {
      activate(container);
    }
  } else if (content = $(event.target).closest('.js-menu-content')[0]) {
  // do nothing
  } else if (container === activeContainer) {
    event.preventDefault();
    deactivate(container);
  }
});

// select item event to set button text
$(document).on("click", ".js-navigation-item", function(e) {
  const $target = $(e.currentTarget);
  const container = $target.closest('.js-menu-container');
  // Update context button text
  const text = $target.find('.js-select-button-text');
  if (text[0]) {
    container.find('.js-select-button').html(text.html());
  }

  container.find(".js-navigation-item").removeClass("selected");
  $target.addClass("selected")

  deactivate(container[0]);
})

// Handle close click event
$(document).on('click', '.js-menu-container .js-menu-close', function(event) {
  deactivate($(this).closest('.js-menu-container')[0]);
  event.preventDefault();
});