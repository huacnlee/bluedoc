class DefaultAvatar extends React.Component {
  render() {
    const { user, style } = this.props

    const firstChar = user.slug[0].toUpperCase()
    const idx = firstChar.charCodeAt(0) % 5

    return <span className={`avatar avatar-${style} default-avatar default-avatar-${idx}`}>{firstChar}</span>
  }
}

export default class UserAvatar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { user, style, className, link = true } = this.props;

    let avatarHTML;

    if (!user.avatar_url) {
      avatarHTML = <DefaultAvatar {...this.props} />
    } else {
      avatarHTML = <img src={user.avatar_url} className={`avatar avatar-${style}`} />
    }

    if (!link) {
      return avatarHTML
    }


    return <a className={`user-avatar-link ${className}`} href={`/${user.slug}`} title={user.name}>
      {avatarHTML}
    </a>
  }
}
