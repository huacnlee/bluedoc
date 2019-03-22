export default class Assignee extends React.PureComponent {
  constructor(props) {
    super(props);

    this.menuRef = React.createRef()

    this.state = {
      showAssigneeMenu: false,
      assignees: props.assignees,
      selectedAssigneeIds: props.assignees.map(user => user.id),
    }
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.Assignee${key}`);
    }
    return i18n.t(key);
  }


  onSelectAssignee = (e) => {
    e.stopPropagation();
    e.preventDefault();

    this.menuRef.current.removeAttribute("open");

    const target = e.currentTarget;
    const userId = parseInt(target.getAttribute("data-id"));
    let { selectedAssigneeIds } = this.state;

    if (selectedAssigneeIds.includes(userId)) {
      selectedAssigneeIds = selectedAssigneeIds.filter(id => id != userId);
    } else {
      selectedAssigneeIds.push(userId);
    }

    this.updateAssignees(selectedAssigneeIds);

    return false;
  }

  onClearAssignees = (e) => {
    e.stopPropagation();
    e.preventDefault();
    this.updateAssignees([]);
    return false;
  }

  updateAssignees = (assigneeIds) => {
    const { issueURL } = this.props;

    this.setState({
      selectedAssigneeIds: assigneeIds,
    })

    let data = {
      issue: {
        assignee_id: assigneeIds
      }
    }

    if (assigneeIds.length == 0) {
      data = { clear: 1 };
    }

    $.ajax({
      url: `${issueURL}/assignees`,
      method: "POST",
      data: data,
      success: (res) => {
        if (res.ok) {
          this.setState({
            assignees: res.assignees,
            selectedAssigneeIds: res.assignees.map(user => user.id),
          })
        }
      }
    })
  }

  render() {
    const { assigneeTargets } = this.props;

    const { selectedAssigneeIds, assignees, showAssigneeMenu } = this.state;

    return <div className="issue-assignee">
      <div className="sub-title clearfix">
        <h2 className="float-left">{this.t(".Assignee")}</h2>

        <details className="dropdown details-overlay details-reset d-inline-block float-right" ref={this.menuRef}>
          <summary className="btn btn-sm"><i className="fas fa-gear"></i></summary>
          <AssigneeMenu {...this.props}
            selectedAssigneeIds={selectedAssigneeIds}
            onClearAssignees={this.onClearAssignees}
            onSelect={this.onSelectAssignee}
            t={this.t} />
        </details>
      </div>

      <div className="assignee-list">
      {assignees.length > 0 && assignees.map(user => {
        return <div className="assignee-item mb-1">
          <a href={`/${user.slug}`} className="issue-assignee-item">
            <img src={user.avatar_url} className="avatar avatar-tiny" />
            <span className="ml-1">{user.name}</span>
          </a>
        </div>
      })}
      {assignees.length == 0 && (
        <div className="blankslate">
          {this.t(".No one assigned")}
        </div>
      )}
      </div>
    </div>
  }
}

class AssigneeMenu extends React.Component {
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
        <img src={user.avatar_url} className="avatar avatar-tiny" />
        <span className="ml-1">{user.name}</span>
      </a>
    </li>
    })}
    </ul>
    </div>
  }
}