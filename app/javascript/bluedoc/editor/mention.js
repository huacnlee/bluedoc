import React from 'react'
import ReactDOM from 'react-dom'

const DEFAULT_POSITION = {
  top: 0,
  left: 0,
}
const MENTION_REGEX = /@(\S*)$/

export const USER_MENTION_NODE_TYPE = "mention";
export const USER_MENTION_CONTEXT_TYPE = 'mentionContext'

/**
 * Suggestions is a PureComponent because we need to prevent updates when x/ y
 * Are just going to be the same value. Otherwise we will update forever.
 */

export class MentionList extends React.PureComponent {
  menuRef = React.createRef()

  state = DEFAULT_POSITION

  /**
   * On update, update the menu.
   */

  componentDidMount = () => {
    this.updateMenu()
  }

  componentDidUpdate = () => {
    this.updateMenu()
  }

  render() {
    const body = document.querySelector('body')
    const { users = [] } = this.props;

    return ReactDOM.createPortal(
      <div className="mention-list"
        ref={this.menuRef}
        style={{
          top: this.state.top,
          left: this.state.left,
        }}
      >
        {users.map(user => {
          if (!user.slug) { return <span /> }
          return (
            <div className="mention-item" key={user.id} onClick={() => this.props.onSelect(user)}>
              {user.name} <span className="username">{user.slug}</span>
            </div>
          )
        })}
      </div>,
      body
    )
  }

  updateMenu() {
    const anchor = window.document.querySelector(this.props.anchor)

    if (!anchor) {
      return this.setState(DEFAULT_POSITION)
    }

    const anchorRect = anchor.getBoundingClientRect()

    this.setState({
      top: anchorRect.bottom,
      left: anchorRect.left,
    })
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
    return null
  }

  const startOffset = value.selection.start.offset
  const textBefore = value.startText.text.slice(0, startOffset)
  const result = MENTION_REGEX.exec(textBefore)

  return result === null ? null : result[1]
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
  const { document, selection } = value

  const validParent = document.getClosest(
    selection.start.key,
    // In this simple case, we only want mentions to live inside a paragraph.
    // This check can be adjusted for more complex rich text implementations.
    (node) => {
      return node.type === 'paragraph' || node.type === 'blockquote' || node.type === 'span'
    }
  )

  return validParent
}