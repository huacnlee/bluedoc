import ClipboardJS from 'clipboard';
import Tooltip from 'tooltip.js';

const languages = {
  "en": {
    "Copy successed": "Copy successed",
  },
  "zh-CN": {
    "Copy successed": "复制成功",
  },
}

document.addEventListener('turbolinks:load', () => {
  let locale = "en";
  const metaLocale = document.querySelector("meta[name=locale]");
  if (metaLocale) {
    locale = metaLocale.getAttribute("content");
  }
  const lang = languages[locale];
  const clipboard = new ClipboardJS('clipboard-copy');
  clipboard.on('success', (e) => {
    const $target = $(e.trigger);
    let $tipTarget = $(e.trigger);

    // data-clipboard-tooltip-target
    if ($target.attr('data-clipboard-tooltip-target')) {
      $tipTarget = $($target.attr('data-clipboard-tooltip-target'));
    }
    let message = lang["Copy successed"];
    // data-clipboard-message="Copy successed"
    if ($target.attr('data-clipboard-message')) {
      message = $target.attr('clipboard-success-text');
    }

    const tooltip = new Tooltip($tipTarget, {
      title: message,
      trigger: "trigger",
      closeOnClickOutside: true,
    });
    tooltip.show()

    setTimeout(() => tooltip.hide(), 5000);
  });
});
