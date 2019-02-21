import ErrorMessages from '../shared/error-messages';

export default class DocSetting extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      slug: props.slug,
      saveURL: props.saveURL,
      messages: [],
    };
  }

  slugInputRef = React.createRef()

  containerRef= React.createRef()

  onSubmit = (e) => {
    e.preventDefault();

    const { saveURL } = this.state;
    const slugInput = this.slugInputRef.current;
    const newSlug = slugInput.value;

    $.ajax({
      method: 'PUT',
      url: saveURL,
      dataType: 'JSON',
      data: {
        doc: {
          slug: slugInput.value,
        },
      },
      success: (res) => {
        const { saveURL, slug } = this.state;
        const { doc, ok } = res;

        if (ok) {
          const regexp = new RegExp(`/${slug}$`);
          const newSaveURL = saveURL.replace(regexp, `/${doc.slug}`);

          this.setState({ saveURL: newSaveURL, slug: doc.slug, messages: [] });
          this.props.onChange({ saveURL: newSaveURL, slug: doc.slug });
          this.dismiss();
        } else {
          this.setState({ messages: res.messages });
        }
      },
    });

    return false;
  }

  dismiss = () => {
    this.containerRef.current.removeAttribute('open');
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`editor.DocSetting${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { slug } = this.state;
    const { repositoryURL } = this.props;

    return (
      <React.Fragment>
      <details className="doc-setting-box position-relative details-overlay details-reset d-inline-block" ref={this.containerRef}>
        <summary className="btn"><i className="fas fa-setting"></i></summary>
        <div className="dropdown-menu dropdown-menu-sw p-4 text-left">
          <ErrorMessages messages={this.state.messages} />
          <div className="form-group mb-4">
            <label className="control-label">{this.t('.Slug')}</label>
            <div className="input-group d-flex">
              <div className="input-group-prepend mr-2">
                <div className="input-group-text">{repositoryURL}/</div>
              </div>
              <input type="text" ref={this.slugInputRef} className="form-control input-slug flex-auto" defaultValue={slug} />
            </div>
          </div>
          <div className="text-right">
            <span className="btn btn-primary" onClick={this.onSubmit}>{this.t('.Done')}</span>
          </div>
        </div>
      </details>
      </React.Fragment>
    );
  }
}
