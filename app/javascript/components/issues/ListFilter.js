import AssigneeMenu from "./AssigneeMenu";
import LabelMenu from "./LabelMenu";
const _ = require('underscore');

export default class ListFilter extends React.PureComponent {

  formRef = React.createRef()

  constructor(props) {
    super(props);

    let assignee_id = props.assignee_id || [];
    if (!Array.isArray(assignee_id)) {
      assignee_id = [assignee_id];
    }
    assignee_id = assignee_id.map(id => parseInt(id));
    let label_id = props.label_id || [];
    if (!Array.isArray(label_id)) {
      label_id = [label_id];
    }
    label_id = label_id.map(id => parseInt(id));

    this.state = {
      assignee_ids: assignee_id,
      label_ids: label_id,
      q: props.q,
      needSubmit: null,
    }
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.ListFilter${key}`);
    }
    return i18n.t(key);
  }

  onSelectLabel = (label_id) => {
    let { label_ids } = this.state;

    if (label_ids.includes(label_id)) {
      label_ids = label_ids.filter(id => id != label_id);
    } else {
      label_ids.push(label_id);
    }

    this.setState({ label_ids, needSubmit: new Date() });
  }

  onClearLabel = (e) => {
    e.stopPropagation();
    e.preventDefault();

    this.setState({ label_ids: [], needSubmit: new Date() });

    return false
  }

  onSelectAssignee = (assignee_id) => {
    let { assignee_ids } = this.state;

    if (assignee_ids.includes(assignee_id)) {
      assignee_ids = assignee_ids.filter(id => id != assignee_id);
    } else {
      assignee_ids.push(assignee_id);
    }

    this.setState({ assignee_ids, needSubmit: new Date() });
  }

  onClearAssignee = (e) => {
    e.stopPropagation();
    e.preventDefault();

    this.setState({ assignee_ids: [], needSubmit: new Date() });

    return false
  }

  onSearchKeyUp = (e) => {
    if (e.keyCode == 13) {
      this.setState({ q: e.currentTarget.value, needSubmit: new Date()   });
      return false
    }
  }

  componentDidUpdate = (prevProps, prevState) => {
    const form = this.formRef.current;

    if (prevState.needSubmit != this.state.needSubmit) {
      form.submit();
    }
  }

  render() {
    const { repoURL } = this.props;
    let { assignee_ids, label_ids, q } = this.state;

    return <form action={location.href} data-remote={true} ref={this.formRef} method="GET" className="list-filter">
      <details className="filter-item dropdown details-overlay details-reset d-inline-block">
        <summary>{this.t(".Assignee")} <div className="dropdown-caret"></div></summary>
        <AssigneeMenu {...this.props} onSelect={this.onSelectAssignee} onClear={this.onClearAssignee} selectedIds={assignee_ids} />
        {assignee_ids.map(id => {
          return <input type="hidden" name="assignee_id[]" value={id} />
        })}
      </details>

      <details className="filter-item dropdown details-overlay details-reset d-inline-block">
        <summary>{this.t(".Label")} <div className="dropdown-caret"></div></summary>
        <LabelMenu {...this.props}
          onSelect={this.onSelectLabel}
          onClear={this.onClearLabel}
          selectedIds={label_ids}
          labelsURL={`${repoURL}/issues/labels`} />
        {label_ids.map(id => {
          return <input type="hidden" name="label_id[]" value={id} />
        })}
      </details>

      <div className="filter-item d-inline-block filter-search">
        <input type="text" name="q" className="form-control" placeholder={this.t(".Search")} onKeyUp={this.onSearchKeyUp} defaultValue={q} />
        <i className="fas fa-search"></i>
      </div>
    </form>
  }
}