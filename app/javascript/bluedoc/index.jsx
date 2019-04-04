import Turbolinks from 'turbolinks';

import '@babel/polyfill';
import 'activestorage';
import 'styles/event';
import 'vendor/turbo-react.min';
import { render as timeagoRender } from 'timeago.js';
import i18n from "./i18n";
import './rails-ujs-extends';

Turbolinks.start();
Turbolinks.setProgressBarDelay(150);

window.$ = jQuery;
window.i18n = i18n;

const metaLocale = document.querySelector('meta[name=locale]');
window.App = {
  // en, zh_CN
  locale: (metaLocale && metaLocale.content || 'en').replace('-', '_'),

  /**
   * Alert message
   */
  alert: (message) => {
    App.notice(message, "error");
  },

  notice: (message, type = "success") => {
    const html = $(`<div class="notice notice-${type}">${message} <i class="notice-close js-notice-close fas fa-cancel"></i></div>`);
    $(".navbar-notice").html(html);

    setTimeout(() => {
      html.remove();
    }, 10000);
  }
};

document.addEventListener('turbolinks:load', () => {
  timeagoRender(document.querySelectorAll('.timeago'), App.locale);
});

import './editor/index.js';
import './reader/index.js';
import './versions/index.js';
import './follow-user/index.js';
import './comments/index.js';
import './toc-editor/index.js';
