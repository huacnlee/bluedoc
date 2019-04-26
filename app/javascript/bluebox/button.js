const { Component } = React;

export class Button extends Component {
  constructor(props) {
    super(props);

    this.state = {
      disabled: props.disabled || false,
      children: props.children,
    };
  }

  onClick = (e) => {
    e.preventDefault();

    const { onClick, disableWith } = this.props;

    if (disableWith) {
      this.setState({
        disabled: true,
      });
    }

    if (onClick) {
      onClick(e);
    }

    return false;
  };

  render() {
    const { children, className = '' } = this.props;
    const { disabled } = this.state;

    const newClassName = `btn ${className}`;

    return (
      <button {...this.props} className={newClassName} disabled={disabled} onClick={this.onClick}>
        {children}
      </button>
    );
  }
}

export class PrimaryButton extends Button {
  render() {
    const { children, className } = this.props;

    return (
      <Button {...this.props} className={`btn-primary ${className}`}>
        {children}
      </Button>
    );
  }
}
