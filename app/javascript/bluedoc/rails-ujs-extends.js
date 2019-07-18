import loginRequiredDialog from 'components/modals/LoginRequiredDialog';

document.addEventListener('turbolinks:load', () => {
  // Rails UJS disable-with
  $('a,button[data-disable]')
    .on('ajax:beforeSend', (event) => {
      // eslint-disable-next-line no-undef
      const $el = $(event.currentTarget);
      // eslint-disable-next-line no-undef
      $el.attr('disabled', 'disabled');
    })
    .on('ajax:complete', (event) => {
      // eslint-disable-next-line no-undef
      const $el = $(event.currentTarget);
      // eslint-disable-next-line no-undef
      $el.removeAttr('disabled');
    })
    .on('ajax:error', (event) => {
      const status = event.detail[1];
      const xhr = event.detail[2];

      switch (xhr.status) {
        case 401:
          loginRequiredDialog();
          break;
        case 403:
          alert('Access denined, status: 403');
          break;
        case 422:
          alert('Submit failed, please refresh browser and retry it.');
          break;
        default:
          alert(`Unknow error with remote submit, status: ${status}`);
          break;
      }
    });
});
