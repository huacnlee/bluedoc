// eslint-disable-next-line import/no-extraneous-dependencies
import { PureComponent } from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';
import Hotkeys from 'hotkeys-js';

export default class ReactHotkeys extends PureComponent {
  constructor(props) {
    super(props);
    this.handle = {};
  }

  componentDidMount() {
    Hotkeys.unbind(this.props.keyName);
    Hotkeys(this.props.keyName, this.onKeyDown);
  }

  componentWillUnmount() {
    Hotkeys.unbind(this.props.keyName);
    this.handle = {};
  }

  onKeyDown = (e, handle) => {
    const { onKeyDown } = this.props;
    this.handle = handle;
    onKeyDown(handle.shortcut, e, handle);
  }

  render() {
    return this.props.children || null;
  }
}

ReactHotkeys.propTypes = {
  keyName: PropTypes.string,
  onKeyDown: PropTypes.func,
};

ReactHotkeys.defaultProps = {
  onKeyDown() { },
};
