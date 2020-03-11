import CKEditor from '@ckeditor/ckeditor5-react';
import { } from './ckeditor';
import { AttachmentUpload } from './attachment-upload';

export default class CkEditor extends React.Component {
  toolbarRef = React.createRef();

  constructor(props) {
    super(props);

    this.state = {
      title: props.title,
      value: props.value,
    };
  }

  onChange = (ev, editor) => {
    const newValue = editor.getData();
    this.props.onChange(newValue);
  }

  onChangeTitle = (ev) => {
    const newTitle = ev.target.value;
    this.props.onChangeTitle(newTitle);
    this.setState({ title: newTitle });
  }

  onInit = (editor) => {
    this.toolbarRef.current.appendChild(editor.ui.view.toolbar.element);
  }

  render() {
    const { value, title } = this.state;
    const { placeholder } = this.props;
    let { mode } = this.props;

    if (!mode) {
      mode = 'full';
    }

    const { directUploadURL, blobURLTemplate } = window.App;

    const config = {
      attachmentUpload: {
        directUploadURL,
        blobURLTemplate,
        AttachmentUpload,
      },
      language: App.locale === 'en' ? 'en' : 'zh-CN',
    };


    return <div className={`rich-editor-${mode} ck-editor`}>
      <div ref={this.toolbarRef} className="editor-toolbar"></div>
      <div className="editor-bg">
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
            <CKEditor
              editor={ClassicEditor}
              onInit={this.onInit}
              data={value}
              config={config}
              onChange={this.onChange}
            />
          </div>
        </div>
      </div>
    </div>;
  }
}
