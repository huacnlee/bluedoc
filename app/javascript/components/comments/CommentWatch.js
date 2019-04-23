import { UserAvatar } from "bluebox/avatar";
import { watchComments } from "./api";
import{ Icon } from "bluebox/iconfont"

export default class CommentWatch extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      status: props.watchStatus,
      loading: false,
    }
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`comments.comment_watch${key}`);
    }
    return i18n.t(key);
  }


  onSubmit = (e) => {
    e.preventDefault();

    const { commentableType, commentableId } = this.props;

    this.setState({ loading: true });

    const newStatus = e.target.getAttribute("status");

    watchComments({ commentableType, commentableId, option: newStatus }).then((result) => {
      this.setState({
        status: newStatus,
        loading: false,
      })
    }).catch((errors) => {
      App.alert(errors);
      this.setState({ loading: false });
    });

    return false;
  }

  render() {
    const { currentUser } = this.props;
    const { t } = this;
    const { status, loading } = this.state;

    if (!currentUser) {
      return <span />
    }

    return <div id="comment-watch-box" className="border-bottom mb-3 pb-3 clearfix">
      <div className="watch-button-group">
        <div className="form-label">{t(".Subscribe")}</div>
        {this.renderButton()}
      </div>
    </div>
  }

  renderButton() {
    const { status } = this.state;
    const { t } = this;

    switch (status) {
      case "ignore":
        return <>
          <p class="text-gray" watch-status="ignore">{t(".You’re ignoring this notifications")}</p>
          <a href="#" className="btn-radio" status="watch" onClick={this.onSubmit} />
        </>
      case "watch":
        return <>
          <p class="text-gray" watch-status="watched">{t(".You’re receiving notifications because you’re subscribed")}</p>
          <a href="#" className="btn-radio checked" status="ignore" onClick={this.onSubmit} />
        </>
      default:
        return <>
          <p class="text-gray" watch-status="none">{t(".You’re not receiving notifications")}</p>
          <a href="#" className="btn-radio" status="watch" onClick={this.onSubmit} />
        </>
    }
  }
}
