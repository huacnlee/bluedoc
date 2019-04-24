import { UserAvatar } from 'bluebox/avatar';
import { Icon } from 'bluebox/iconfont';
import { Timeago } from 'bluebox/timeago';
import { UserLink } from 'bluebox/user';
import Reactions from '../reactions/Index';

import InReply from './InReply';

export default class Comment extends React.Component {
  constructor(props) {
    super(props);

    const { comment } = this.props;

    this.menuRef = React.createRef();

    this.state = {
      reactions: comment.reactions,
      reactionsUpdated: Date.now(),
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`comments.comment${key}`);
    }
    return i18n.t(key);
  };

  onDelete = (e) => {
    e.preventDefault();
    this.dismissMenu();

    if (!confirm(this.t('.Are you sure?'))) {
      return false;
    }

    const { comment, onDelete } = this.props;

    if (onDelete) {
      onDelete(comment);
    }

    return false;
  };

  onReply = (e) => {
    e.preventDefault();
    this.dismissMenu();

    const { comment, onReply } = this.props;
    if (onReply) {
      onReply(comment);
    }
  };

  onReactionChange = (reactions) => {
    this.setState({
      reactions: [...reactions],
    });
  };

  dismissMenu = () => {
    if (this.menuRef) {
      this.menuRef.current.removeAttribute('open');
    }
  };

  render() {
    const { comment, abilities = {}, type = 'full' } = this.props;
    const { currentUser } = App;
    const { t } = this;
    const { reactions } = this.state;

    let canDestroy = abilities.destroy;
    let canUpdate = abilities.update;

    if (currentUser) {
      if (!canDestroy) {
        canDestroy = comment.user.id === currentUser.id;
      }
      if (!canUpdate) {
        canUpdate = comment.user.id === currentUser.id;
      }
    }

    const pageURL = window.location.href.replace(window.location.hash, '');
    return (
      <div id={`comment-${comment.id}`} className="comment" data-parent-id={comment.parentId}>
        <div class="avatar-box">
          <UserAvatar user={comment.user} type="medium" />
        </div>
        <div className="comment-infos">
          <div className="info">
            <UserLink user={comment.user} />
            <div className="time">
              <Timeago value={comment.createdAt} />
            </div>
            <div className="opts">
              {type === 'full' && (
                <Reactions
                  key="reactions1"
                  subjectType="Comment"
                  subjectId={comment.id}
                  mode="new_button"
                  reactions={reactions}
                  onChange={this.onReactionChange}
                />
              )}
              <details
                id={`comment-${comment.id}-menu-button`}
                ref={this.menuRef}
                className="dropdown details-reset details-overlay d-inline-block ml-4"
              >
                <summary>
                  <Icon name="ellipsis" />
                </summary>
                <div className="dropdown-menu dropdown-menu-sw">
                  <ul>
                    <li>
                      <clipboard-copy
                        class="dropdown-item btn-link"
                        data-close-dialog
                        data-clipboard-text={`${pageURL}#comment-${comment.id}`}
                        data-clipboard-tooltip-target={`#comment-${comment.id}-menu-button`}
                      >
                        {t('.Copy link')}
                      </clipboard-copy>
                    </li>
                    {currentUser && (
                      <li>
                        <a href="#" onClick={this.onReply} className="dropdown-item">
                          {t('.Reply')}
                        </a>
                      </li>
                    )}
                    {canDestroy && (
                      <>
                        <li class="dropdown-divider" />
                        <li>
                          <a href="#" onClick={this.onDelete} className="dropdown-item">
                            {t('.Delete')}
                          </a>
                        </li>
                      </>
                    )}
                  </ul>
                </div>
              </details>
            </div>
          </div>

          <div class="markdown-body">
            <InReply comment={comment} />
            <div dangerouslySetInnerHTML={{ __html: comment.bodyHtml }} />
          </div>

          {type === 'full' && (
            <Reactions
              key="reactions2"
              subjectType="Comment"
              subjectId={comment.id}
              reactions={reactions}
              mode="list"
              onChange={this.onReactionChange}
            />
          )}
        </div>
      </div>
    );
  }
}
