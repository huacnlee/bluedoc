import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

class LoginRequiredDialog extends React.Component {
  state = {
    open: true,
  };

  handleCancel = () => {
    this.setState({
      open: false,
    });
  };

  handleLogin = () => {
    window.location.href = '/account/sign_in';
  };

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`user.loginRequiredDialog${key}`);
    }
    return i18n.t(key);
  };

  render() {
    return (
      <div>
        <Dialog
          open={this.state.open} onClose={this.handleClose}
          aria-labelledby="alert-dialog-title"
          aria-describedby="alert-dialog-description"
        >
          <DialogTitle id="alert-dialog-title">{this.t('.title')}</DialogTitle>
          <DialogContent>
            <DialogContentText id="alert-dialog-description">
              {this.t('.description')}
            </DialogContentText>
          </DialogContent>
          <DialogActions>
            <Button onClick={this.handleCancel} color="primary">
              {this.t('.cancelButtonTitle')}
            </Button>
            <Button onClick={this.handleLogin} color="primary" autoFocus>
              {this.t('.okButtonTitle')}
            </Button>
          </DialogActions>
        </Dialog>
      </div>
    );
  }
}

export default function () {
  // eslint-disable-next-line no-case-declarations
  const mountedDom = document.createElement('div');
  document.body.appendChild(mountedDom);
  ReactDOM.render(<LoginRequiredDialog/>, mountedDom);
}
