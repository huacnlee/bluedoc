
import Tooltip from 'tooltip.js';

export default class BarButton extends React.Component {
  constructor(props) {
    super(props);

    this.container = React.createRef();
  }

  componentDidMount() {
    const { title } = this.props;
    if (this.container) {
      const el = this.container.current;
      new Tooltip(el, {
        title: title,
        placement: "bottom",
      });
    }
  }

  render() {
    const { icon, title, onMouseDown, active, enable = true } = this.props;

    return <span ref={this.container} className={`bar-button ${active ? 'active' : ''} ${!enable ? 'disabled' : ''}`} onMouseDown={(event) => {
      if (enable) {
        return onMouseDown(event)
      }
      return false;
    }}>
      <i className={`fas fa-text-${icon}`}></i>
    </span>
  }
}
