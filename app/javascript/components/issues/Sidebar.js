import Assignee from "./Assignee";

export default class Sidebar extends React.PureComponent {
  constructor(props) {
    super(props);
  }

  render() {
    return <div className="issue-sidebar">
      <Assignee {...this.props} />
    </div>
  }
}