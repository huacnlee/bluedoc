import UserAvatar from "../users/UserAvatar";

export default class LabelMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      targetLabels: props.targetLabels,
    }
  }

  onSelect = (e) => {
    e.stopPropagation();
    e.preventDefault();

    const { onSelect } = this.props;

    const labelId = parseInt(e.currentTarget.getAttribute("data-id"));
    onSelect(labelId);

    return false
  }

  onFilter = (e) => {
    const input = e.currentTarget;
    const value = input.value.trim();
    let { targetLabels } = this.state;

    if (value.length > 0) {
      targetLabels = this.props.targetLabels.filter(item => {
        return item.title.includes(value);
      })
    } else {
      targetLabels = this.props.targetLabels
    }

    this.setState({
      targetLabels: targetLabels,
    })
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.LabelMenu${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { selectedIds, onClear, labelsURL } = this.props;
    const { targetLabels } = this.state;
    const { t } = this;

    return <div className="dropdown-menu dropdown-menu-sw dropdown-menu-filter" style={{ width: "250px", top: "24px", right: "-8px" }}>
    <div className="dropdown-header">
      <div><input type="text" onKeyUp={this.onFilter} className="form-control" placeholder={t(".Filter")} /></div>
      {selectedIds.length > 0 && (
        <div class="mt-1">
          <a href="#" onClick={onClear}><i className="fas fa-times"></i> {t(".Clear All")}</a>
        </div>
      )}
    </div>
    <ul style={{ maxHeight: "200px", overflowY: "scroll" }}>
    {targetLabels.map(item => {
      return <li>
      <a className="dropdown-item" href="#" data-id={item.id} onClick={this.onSelect}>
        <span style={{ width: "20px", display: "inline-block" }}>
        {selectedIds.includes(item.id) && (
          <i className="fas fa-check"></i>
        )}
        </span>
        <span style={{ backgroundColor: item.color }} className="ml-1 issue-label">{item.title}</span>
      </a>
    </li>
    })}
    </ul>
    {labelsURL && (
      <div className="dropdown-footer">
      <a href={labelsURL} className="float-right">{this.t(".Manage")}</a>
      </div>
    )}
    </div>
  }
}