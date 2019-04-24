import ContentLoader from 'react-content-loader';
import { Pagination } from 'bluebox/pagination';
import CommentWatch from './CommentWatch';
import CommentForm from './CommentForm';
import Comment from './Comment';


import { getComments, deleteComment } from './api';

export default class Index extends React.Component {
  constructor(props) {
    super(props);

    this.formRef = React.createRef();

    this.state = {
      comments: [],
      replyTo: null,
      loading: false,
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`comments.comments${key}`);
    }
    return i18n.t(key);
  }

  componentDidMount = () => {
    this.fetch(1);

    // TODO: Focus Comment item when location.href.hash exist
  }

  onPage = (page) => {
    this.fetch(page);
  }

  fetch(page) {
    const { commentableType, commentableId, nid = '' } = this.props;

    this.setState({ loading: true });

    getComments({
      commentableType, commentableId, page, nid,
    }).then((result) => {
      const { records, pageInfo } = result.comments;
      this.setState({
        // Only return the first 5 results
        comments: records,
        pageInfo,
        loading: false,
      });
    }).catch((errors) => {
      App.alert(errors);
      this.setState({
        loading: false,
      });
    });
  }

  onDelete = (comment) => {
    let { comments } = this.state;

    deleteComment({ id: comment.id }).then((result) => {
      comments = comments.filter(c => c.id != comment.id);
      this.setState({ comments });
    }).catch((errors) => {
      App.alert(errors);
    });
  }

  onReply = (comment) => {
    this.setState({
      replyTo: comment,
    });

    this.formRef.current.focus();
  }

  onCancelReplyTo = () => {
    this.setState({
      replyTo: null,
    });
    this.formRef.current.focus();
  }

  onCommentCreate = (comment) => {
    const { comments } = this.state;
    comments.push(comment);
    this.setState({ comments });
  }

  render() {
    const { type = 'full' } = this.props;
    const {
      comments, replyTo, loading, pageInfo,
    } = this.state;
    const { t } = this;

    return <div className={`comments comments-${type}`}>
      <div class="sub-title">{t('.Comments')}</div>
      <CommentWatch {...this.props} />
      <div className="comments-list">
        {loading && (
          <div style={{ width: '400px' }}>
            <CommentLoader />
            <CommentLoader />
          </div>
        )}
        {!loading && (
          comments.map(comment => <Comment {...this.props} comment={comment} onReply={this.onReply} onDelete={this.onDelete} />)
        )}
      </div>

      {comments.length > 0
        && <Pagination onPage={this.onPage} pageInfo={pageInfo} />
      }

      <CommentForm ref={this.formRef} {...this.props} onCreate={this.onCommentCreate} onCancelReplyTo={this.onCancelReplyTo} replyTo={replyTo} />
    </div>;
  }
}

const CommentLoader = () => (
  <ContentLoader
    height={120}
    width={400}
    speed={2}
    primaryColor="#f7f7f7"
    secondaryColor="#eeeeee"
  >
    <circle cx="19" cy="28" r="17" />
    <rect x="50" y="36" rx="4" ry="4" width="50" height="8" />
    <rect x="51" y="14" rx="4" ry="4" width="130" height="14" />
    <rect x="51" y="67" rx="4" ry="4" width="340" height="16" />
    <rect x="51" y="94" rx="4" ry="4" width="300" height="16" />
  </ContentLoader>
);
