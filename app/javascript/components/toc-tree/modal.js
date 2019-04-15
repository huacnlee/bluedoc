
import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogTitle from '@material-ui/core/DialogTitle';
import { updateToc } from './api';

class ConfirmDialog extends Component {
  constructor(props) {
    super(props);

    this.state = {
      open: this.props.open,
    };

    this.titleRef = React.createRef();
    this.urlRef = React.createRef();
  }

  handleClose = () => this.setState({ open: false })

  handleConfirm = () => {
    const { info: { id }, onSuccessBack } = this.props;
    const title = this.titleRef.current.value;
    const url = this.urlRef.current.value;
    const params = {
      id,
      title,
      url,
    };

    this.setState({
      loading: true,
    }, () => {
      updateToc(params).then((result) => {
        App.notice(this.props.t('.Toc has successfully updated'));
        onSuccessBack && onSuccessBack();
        this.setState({ loading: false }, this.handleClose);
      });
    });
  }

  render() {
    const { open } = this.state;
    const { info = {}, t } = this.props;
    const { url, title } = info;
    return (
      <Dialog
        open={open}
        onClose={this.handleClose}
        aria-labelledby="form-dialog-title"
      >
        <DialogTitle id="form-dialog-title">{t('.Setting Doc')}</DialogTitle>
        <DialogContent style={{ minWidth: 400 }}>
          <form>
            <div className='form-group'>
              <label className='control-label'>{t('.title')}</label>
              <input className='form-control' type='text' defaultValue={title} ref={this.titleRef}/>
            </div>
            <div className='form-group'>
              <label className='control-label'>{t('.url')}</label>
              <input className='form-control' type='text' defaultValue={url} ref={this.urlRef}/>
            </div>
          </form>
        </DialogContent>
        <DialogActions style={{ margin: '0 24px 24px 24px' }}>
          <button className='btn' onClick={this.handleClose}>取消</button>
          <button className='btn btn-primary' onClick={this.handleConfirm}>确认</button>
        </DialogActions>
      </Dialog>
    );
  }
}

export default function confirm(config) {
  const div = document.createElement('div');
  document.body.appendChild(div);
  let currentConfig = { ...config, close, open: true };

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

  function render(props) {
    ReactDOM.render(<ConfirmDialog {...props}/>, div);
  }

  render(currentConfig);

  return {
    close,
    update,
  };
}
