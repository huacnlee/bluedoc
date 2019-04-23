import Reaction from './Reaction';
import NewReaction from './NewReaction';
import { updateReaction } from './api';

export default class Reactions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      t: props.updated || Date.now(),
    };
  }

  onSelect = (name, option) => {
    const { subjectType, subjectId } = this.props;

    if (option === 'unset') {
      let { reactions } = this.props;
      reactions = reactions.filter(r => r.name != name);
      this.updateReactions(reactions);
    }

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
        App.alert(errors);
      });
  };

  updateReactions = (newReactions) => {
    const { onChange } = this.props;
    onChange && onChange(newReactions);
  };

  render() {
    const { t } = this.state;
    const { reactions = [], mode = 'normal' } = this.props;

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
