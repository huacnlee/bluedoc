import { Container, serializer } from 'typine';
import { AttachmentUpload } from './attachment-upload';
import Toolbar from './toolbar';

const defaultSML = '["root",["p",["span",{"t":1},["span",{"t":0},""]]]]';

export default class RichEditor extends React.Component {
  constructor(props) {
    super(props);
    const { value, format } = props;

    this.state = {
      value: this.getFormatValue({ value, format }),
      activeMarkups: [],
      title: props.title || '',
    };

    const { directUploadURL, blobURLTemplate } = this.props;

    this.attachmentService = {
      imageUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(
            file,
            directUploadURL,
            blobURLTemplate,
            url => resolve(url),
            onProgress,
          );
          upload.start();
        });
      },
      attachmentUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(
            file,
            directUploadURL,
            blobURLTemplate,
            url => resolve(url),
            onProgress,
          );
          upload.start();
        });
      },
      videoUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(
            file,
            directUploadURL,
            blobURLTemplate,
            url => resolve(url),
            onProgress,
          );
          upload.start();
        });
      },
    };

    this.editor = null;
  }

  container = null

  containerRef = React.createRef()

  componentDidMount() {
    this.container = ReactDOM.findDOMNode(this.containerRef.current);
  }

  getFormatValue = ({ value, format }) => {
    if (format === 'markdown') {
      return serializer.parserToValue(serializer.parserMarkdown(value));
    }
    return serializer.parserToValue(JSON.parse(value || defaultSML));
  }

  handleReset = ({ value, format }) => {
    this.onChange({ value: this.getFormatValue({ value, format }) });
  }

  getEditorContainer = () => this.container

  setEditor = (editor) => {
    const { getEditor } = this.props;
    if (getEditor) {
      getEditor(editor);
    }
    this.editor = editor;
  }

  onChange = (change) => {
    const { format } = this.props;

    this.setState({ value: change.value });

    const xslValue = serializer.parserToXSL(change.value);
    const markdownValue = serializer.parserToMarkdown(xslValue);

    const smlValue = JSON.stringify(xslValue);
    this.props.onChange(markdownValue, smlValue);
  }

  onChangeTitle = (e) => {
    const newTitle = e.target.value;
    this.props.onChangeTitle(newTitle);
    this.setState({ title: newTitle });
  }

  onMarkupChange = (markups) => {
    this.setState({ activeMarkups: markups });
  }

  isActiveMarkup = (type) => {
    const { activeMarkups } = this.state;
    return activeMarkups.indexOf(type) >= 0;
  }

  focus = () => {
    this.editor.focus();
  }

  // Render the editor.
  render() {
    let { value, title } = this.state;
    const { mode = 'full' } = this.props;
    // change "New Document" as placeholder
    let placeholder = 'Document title';
    if (title.trim() === 'New Document') {
      placeholder = 'New Document';
      title = '';
    }
    return <div className={`rich-editor-${mode}`}>
      <Toolbar value={value} mode={mode} editor={this.editor} container={this} />
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
            <Container
              value={value}
              onChange={this.onChange}
              getActiveMarkups={this.onMarkupChange}
              getEditor={this.setEditor}
              getEditorContainer={this.getEditorContainer}
              service={this.attachmentService}
              plantumlServiceHost={this.props.plantumlServiceHost}
              mathJaxServiceHost={this.props.mathJaxServiceHost}
             />
          </div>
        </div>
      </div>
    </div>;
  }
}
