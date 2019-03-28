import UserAvatar from "../users/UserAvatar";

export default class LabelMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      targetLabels: props.targetLabels,
    }
  }

  onSelect = (userId) => {
    const { onSelect } = this.props;
    onSelect(userId);

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

  render() {
    const { selectedIds, onClear, t } = this.props;
    const { targetLabels } = this.state;

    return <div className="dropdown-menu dropdown-menu-sw" style={{ width: "200px" }}>
    <div className="dropdown-header">
      <div><input type="text" onKeyUp={this.onFilter} className="form-control" placeholder={t(".Filter")} /></div>
      {selectedIds.length > 0 && (
        <div class="mt-2">
          <a href="#" onClick={onClear}><i className="fas fa-times"></i> {t(".Clear All")}</a>
        </div>
      )}
    </div>
    <div className="dropdown-divider"></div>
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
    </div>
  }
}