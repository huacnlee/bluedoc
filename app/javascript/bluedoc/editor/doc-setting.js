import { ErrorMessages } from "../shared/error-messages";

export class DocSetting extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      slug: props.slug,
      saveURL: props.saveURL,
      messages: []
    }
  }

  slugInputRef = React.createRef()
  containerRef= React.createRef()

  onSubmit = (e) => {
    e.preventDefault();

    const { saveURL } = this.state;
    const slugInput = this.slugInputRef.current;
    const newSlug = slugInput.value;

    $.ajax({
      method: "PUT",
      url: saveURL,
      dataType: "JSON",
      data: {
        doc: {
          slug: slugInput.value
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
      }
    });

    return false
  }

  dismiss = () => {
    this.containerRef.current.removeAttribute("open");
  }

  render() {
    const { slug } = this.state;
    const { repositoryURL } = this.props;

    return (
      <React.Fragment>
      <details className="doc-setting-box position-relative details-overlay details-reset d-inline-block" ref={this.containerRef}>
        <summary className="btn"><i className="fas fa-info"></i></summary>
        <div className="dropdown-menu dropdown-menu-sw p-4 mb-2 text-left">
          <h4 className="mb-2"><i className="fas fa-info"></i> Doc settings</h4>
          <ErrorMessages messages={this.state.messages} />
          <div className="form-group">
            <label className="control-label">Change Slug:</label>

            <div className="input-group">
              <div className="input-group-prepend">
                <div className="input-group-text">{repositoryURL}/</div>
              </div>
              <input type="text" ref={this.slugInputRef} className="form-control input-slug" defaultValue={slug} />
            </div>
          </div>
          <div className="mt-1">
            <a className="btn btn-primary" onClick={this.onSubmit}>Done</a>
          </div>
        </div>
      </details>
      </React.Fragment>
    )
  }
}