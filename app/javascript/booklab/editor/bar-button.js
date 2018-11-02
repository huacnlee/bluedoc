export class BarButton extends React.Component {
  render() {
    const { icon, title, onMouseDown, active } = this.props;

    const iconClassName = "svg-ic-dims svg-ic_" + icon + "_24px";

    let className = "bar-button";
    if (this.props.active) {
      className = className + " active";
    }

    return <button title={title} className={className} onMouseDown={onMouseDown}>
      <i className={iconClassName}></i>
    </button>
  }
}
