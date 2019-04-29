/* eslint-disable import/no-extraneous-dependencies */
import React from 'react';
import ReactDOM from 'react-dom';
import UpdateDialog from './EditModal';
import CreateDialog from './NewModal';

const ConfirmDialog = (props) => {
  const { type } = props;
  if (type === 'updateToc') {
    return <UpdateDialog {...props} />;
  }
  if (type === 'createToc') {
    return <CreateDialog {...props} />;
  }
  return null;
};

export default function dialog(config) {
  const div = document.createElement('div');
  document.body.appendChild(div);

  let currentConfig = {
    ...config,
    close,
    open: true,
    afterClose: destory.bind(this),
  };

  function close() {
    currentConfig = {
      ...currentConfig,
      open: false,
    };
    render(currentConfig);
  }

  function update(newConfig) {
    currentConfig = {
      ...currentConfig,
      ...newConfig,
    };
    render(currentConfig);
  }

  function destory() {
    const unmountResult = ReactDOM.unmountComponentAtNode(div);
    if (unmountResult && div.parentNode) {
      div.parentNode.removeChild(div);
    }
  }

  function render(props) {
    ReactDOM.render(<ConfirmDialog {...props} />, div);
  }

  render(currentConfig);

  return {
    close,
    update,
  };
}
