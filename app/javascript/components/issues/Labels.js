import LabelMenu from "./LabelMenu";

export default class Labels extends React.PureComponent {
  constructor(props) {
    super(props);

    this.menuRef = React.createRef()

    this.state = {
      showMenu: false,
      labels: props.labels,
      selectedIds: props.labels.map(label => label.id),
    }
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`issues.Labels${key}`);
    }
    return i18n.t(key);
  }


  onSelect = (targetId) => {
    this.menuRef.current.removeAttribute("open");

    let { selectedIds } = this.state;

    if (selectedIds.includes(targetId)) {
      selectedIds = selectedIds.filter(id => id != targetId);
    } else {
      selectedIds.push(targetId);
    }

    this.updateLabels(selectedIds);

    return false;
  }

  onClear = (e) => {
    e.stopPropagation();
    e.preventDefault();
    this.updateLabels([]);
    return false;
  }

  updateLabels = (ids) => {
    const { issueURL } = this.props;

    this.setState({
      selectedIds: ids,
    })

    let data = {
      issue: {
        label_id: ids
      }
    }

    if (ids.length == 0) {
      data = { clear: 1 };
    }

    $.ajax({
      url: `${issueURL}/labels`,
      method: "POST",
      data: data,
      success: (res) => {
        if (res.ok) {
          this.setState({
            labels: res.labels,
            selectedIds: res.labels.map(item => item.id),
          })
        }
      }
    })
  }

  render() {
    const { targetLabels, abilities } = this.props;

    const { selectedIds, labels, showMenu } = this.state;

    return <div className="sidebar-box issue-labels">
      <div className="clearfix">
        <h2 className="float-left sub-title ">{this.t(".Label")}</h2>

        {abilities.manage && (
        <details className="dropdown details-overlay details-reset d-inline-block float-right" ref={this.menuRef}>
          <summary><i className="fas fa-gear"></i></summary>
          <LabelMenu {...this.props}
            selectedIds={selectedIds}
            onClear={this.onClear}
            onSelect={this.onSelect}
            t={this.t} />
        </details>
        )}
      </div>

      <div className="label-list">
      {labels.length > 0 && labels.map(item => {
        return <div className="mb-1">
          <a href="#" className="issue-label" style={{ backgroundColor: item.color }}>
            <span className="issue-label-name">{item.title}</span>
          </a>
        </div>
      })}
      {labels.length == 0 && (
        <div className="blankslate">
          {this.t(".No label")}
        </div>
      )}
      </div>
    </div>
  }
}
