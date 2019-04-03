
import { ErrorMessages } from 'bluebox/notice';

export default class EditorSetting extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      slug: props.slug,
      description: props.description,
      privacy: props.privacy,
      saveURL: props.saveURL,
      messages: [],
    };
  }

  slugInputRef = React.createRef()

  descriptionInputRef = React.createRef()

  containerRef= React.createRef()

  onSubmit = (e) => {
    e.preventDefault();

    const { saveURL, privacy } = this.state;
    const slugInput = this.slugInputRef.current;
    const descriptionInput = this.descriptionInputRef.current;

    const data = {};
    data.note = {
      slug: slugInput.value,
      description: descriptionInput.value,
      privacy,
    };

    $.ajax({
      method: 'PUT',
      url: saveURL,
      dataType: 'JSON',
      data,
      success: (res) => {
        const { saveURL, slug } = this.state;
        const { ok } = res;

        const record = res.note;

        if (ok) {
          const regexp = new RegExp(`/${slug}$`);
          const newSaveURL = saveURL.replace(regexp, `/${record.slug}`);

          this.setState({ saveURL: newSaveURL, slug: record.slug, messages: [] });
          this.onChange({ saveURL: newSaveURL, slug: record.slug });
          this.dismiss();
        } else {
          this.setState({ messages: res.messages });
        }
      },
    });

    return false;
  }

  onChange = (res) => {
    const { saveURL } = res;
    const pageURL = `${saveURL}/edit`;
    window.history.pushState({}, window.title, pageURL);
    document.querySelector('#note-form').setAttribute('action', saveURL);
    document.querySelector('.note-link').setAttribute('href', saveURL);
  }

  dismiss = () => {
    this.containerRef.current.removeAttribute('open');
  }

  selectPrivacy = (e) => {
    this.setState({ privacy: e.currentTarget.value });
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`notes.EditorSetting${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { slug, description, privacy } = this.state;
    const wasPrivacy = this.props.privacy;
    const { prefix } = this.props;

    return (
      <details className="doc-setting-box position-relative details-overlay details-reset d-inline-block" ref={this.containerRef}>
        <summary className="btn"><i className="fas fa-setting"></i></summary>
        <div className="dropdown-menu dropdown-menu-sw p-4 text-left">
          <ErrorMessages messages={this.state.messages} />
          <div className="form-group">
            <label className="control-label">{this.t('.Note path')}</label>
            <div className="input-group d-flex">
              <div className="input-group-prepend mr-2" title={`${prefix}/`}>
                <div className="input-group-text text-overflow">{prefix}/</div>
              </div>
              <input type="text" ref={this.slugInputRef} width="150px" className="form-control input-slug flex-auto" defaultValue={slug} />
            </div>
          </div>

          <div className="form-group mb-4">
            <label className="control-label">{this.t('.Description')}</label>
            <textarea className="form-control" ref={this.descriptionInputRef} defaultValue={description}></textarea>
          </div>

          <div className="form-group mb-4">
            <label className="control-label">{this.t('.Privacy')}</label>
            <div className="form-checkbox">
              <label>
      <input type="radio" name="_privacy" checked={privacy === 'public'} onChange={this.selectPrivacy} defaultValue="public" /> {this.t('.Public')}
                <div className="form-text"> {this.t('.Anyone can see this Note')}</div>
              </label>
            </div>
            <div className="form-checkbox">
              <label>
      <input type="radio" name="_privacy" checked={privacy === 'private'} onChange={this.selectPrivacy} defaultValue="private" /> {this.t('.Private')}
                <div className="form-text">{this.t('.Only you can see this Note')}</div>
              </label>
            </div>
            {privacy === 'private' && privacy !== wasPrivacy && (
              <div className="notice notice-error">{this.t('.If you change privacy from Public to Private')}</div>
            )}
          </div>

          <div className="text-right">
            <span className="btn btn-primary" onClick={this.onSubmit}>{this.t('.Done')}</span>
          </div>
        </div>
      </details>
    );
  }
}
