export default class Reaction extends React.Component {
  constructor(props) {
    super(props);

    const { currentUser = {} } = App;
    const { reaction } = props;

    const existSlugs = reaction.groupUserSlugs || reaction.group_user_slugs || [];
    const active = existSlugs.includes(currentUser.slug);

    this.state = {
      active,
      groupCount: reaction.groupCount || reaction.group_count,
    };
  }

  onClick = (e) => {
    e.preventDefault();

    const { onSelect, reaction } = this.props;
    const { active } = this.state;

    if (onSelect) {
      if (active) {
        onSelect(reaction.name, 'unset');
      } else {
        onSelect(reaction.name, 'set');
      }
    }

    return false;
  };

  render() {
    const { reaction, className = '' } = this.props;
    const { active, groupCount } = this.state;
    let btnClassName = `btn-link reaction-item ${className}`;

    if (active) {
      btnClassName += ' selected';
    }

    return (
      <a
        href="#"
        onClick={this.onClick}
        className={btnClassName}
        data-toggle="tooltip"
        title={reaction.name}
      >
        <img src={reaction.url} className="emoji" />
        {groupCount > 0 && <span className="ml-1">{groupCount}</span>}
      </a>
    );
  }
}
