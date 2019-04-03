export class Icon extends React.Component {
  render() {
    const { name, className } = this.props;

    let finalClassName = `fas fa-${name}`;
    if (className) {
      finalClassName += " " + className;
    }

    return <i className={finalClassName} />
  }
}