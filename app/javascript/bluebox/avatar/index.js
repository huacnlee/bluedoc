export class DefaultAvatar extends React.Component {
  render() {
    const { user, type = 'small' } = this.props;

    const firstChar = user.slug[0].toUpperCase();
    const idx = firstChar.charCodeAt(0) % 10;

    return <span className={`avatar avatar-${type} default-avatar default-avatar-${idx}`}>{firstChar}</span>;
  }
}

export class UserAvatar extends React.Component {
  render() {
    const {
      user, type = 'small', className, link = true,
    } = this.props;

    let avatarHTML;

    if (!user.avatar_url) {
      avatarHTML = <DefaultAvatar {...this.props} />;
    } else {
      avatarHTML = <img src={user.avatar_url} className={`avatar avatar-${type}`} />;
    }

    if (!link) {
      return <span className={className}>{avatarHTML}</span>;
    }

    return <a className={`user-avatar-link ${className}`} href={`/${user.slug}`} title={user.name}>
      {avatarHTML}
    </a>;
  }
}
