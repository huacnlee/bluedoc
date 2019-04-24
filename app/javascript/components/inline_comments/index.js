import Drawer from '@material-ui/core/Drawer';
import { Icon } from 'bluebox/iconfont';
import Comments from '../comments/Index';

export default class InlineComments extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      nid: null,
      commentableType: props.commentableType,
      commentableId: props.commentableId,
      open: false,
    };
  }

  open = (props) => {
    this.setState({
      nid: props.nid,
      open: true,
    });
  }

  handleClose = (e) => {
    if (e) {
      e.preventDefault();
    }
    this.setState({
      open: false,
    });

    return false;
  };

  render() {
    const {
      open, nid, commentableType, commentableId,
    } = this.state;

    if (!nid) {
      return false;
    }

    return (
      <Drawer
        anchor="right"
        open={open}
        onClose={this.handleClose}>
        <div style={{ position: 'relative', margin: '15px' }}>
          <a className="btn-close" href="#" onClick={this.handleClose} style={{ position: 'absolute', right: '8px', top: '15px;' }}><Icon name="times" /></a>
          <Comments commentableType={commentableType} commentableId={commentableId} nid={nid} type="inline" />
        </div>
      </Drawer>
    );
  }
}
