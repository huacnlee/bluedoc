/* eslint-disable-next-line */
import React from 'react';
/* eslint-disable-next-line */
import ReactDOM from 'react-dom';

const DEFAULT_POSITION = {
  top: 0,
  left: 0,
};
const MENTION_REGEX = /@(\S*)$/;

export const USER_MENTION_NODE_TYPE = 'mention';
export const USER_MENTION_CONTEXT_TYPE = 'mentionContext';

/**
 * Suggestions is a PureComponent because we need to prevent updates when x/ y
 * Are just going to be the same value. Otherwise we will update forever.
 */

export class MentionList extends React.PureComponent {
  menuRef = React.createRef()

  state = {
    pos: DEFAULT_POSITION,
    activeIndex: 0,
    users: [],
  }

  static getDerivedStateFromProps({ users = [], anchor }, prevState) {
    let { pos } = prevState;
    if (users && users.length > 1 && users !== prevState.users) {
      const anchorEle = window.document.querySelector(anchor);
      if (anchorEle) {
        const { top, left } = anchorEle.getBoundingClientRect();
        pos = { top, left };
      }
    }
    return { ...prevState, pos, users: users.filter(v => v.slug) };
  }
  /**
   * On update, update the menu.
   */

  componentDidMount = () => {
    this.updateMenu();
    window.addEventListener('keydown', this.handleKeyDown, true);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleKeyDown, true);
  }

  updateMenu = () => {
    const anchor = window.document.querySelector(this.props.anchor);
    if (!anchor) {
      this.setState(DEFAULT_POSITION);
    } else {
      const anchorRect = anchor.getBoundingClientRect();
      this.setState({
        top: anchorRect.bottom,
        left: anchorRect.left,
      });
    }
  }

  handleKeyDown = (event) => {
    const { keyCode } = event;
    const { activeIndex, users } = this.state;
    if (users.length < 1) return;
    switch (keyCode) {
      // up
      case 38:
        event.stopPropagation();
        event.preventDefault();
        this.handleSelectItem(activeIndex - 1);
        break;
      // down
      case 40:
        event.stopPropagation();
        event.preventDefault();
        this.handleSelectItem(activeIndex + 1);
        break;
      // enter
      case 13:
      {
        event.stopPropagation();
        event.preventDefault();
        const user = users[activeIndex];
        user && this.props.onSelect(user);
        break;
      }
      default:
        break;
    }
  }

  handleSelectItem = (activeIndex) => {
    const { users = [] } = this.state;
    if (activeIndex < 0 || activeIndex > users.length - 1) {
      return;
    }
    this.setState({ activeIndex });
  }

  render() {
    const body = document.querySelector('body');
    const { pos: { top, left }, activeIndex, users = [] } = this.state;
    if ((top === 0 && left === 0) || users.length < 1) {
      return null;
    }
    return ReactDOM.createPortal(
      <div className="mention-list"
        ref={this.menuRef}
        style={{ top, left }}
      >
        {users.map((user, index) => (
          <div
            className={`mention-item ${index === activeIndex ? 'active' : ''}`}
            key={user.id}
            onClick={() => this.props.onSelect(user)}
          >
            {user.name} <span className="username">{user.slug}</span>
          </div>
        ))}
      </div>,
      body,
    );
  }
}

/**
 * Get get the potential mention input.
 *
 * @type {Value}
 */


export function getMentionInput(value) {
  // In some cases, like if the node that was selected gets deleted,
  // `startText` can be null.
  if (!value.startText) {
    return null;
  }

  const startOffset = value.selection.start.offset;
  const textBefore = value.startText.text.slice(0, startOffset);
  const result = MENTION_REGEX.exec(textBefore);
  return result === null ? null : result[1];
}

/**
 * Determine if the current selection has valid ancestors for a context. In our
 * case, we want to make sure that the mention is only a direct child of a
 * paragraph. In this simple example it isn't that important, but in a complex
 * editor you wouldn't want it to be a child of another inline like a link.
 *
 * @param {Value} value
 */

export function hasValidAncestors(value) {
  const { document, selection } = value;

  const validParent = document.getClosest(
    selection.start.key,
    // In this simple case, we only want mentions to live inside a paragraph.
    // This check can be adjusted for more complex rich text implementations.
    node => (node.type !== 'paragraph' && node.type !== 'blockquote' && node.type !== 'span'),
  );
  return !validParent;
}
