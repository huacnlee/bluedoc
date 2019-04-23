import Reaction from './Reaction';
import NewReaction from './NewReaction';
import { updateReaction } from './api';

export default class Reactions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      t: props.updated || Date.now(),
      reactions: this.props.reactions || [],
    };
  }

  static getDerivedStateFromProps(props, state) {
    if (props.onChange && props.reactions !== state.reactions) {
      return {
        reactions: props.reactions,
      };
    }
    return null;
  }

  onSelect = (name, option) => {
    const { subjectType, subjectId } = this.props;

    updateReaction({
      subjectType,
      subjectId,
      name,
      option,
    })
      .then((result) => {
        this.updateReactions(result.updateReaction);
      })
      .catch((errors) => {
        window.App.alert(errors);
      });
  };

  updateReactions = (newReactions) => {
    const { onChange } = this.props;
    if (onChange) {
      onChange(newReactions);
    } else {
      this.setState({ reactions: newReactions });
    }
  };

  render() {
    const { t, reactions = [] } = this.state;
    const { mode = 'normal' } = this.props;

    let boxClassName = 'reaction-box';
    if (mode === 'normal' && reactions.length === 0) {
      boxClassName += ' reaction-box-empty';
    }
    return (
      <div class={boxClassName} updated={t}>
        {mode !== 'new_button'
          && reactions.map(reaction => (
            <Reaction
              {...this.props}
              reaction={reaction}
              className="reaction-summary-item"
              onSelect={this.onSelect}
            />
          ))}
        {mode !== 'list' && <NewReaction {...this.props} onSelect={this.onSelect} />}
      </div>
    );
  }
}
