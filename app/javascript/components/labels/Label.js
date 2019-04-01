import { ColorPicker, ColorItem } from "../ColorPicker";

export default class Label extends React.PureComponent {
  constructor(props) {
    super(props);
    this.remoteURL = window.location.pathname;
    this.remoteMethod = "POST";
    if (props.id) {
      this.remoteURL += `/${props.id}`;
      this.remoteMethod = "PUT";
    }

    this.titleRef = React.createRef()
    this.colorRef = React.createRef()
    this.colorPickerContainer = React.createRef()

    this.state = {
      color: this.props.color || "#3070ff",
      editMode: this.props.editMode,
      message: null,
    }
  }

  reload = () => {
    Turbolinks.visit(window.location.pathname);
  }

  onEdit = (e) => {
    e.preventDefault();

    this.setState({ editMode: true })

    return false;
  }

  onSubmit = (e) => {
    e.preventDefault();

    const title = this.titleRef.current.value;
    const color = this.colorRef.current.value;

    $.ajax({
      url: this.remoteURL,
      method: this.remoteMethod,
      data: {
        label: { title, color }
      },
      success: (res) => {
        if (!res.ok) {
          this.setState({ message: res.errors });
        } else {
          this.reload();
        }
      }
    })

    return false;
  }

  onDelete = (e) => {
    e.preventDefault();

    if (!confirm(this.t(".Are you sure delete this Label"))) {
      return false;
    }

    $.ajax({
      url: this.remoteURL,
      method: "DELETE",
      success: (res) => {
        if (!res.ok) {
          this.setState({ message: res.errors });
        } else {
          this.reload();
        }
      }
    })

    return false;
  }

  onCancel = (e) => {
    e.preventDefault();

    this.setState({ editMode: false, message: null })

    return false;
  }

  onChangeColor = (color) => {
    this.colorPickerContainer.current.removeAttribute("open");
    this.setState({ color });
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`labels${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { id, title } = this.props;
    const { editMode, message, color } = this.state;

    const newMode = !id;
    let editBoxClassName = 'label-item-edit';
    if (newMode) {
      editBoxClassName += ' label-item-new';
    }

    if (editMode) {
      return <div className={editBoxClassName}>
        {newMode && (
          <div className="new-title">{this.t(".New Label")}</div>
        )}
        <div className="label-item">
          <div className="issue-title issue-label-box"><input type="text" className="form-control form-control-full" placeholder={this.t(".Label Title")} ref={this.titleRef} defaultValue={title} /></div>
          <div className="label-color">
            <details className="dropdown details-overlay details-reset d-inline-block" ref={this.colorPickerContainer}>
              <summary><ColorItem color={color} /></summary>
              <input type="hidden" ref={this.colorRef} defaultValue={color} />
              <ColorPicker onChange={this.onChangeColor} className="dropdown-menu-ne" color={color} />
            </details>
          </div>
          <div className="buttons">
            <a href="#" onClick={this.onSubmit} className="btn btn-primary btn-sm">{ id ? this.t(".Update") : this.t(".Create")}</a>
            {!newMode && (
              <a href="#" onClick={this.onCancel} className="btn btn-sm ml-1">{this.t(".Cancel")}</a>
            )}
          </div>
          {message && (
            <div className="message">{message}</div>
          )}
        </div>
      </div>
    }

    return <div className="label-item">
      <div className="issue-label-box">
        <div className="issue-label" style={{ backgroundColor: color }}>{title}</div>
      </div>
      <div className="label-color">{color}</div>
      <div className="actions">
        <a href="#" className="btn btn-link" onClick={this.onEdit}>{this.t(".Edit")}</a>
        <a href="#" className="btn btn-link ml-1" onClick={this.onDelete}>{this.t(".Delete")}</a>
      </div>
    </div>
  }
}