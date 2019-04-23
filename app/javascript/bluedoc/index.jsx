import Turbolinks from 'turbolinks';

import '@babel/polyfill';
import 'activestorage';
import 'bluebox/classic';
import 'vendor/turbo-react.min';
import { render as timeagoRender } from 'timeago.js';
import i18n from './i18n';
import './rails-ujs-extends';

import './editor/index.js';
import './reader/index.js';
import './versions/index.js';
import './follow-user/index.js';
import './comments/index.js';

Turbolinks.start();
Turbolinks.setProgressBarDelay(150);

window.$ = jQuery;
window.i18n = i18n;

const metaLocale = document.querySelector('meta[name=locale]');
window.App = {
  // en, zh_CN
  locale: (metaLocale && metaLocale.content || 'en').replace('-', '_'),
  host: `${location.protocol}//${location.host}`,

  currentUser: null,

  csrf_param: "authenticity_token",
  csrf_token: null,
  directUploadURL: "/rails/active_storage/direct_uploads",
  blobURLTemplate: "/uploads/:id",

  routes: {
    new_session_path: "/sessions/sign_in",
  },

  /**
   * Alert message
   */
  alert: (message) => {
    if (typeof message != "string") {
      if (message.error) {
        message = message.error.message;
      }
    }
    App.notice(message, 'error');
  },

  notice: (message, type = 'success') => {
    const html = $(`<div class="notice notice-${type}">${message} <i class="notice-close js-notice-close fas fa-cancel"></i></div>`);
    $('.navbar-notice').html(html);

    setTimeout(() => {
      html.remove();
    }, 10000);
  },

  scrollTo: (selector) => {
    const element = document.querySelector(selector);
    element.scrollIntoView({
      behavior: 'smooth',
      block: 'start'
    });
  }
};

document.addEventListener('turbolinks:load', () => {
  timeagoRender(document.querySelectorAll('.timeago'), App.locale);
  App.csrf_token = document.querySelector("meta[name=csrf-token]").getAttribute("content");
  App.csrf_param = document.querySelector("meta[name=csrf-param]").getAttribute("content");
});
