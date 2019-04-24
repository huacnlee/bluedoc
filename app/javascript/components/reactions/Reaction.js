import { Tooltip } from 'bluebox/tooltip';

export default class Reaction extends React.Component {
  constructor(props) {
    super(props);

    this.itemRef = React.createRef()
  }

  onClick = (e) => {
    e.preventDefault();

    const active = e.currentTarget.className.includes("selected");

    const { onSelect, reaction } = this.props;

    if (onSelect) {
      if (active) {
        onSelect(reaction.name, 'unset');
      } else {
        onSelect(reaction.name, 'set');
      }
    }

    return false;
  }


  t = (key, opts = {}) => {
    if (key.startsWith('.')) {
      return i18n.t(`reactions.reaction${key}`, opts);
    }
    return i18n.t(key);
  }

  render() {
    const { reaction, className = '' } = this.props;
    const { t } = this;
    let btnClassName = `reaction-item ${className}`;

    const { currentUser = {} } = App;

    const existSlugs = reaction.groupUserSlugs || reaction.group_user_slugs || [];
    const active = existSlugs.includes(currentUser.slug);

    let title = '';
    if (existSlugs.length > 0) {
      title = existSlugs.slice(0,3).join(', ')
      if (existSlugs.length > 3) {
        title += t(".and count people has reacted", { count: existSlugs.length })
      } else {
        title += t(".has reacted")
      }
    }

    const usersCount = reaction.groupCount || reaction.group_count;

    if (active) {
      btnClassName += ' selected';
    }

    return (
      <Tooltip title={title}>
        <a
          href="#"
          onClick={this.onClick}
          className={btnClassName}
          active={active}
          ref={this.itemRef}
        >
          <img src={reaction.url} className="emoji" />
          {usersCount > 0 && <span className="ml-1">{usersCount}</span>}
        </a>
      </Tooltip>
    );
  }
}
