import { UserAvatar } from 'bluebox/avatar';
import { UserLink } from 'bluebox/user';
import { PrimaryButton } from 'bluebox/button';
import { Icon } from 'bluebox/iconfont';
import InlineEditor from '../InlineEditor';
import { createComment, createCommentWithParent } from './api';

export default class CommentForm extends React.Component {
  constructor(props) {
    super(props);

    this.editorRef = React.createRef();
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`comments.comments${key}`);
    }
    return i18n.t(key);
  }

  renderBlankslate() {
    const { t } = this;

    return <div id="comment-form-blankslate" style={{ marginTop: '60px', textAlign: 'center' }} className="blankslate">
      <h2>{t('.Sign in to write comment')}</h2>
      <p>{t('.You must sign in first')}</p>
      <p><a href={App.routes.new_session_path} className="btn">{t('.Sign in now')}</a></p>
    </div>;
  }

  focus = () => {
    this.editorRef.current.focus();
  }

  onSubmit = (e) => {
    e.preventDefault();

    const {
      commentableType, commentableId, nid = '', replyTo, onCreate,
    } = this.props;
    const { t } = this;

    const { body, bodySml } = this.state;

    if (!body || !bodySml) {
      this.focus();
      return false;
    }

    const createParams = {
      commentableType,
      commentableId,
      body,
      bodySml,
      nid,
    };

    let invokeMethod = createComment;

    if (replyTo) {
      createParams.parentId = replyTo.id;
      invokeMethod = createCommentWithParent;
    }

    invokeMethod(createParams).then((result) => {
      const comment = result.createComment;
      if (onCreate) {
        onCreate(comment);
      }
      App.notice(t('.Comment was successfully created'));
      this.resetValue();
    }).catch((errors) => {
      App.alert(errors);
    });

    return false;
  }

  onBodyChange = (markdownValue, smlValue) => {
    this.setState({
      body: markdownValue,
      bodySml: smlValue,
    });
  }

  onCancelReplyTo = (e) => {
    if (e) {
      e.preventDefault();
    }

    const { onCancelReplyTo } = this.props;
    if (onCancelReplyTo) {
      onCancelReplyTo();
    }

    return false;
  }

  resetValue = () => {
    this.editorRef.current.resetValue();
    this.onCancelReplyTo();
  }

  render() {
    const { replyTo } = this.props;
    const { currentUser } = App;
    const { t } = this;

    if (!currentUser) {
      return this.renderBlankslate();
    }

    return <div className="new-comment" id="new_comment">
      <div className="avatar-box">
        <UserAvatar user={currentUser} link={false} type="medium" />
      </div>

      <div className="form-group">
        <InlineEditor ref={this.editorRef} name="comment[body_sml]" markdownName="comment[body]" format="sml" onChange={this.onBodyChange} />
      </div>

      <div class="form-actions clearfix">
        <PrimaryButton style={{ width: '180px' }} onClick={this.onSubmit}>{t('.Submit')}</PrimaryButton>
        <div className="in-reply-info">
        {replyTo && (
          <>
            <span className="mr-1">{t('.Reply to')}</span>
            <UserAvatar user={replyTo.user} type="small" link={false} className="mr-1" />
            <UserLink user={replyTo.user} className="mr-1" link={false} />
            <a href="#" onClick={this.onCancelReplyTo}><Icon name="times" /></a>
          </>
        )}
        </div>
      </div>
    </div>;
  }
}
