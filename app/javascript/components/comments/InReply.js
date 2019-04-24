import { UserAvatar } from 'bluebox/avatar';
import { UserLink } from 'bluebox/user';

export default class InReply extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      detail: false,
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`comments.comments${key}`);
    }
    return i18n.t(key);
  }


  onToggle = (e) => {
    e.preventDefault();


    this.setState({ detail: !this.state.detail });

    return false;
  }

  render() {
    const { comment } = this.props;
    const { detail } = this.state;
    const { t } = this;

    if (!comment.replyTo) {
      return <span />;
    }

    if (detail) {
      return this.renderDetail();
    }

    return <div class="in-reply-to">
      <a href="#" onClick={this.onToggle} className="in-reply-link">
        <span className="mr-1">{t('.In reply to')}</span>
        <UserAvatar user={comment.replyTo.user} type="tiny" link={false} className="mr-1" />
        <UserLink user={comment.replyTo.user} link={false} />
      </a>
    </div>;
  }

  renderDetail() {
    const { comment } = this.props;
    const { t } = this;

    return <div class="in-reply-to">
      <div className="in-reply-link">
        <span className="mr-1">{t('.In reply to')}</span>
        <UserAvatar user={comment.replyTo.user} type="tiny" link={false} className="mr-1" />
        <UserLink user={comment.replyTo.user} link={false} />
        <div className="body markdown-body" dangerouslySetInnerHTML={{ __html: comment.replyTo.bodyHtml }} />
      </div>
    </div>;
  }
}
