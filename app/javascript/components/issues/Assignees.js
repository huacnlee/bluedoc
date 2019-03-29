import UserAvatar from "../users/UserAvatar";
import AssigneeMenu from "./AssigneeMenu";

export default class Assignees extends React.PureComponent {
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
      return i18n.t(`issues.Assignees${key}`);
    }
    return i18n.t(key);
  }


  onSelect = (userId) => {
    this.menuRef.current.removeAttribute("open");

    let { selectedAssigneeIds } = this.state;

    if (selectedAssigneeIds.includes(userId)) {
      selectedAssigneeIds = selectedAssigneeIds.filter(id => id != userId);
    } else {
      selectedAssigneeIds.push(userId);
    }

    this.updateAssignees(selectedAssigneeIds);
  }

  onClear = (e) => {
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
    const { targetAssignees, abilities } = this.props;

    const { selectedAssigneeIds, assignees, showAssigneeMenu } = this.state;

    return <div className="sidebar-box issue-assignee">
      <div className="clearfix">
        <h2 className="float-left sub-title ">{this.t(".Assignee")}</h2>

        {abilities.manage && (
        <details className="dropdown details-overlay details-reset d-inline-block float-right" ref={this.menuRef}>
          <summary><i className="fas fa-gear"></i></summary>
          <AssigneeMenu {...this.props}
            selectedIds={selectedAssigneeIds}
            onClear={this.onClear}
            onSelect={this.onSelect}
            t={this.t} />
        </details>
        )}
      </div>

      <div className="assignee-list">
      {assignees.length > 0 && assignees.map(user => {
        return <div className="assignee-item mb-1">
          <a href={`/${user.slug}`} className="issue-assignee-item">
            <UserAvatar user={user} style="tiny" link={false} />
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
