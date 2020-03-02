import Toolbar from './markdown-toolbar';
import { AttachmentUpload } from './attachment-upload';

require('codemirror/mode/markdown/markdown.js');
require('codemirror/mode/gfm/gfm.js');
require('codemirror/addon/mode/overlay.js');
require('codemirror/addon/selection/mark-selection.js');

const CodeMirror = require('react-codemirror');

const codeMirrorOptions = {
  mode: 'gfm',
  showCursorWhenSelecting: true,
  lineWrapping: true,
};

export default class MarkdownEditor extends React.Component {
  editorRef = React.createRef();


  codemirror = null

  constructor(props) {
    super(props);

    const { title, value, format } = props;

    this.state = {
      title,
      value,
      format,
    };


    const { directUploadURL, blobURLTemplate } = window.App;

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
  }

  componentDidMount() {
    this.codemirror = this.editorRef.current.getCodeMirror();
  }

  onChange = (newValue) => {
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

  _insertText = (text) => {
    const { codemirror } = this;
    const { doc } = codemirror;

    const cursor = doc.getCursor();
    doc.replaceRange(text, cursor);
  }

  _insertImage = ({ name, url }) => {
    const text = `![${name}](${url})`;
    this._insertText(text);
  }

  _insertFile = ({ name, url }) => {
    const text = `[${name}](${url})`;
    this._insertText(text);
  }

  _insertVideo = ({ name, url }) => {
    const text = `<video preload="no" title="${name}"><source src="${url}"></video>`;
    this._insertText(text);
  }

  getSelection = () => {
    const { codemirror } = this;
    const { doc } = codemirror;
    const cursor = doc.getCursor();
    const selection = doc.getSelection();

    return { cm: doc, cursor, selection };
  }

  _bold = () => {
    const { cm, cursor, selection } = this.getSelection();

    cm.replaceSelection(`**${selection}**`);
    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 2);
    }
  }

  _italic = () => {
    const { cm, cursor, selection } = this.getSelection();
    cm.replaceSelection(`*${selection}*`);

    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 1);
    }
  }

  _strike = () => {
    const { cm, cursor, selection } = this.getSelection();
    cm.replaceSelection(`~~${selection}~~`);

    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 2);
    }
  }

  _link = () => {
    const { cm, cursor, selection } = this.getSelection();
    cm.replaceSelection(`[${selection}]()`);
    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 2);
    }
  }

  _code = () => {
    const { cm, cursor, selection } = this.getSelection();

    cm.replaceSelection(`\`${selection}\``);

    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 1);
    }
  }

  _codeblock = () => {
    const { cm, cursor, selection } = this.getSelection();
    this._insertText('\n```\n```\n');

    if (selection === '') {
      cm.setCursor(cursor.line, cursor.ch + 3);
    }
  }

  _blockquote = () => {
    const { cm, cursor, selection } = this.getSelection();

    if (cursor.ch !== 0) {
      cm.setCursor(cursor.line, 0);
      cm.replaceSelection(`> ${selection}`);
      cm.setCursor(cursor.line, cursor.ch + 2);
    } else {
      cm.replaceSelection(`> ${selection}`);
    }
  }

  _heading = (num) => {
    const { cm, cursor, selection } = this.getSelection();
    const prefix = `${'#'.repeat(num)} `;

    if (cursor.ch !== 0) {
      cm.setCursor(cursor.line, 0);
      cm.replaceSelection(prefix + selection);
      cm.setCursor(cursor.line, cursor.ch + num + 1);
    } else {
      cm.replaceSelection(prefix + selection);
    }
  }

  _bulletedList = () => {
    const { cm, cursor, selection } = this.getSelection();

    if (selection === '') {
      cm.replaceSelection(`- ${selection}`);
    } else {
      const selectionText = selection.split('\n');

      for (let i = 0, len = selectionText.length; i < len; i++) {
        selectionText[i] = (selectionText[i] === '') ? '' : `- ${selectionText[i]}`;
      }

      cm.replaceSelection(selectionText.join('\n'));
    }
  }

  _numberedList = () => {
    const { cm, cursor, selection } = this.getSelection();


    if (selection === '') {
      cm.replaceSelection(`1. ${selection}`);
    } else {
      const selectionText = selection.split('\n');

      for (let i = 0, len = selectionText.length; i < len; i++) {
        selectionText[i] = (selectionText[i] === '') ? '' : `${i + 1}. ${selectionText[i]}`;
      }

      cm.replaceSelection(selectionText.join('\n'));
    }
  }

  _hr = () => {
    const { cm, cursor, selection } = this.getSelection();

    cm.replaceSelection(`${(cursor.ch !== 0) ? '\n\n' : '\n'}------------\n\n`);
  }

  _undo = () => {
    const { cm } = this.getSelection();
    cm.undo();
  }

  _redo = () => {
    const { cm } = this.getSelection();
    cm.redo();
  }

  _uploadFileEvent = (event, fileType, next) => {
    const service = this.attachmentService;
    const { imageUpload, attachmentUpload, videoUpload } = service;
    if (!imageUpload) return next();

    const editor = this;

    let transfer = { files: [] };

    if (event.target && event.target.files) {
      transfer = { files: event.target.files };
    }

    const { files } = transfer;

    for (const file of files) {
      const { type, name } = file;
      event.preventDefault();
      const onProgress = (progress) => { };

      if (fileType === 'image') {
        imageUpload(file, onProgress).then((url) => {
          editor._insertImage({ url, name });
        }).catch((e) => {
          console.error(e);
        });
      } else if (fileType === 'video') {
        videoUpload(file, onProgress)
          .then((url) => {
            editor._insertVideo({ url, name });
          })
          .catch((e) => {
            console.error(e);
          });
      } else {
        attachmentUpload(file, onProgress)
          .then((url) => {
            editor._insertFile({ url, name });
          })
          .catch((e) => {
            console.error(e);
          });
      }
    }
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
      <Toolbar value={value} mode={mode} editor={this} />
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
            <CodeMirror className="editor-body-text" autoFocus options={codeMirrorOptions} ref={this.editorRef} value={value} onChange={this.onChange} />
          </div>
        </div>
      </div>
    </div>;
  }
}
