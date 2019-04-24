import { Icon } from 'bluebox/iconfont';
import Reaction from './Reaction';

export default class NewReaction extends React.Component {
  constructor(props) {
    super(props);

    this.menuRef = React.createRef();
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`reactions.new_button${key}`);
    }
    return i18n.t(key);
  };

  onSelect = (name, option) => {
    const { onSelect } = this.props;

    this.menuRef.current.removeAttribute('open');

    onSelect(name, option);
  };

  render() {
    const { currentUser, allowReactions = [] } = App;
    const { t } = this;

    if (!currentUser) {
      return <span />;
    }

    return (
      <details
        class="details-overlay details-reset position-relative float-left reaction-popover-container"
        ref={this.menuRef}
      >
        <summary class="reaction-summary-item add-reaction-btn">
          <Icon name="smile" />
        </summary>
        <div class="dropdown-menu dropdown-menu-ne add-reaction-popover anim-scale-in">
          <div class="text-gray mx-2 my-1">{t('.Select a item')}</div>
          <div class="dropdown-divider" />
          <div class="add-reactions-options mx-1 mb-3">
            {allowReactions.map(reaction => (
              <Reaction
                {...this.props}
                reaction={reaction}
                onSelect={this.onSelect}
                className="add-reactions-options-item"
              />
            ))}
          </div>
        </div>
      </details>
    );
  }
}
