import { Container, serializer } from '@thebluedoc/editor';
import AttachmentUpload from './attachment-upload';
import Toolbar from './toolbar';
import {
  MentionList,
  getMentionInput,
  hasValidAncestors,
  USER_MENTION_NODE_TYPE,
  USER_MENTION_CONTEXT_TYPE,
} from './mention';
import { searchUsers } from '../graphql';

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
    // Mention
    const mentionValue = getMentionInput(change.value);
    if (mentionValue !== this.lastMentionValue) {
      this.lastMentionValue = mentionValue;
      const isValid = hasValidAncestors(change.value);
      if (isValid) {
        this.searchUsers(mentionValue);
      }
      const { selection } = change.value;
      let decorations = change.value.decorations.filter(
        value => value.mark.type !== USER_MENTION_CONTEXT_TYPE,
      );
      if (mentionValue && isValid) {
        decorations = decorations.push({
          anchor: {
            key: selection.start.key,
            offset: selection.start.offset - mentionValue.length,
          },
          focus: {
            key: selection.start.key,
            offset: selection.start.offset,
          },
          mark: {
            type: USER_MENTION_CONTEXT_TYPE,
          },
        });
      }

      this.setState({ value: change.value }, () => {
        // We need to set decorations after the value flushes into the editor.
        setTimeout(() => {
          this.editor.setDecorations(decorations);
        }, 20);
      });

      return;
    }

    this.setState({ value: change.value });
    // Update SML value to Textarea
    const xslValue = serializer.parserToXSL(change.value);
    const markdownValue = serializer.parserToMarkdown(xslValue);

    const smlValue = JSON.stringify(xslValue);
    this.props.onChange(markdownValue, smlValue);
  }

  /**
   * Replaces the current "context" with a user mention node corresponding to
   * the given user.
   * @param {Object} user
   *   @param {string} user.id
   *   @param {string} user.username
   */
  insertMention = (user) => {
    const { value } = this.state;
    const inputValue = getMentionInput(value);

    // Delete the captured value, including the `@` symbol
    this.editor.deleteBackward(inputValue.length + 1);
    const selectedRange = this.editor.value.selection;

    this.editor
      .insertText(' ')
      .insertInlineAtRange(selectedRange, {
        data: {
          username: user.slug,
          id: user.id,
          name: user.name,
        },
        nodes: [
          {
            object: 'text',
            leaves: [
              {
                text: `@${user.name}`,
              },
            ],
          },
        ],
        type: USER_MENTION_NODE_TYPE,
      })
      .focus();
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

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`editor.Editor${key}`);
    }
    return i18n.t(key);
  }

  searchUsers = (query) => {
    this.setState({
      mentionUsers: [],
    });

    if (!query) return;

    searchUsers({ query }).then((result) => {
      this.setState({
        // Only return the first 5 results
        mentionUsers: result.search.records.slice(0, 5),
      });
    }).catch((errors) => {
      if (Array.isArray(errors)) {
        errors.forEach(err => console.error('GraphQL query error:', err.message));
      } else {
        console.error(errors);
      }
    });
  }

  // Render the editor.
  render() {
    let { title } = this.state;
    const { value } = this.state;
    const { mode = 'full' } = this.props;
    // change "New Document" as placeholder
    let placeholder = this.t('.New Document');
    if (title.trim() === 'New Document') {
      placeholder = this.t('.New Document');
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
              placeholder={this.t('.Write document contents here')}
             />
            <MentionList
              anchor=".mention-context"
              users={this.state.mentionUsers}
              onSelect={this.insertMention}
            />
          </div>
        </div>
      </div>
    </div>;
  }
}
