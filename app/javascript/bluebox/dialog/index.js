// eslint-disable-next-line import/no-extraneous-dependencies
import React, { Component } from 'react';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogTitle from '@material-ui/core/DialogTitle';

export default class DialogComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: this.props.open,
    };
  }

  static getDerivedStateFromProps(nextprops) {
    return {
      open: nextprops.open,
    };
  }


  render() {
    const {
      open, title, children, actionsEle, content, onClose,
    } = this.props;
    return (
      <Dialog
        open={open}
        onClose={onClose}
        onExited={this.props.afterClose}
        aria-labelledby="form-dialog-title"
      >
        <DialogTitle id="form-dialog-title">{title}</DialogTitle>
        <DialogContent style={{ minWidth: 400 }}>
          {children || content || ''}
        </DialogContent>
        <DialogActions style={{ margin: '0 24px 24px 24px' }}>
          {actionsEle || (
            <button className='btn' onClick={this.handleClose}>{window.i18n.t('.dialog.Cancel')}</button>
          )}
        </DialogActions>
      </Dialog>
    );
  }
}
