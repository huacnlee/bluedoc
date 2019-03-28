import UserAvatar from "../users/UserAvatar";

export default class AssigneeMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      assigneeTargets: props.assigneeTargets,
    }
  }

  onSelectItem = (userId) => {
    const { onSelect } = this.props;
    onSelect(userId);

    return false
  }

  onFilter = (e) => {
    const input = e.currentTarget;
    const value = input.value.trim();
    let { assigneeTargets } = this.state;

    if (value.length > 0) {
      assigneeTargets = this.props.assigneeTargets.filter(user => {
        return user.slug.includes(value) || user.name.includes(value);
      })
    } else {
      assigneeTargets = this.props.assigneeTargets
    }

    this.setState({
      assigneeTargets: assigneeTargets,
    })
  }

  render() {
    const { selectedAssigneeIds, onClearAssignees, t } = this.props;
    const { assigneeTargets } = this.state;

    return <div className="dropdown-menu dropdown-menu-sw" style={{ width: "200px" }}>
    <div className="dropdown-header">
      <div><input type="text" onKeyUp={this.onFilter} className="form-control" placeholder={t(".Filter")} /></div>
      {selectedAssigneeIds.length > 0 && (
        <div class="mt-2">
          <a href="#" onClick={onClearAssignees}><i className="fas fa-times"></i> {t(".Clear All")}</a>
        </div>
      )}
    </div>
    <div className="dropdown-divider"></div>
    <ul style={{ maxHeight: "200px", overflowY: "scroll" }}>
    {assigneeTargets.map(user => {
      return <li>
      <a className="dropdown-item" href="#" data-id={user.id} onClick={this.onSelectItem}>
        <span style={{ width: "20px", display: "inline-block" }}>
        {selectedAssigneeIds.includes(user.id) && (
          <i className="fas fa-check"></i>
        )}
        </span>
        <UserAvatar user={user} style="tiny" link={false} />
        <span className="ml-1">{user.name}</span>
      </a>
    </li>
    })}
    </ul>
    </div>
  }
}