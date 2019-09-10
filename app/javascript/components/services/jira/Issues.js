export default class Issues extends React.Component {
  constructor(props) {
    super(props);
    this.fetchIssues()
    this.state = { issues: [] }
  }

  fetchIssues() {
    const { fetchUrl } = this.props
    $.ajax({
      url: fetchUrl,
      method: 'GET',
      success: (data) => {
        this.setState({ issues: data })
      },
    });
  }

  render() {
    const { issues } = this.state
    if (issues.length === 0) {
      return <span></span>
    }
    return <div className="service jira">
      <div className="sub-title">关联的 JIRA Issues</div>
      { issues && (
        <ul>
          { issues.map(issue => {
            return <li><a target="_blank" href={ issue.url }><span class='issue-key'>{ issue.key }</span>: { issue.summary }</a></li>
          }) }
        </ul>
      )}
    </div>
  }
}
