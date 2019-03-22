export default class UserAvatar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { user, style } = this.props;

    return <a className="user-avatar-link" href={`/${user.slug}`} title={user.name}>
      <img src={user.avatar_url} className={`avatar avatar-${style}`} />
    </a>
  }
}