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

    const avatarUrl = user.avatarUrl || user.avatar_url;

    let avatarHTML;

    if (!avatarUrl) {
      avatarHTML = <DefaultAvatar {...this.props} />;
    } else {
      avatarHTML = <img src={avatarUrl} className={`avatar avatar-${type}`} />;
    }

    if (!link) {
      return <span className={className}>{avatarHTML}</span>;
    }

    return <a className={`user-avatar-link ${className}`} href={`/${user.slug}`} title={user.name}>
      {avatarHTML}
    </a>;
  }
}
