export class UserLink extends React.Component {
  render() {
    const { user, className } = this.props;

    let linkClassName = "user-name";
    if (className) {
      linkClassName += ` ${className}`;
    }

    return <a href={user.path} className={linkClassName}>{user.name}</a>
  }
}
