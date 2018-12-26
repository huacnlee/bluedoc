export class BarButton extends React.Component {
  render() {
    const { icon, title, onMouseDown, active } = this.props;

    let iconClassName = "fas fa-text-" + icon;

    let className = "bar-button";
    if (this.props.active) {
      className = className + " active";
    }

    return <button title={title} className={className} onMouseDown={onMouseDown}>
      <i className={iconClassName}></i>
    </button>
  }
}
