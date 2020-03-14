import { Editor, EditorState, RichUtils } from 'draft-js';
import { stateToHTML } from 'draft-js-export-html';
import { stateFromHTML } from 'draft-js-import-html';
import Toolbar from './draft-toolbar';

export default class DraftEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      editorState: EditorState.createWithContent(stateFromHTML(props.value)),
      value: props.value,
      title: props.title,
    };
  }

  handleKeyCommand = (command, editorState) => {
    const newState = RichUtils.handleKeyCommand(editorState, command);
    if (newState) {
      this.onChange(newState);
      return 'handled';
    }
    return 'not-handled';
  }

  onChange = (editorState) => {
    this.setState({ editorState });


    this.props.onChange(stateToHTML(editorState.getCurrentContent()));
  }

  render() {
    const { mode = 'full', placeholder } = this.props;
    const { title, editorState } = this.state;

    return (
      <div className={`rich-editor-${mode} draft-editor`}>
        <Toolbar editorState={editorState} onChange={this.onChange} mode={mode} editor={this} />
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
              <Editor
                editorState={editorState}
                handleKeyCommand={this.handleKeyCommand}
                onChange={this.onChange}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
