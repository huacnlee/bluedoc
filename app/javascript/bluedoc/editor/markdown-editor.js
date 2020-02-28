import Toolbar from './markdown-toolbar';

export default class MarkdownEditor extends React.Component {
  constructor(props) {
    super(props);

    const { title, value, format } = props;
    this.state = {
      title,
      value,
      format,
    };
  }

  onChange = (e) => {
    const newValue = e.target.value;
    this.props.onChange(newValue);
    this.setState({ value: newValue });
  }

  onChangeTitle = (e) => {
    const newTitle = e.target.value;
    this.props.onChangeTitle(newTitle);
    this.setState({ title: newTitle });
  }


  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`editor.Editor${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { value } = this.state;
    let { title } = this.state;
    const { mode = 'full' } = this.props;
    // change "New Document" as placeholder
    let placeholder = this.t('.New Document');
    if (title.trim() === 'New Document') {
      placeholder = this.t('.New Document');
      title = '';
    }

    return <div className={`rich-editor-${mode} markdown-editor`}>
      <Toolbar value={value} mode={mode} onChange={this.onChange} container={this} />
      <div className="editor-bg" ref={this.containerRef}>
        <div className="editor-box">
          {mode === 'full' && (
            <div className="editor-title">
              <input
                type="text"
                value={title}
                placeholder={placeholder}
                onChange={this.onChangeTitle}
                className="editor-title-text" />
            </div>
          )}
          <div className="editor-text markdown-body">
            <textarea class="editor-body-text" onChange={this.onChange}>{value}</textarea>
          </div>
        </div>
      </div>
    </div>;
  }
}
