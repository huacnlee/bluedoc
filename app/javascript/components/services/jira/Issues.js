export default class Issues extends React.Component {
  constructor(props) {
    super(props);
    this.fetchIssues();
    this.state = { issues: [] };
  }

  fetchIssues() {
    const { fetchUrl } = this.props;
    $.ajax({
      url: fetchUrl,
      method: 'GET',
      success: (data) => {
        this.setState({ issues: data });
      },
    });
  }

  render() {
    const { issues } = this.state;
    if (issues.length === 0) {
      return <span></span>;
    }
    return <div className="service jira">
      <div className="sub-title">{ i18n.t('services.jira.Issues.Jira Issues') }</div>
      <div className="description">{ i18n.t('services.jira.Issues.The relation Jira issues that mentioned in this document')}</div>
      { issues && (
        <ul>
          { issues.map(issue => <li><a target="_blank" href={ issue.url }>{ issue.summary } <span class='issue-key'>{ issue.key }</span></a></li>) }
        </ul>
      )}
    </div>;
  }
}
