import { UserAvatar } from 'bluebox/avatar';

export default class AssigneeMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      targetAssignees: props.targetAssignees,
    };
  }

  onSelectItem = (e) => {
    e.stopPropagation();
    e.preventDefault();

    const { onSelect } = this.props;

    const assigneeId = parseInt(e.currentTarget.getAttribute('data-id'));
    onSelect(assigneeId);

    return false;
  }

  onFilter = (e) => {
    const input = e.currentTarget;
    const value = input.value.trim();
    let { targetAssignees } = this.state;

    if (value.length > 0) {
      targetAssignees = this.props.targetAssignees.filter(user => user.slug.includes(value) || user.name.includes(value));
    } else {
      targetAssignees = this.props.targetAssignees;
    }

    this.setState({
      targetAssignees,
    });
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.AssigneeMenu${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { selectedIds, onClear } = this.props;
    const { targetAssignees } = this.state;
    const { t } = this;

    return <div className="dropdown-menu dropdown-menu-sw dropdown-menu-filter" style={{ width: '250px', top: '24px', right: '-8px' }}>
    <div className="dropdown-header">
      <div><input type="text" onKeyUp={this.onFilter} className="form-control" placeholder={t('.Filter')} /></div>
      {selectedIds.length > 0 && (
        <div class="mt-1">
          <a href="#" onClick={onClear}><i className="fas fa-times"></i> {t('.Clear All')}</a>
        </div>
      )}
    </div>
    <ul style={{ maxHeight: '200px', overflowY: 'scroll' }}>
    {targetAssignees.map(user => <li>
      <a className="dropdown-item" href="#" data-id={user.id} onClick={this.onSelectItem}>
        <span style={{ width: '20px', display: 'inline-block' }}>
        {selectedIds.includes(user.id) && (
          <i className="fas fa-check"></i>
        )}
        </span>
        <UserAvatar user={user} type="tiny" link={false} />
        <span className="ml-1">{user.name}</span>
      </a>
    </li>)}
    </ul>
    </div>;
  }
}
