export default class ErrorMessages extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      hidden: false,
    };
  }

  dismiss = (e) => {
    e.preventDefault();
    this.setState({ hidden: true });
    return false;
  }

  render() {
    const { messages } = this.props;
    const { hidden } = this.state;

    if (hidden || messages.length === 0) {
      return null;
    }

    return (
      <div className="notice notice-block notice-error">
        <p className="mb-2 text-main notice-title"
          dangerouslySetInnerHTML={{ __html: i18n.t('There has count issues', { count: messages.length }) }}
        />
        <ul className="notice-lists">
          {messages.map(message => <li>{message}</li>)}
        </ul>
      </div>
    );
  }
}
