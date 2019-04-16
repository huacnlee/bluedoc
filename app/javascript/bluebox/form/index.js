const { Component } = React;

export const Form = React.forwardRef((props, ref) => (
  <form {...props} ref={ref}>
    <input type="hidden" name={App.csrf_param} value={App.csrf_token} />
    {props.children}
  </form>
));

export class FormGroup extends Component {
  render() {
    let { className, children, name, object } = this.props;
    const { errors } = object;

    className = `form-group ${className}`;
    let errorMessage = null;
    if (errors[name]) {
      errorMessage = errors[name];
      className += " has-error";
    }

    return <div className={className} {...this.props}>
      {children}
      {errorMessage && (
        <div className="form-error">{errorMessage}</div>
      )}
    </div>
  }
}

export class ControlLabel extends Component {
  render() {
    return <label className="control-label">{this.props.name || this.props.title}</label>
  }
}
