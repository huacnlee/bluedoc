import { BarButton } from "./bar-button"
import styled from "styled-components";
// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"

export class Toolbar extends React.Component {
  state = { }

  isActiveMarkup = (type) => {
    const { container } = this.props;
    return container.isActiveMarkup(type);
  }

  /**
   * When a mark button is clicked, toggle the current mark.
   *
   * @param {Event} ev
   * @param {String} type
   */
  onClickMark = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.props.editor._toggleMarkAtRanges(type);
  };

  onClickBlock = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    switch (type) {
    case "bulleted-list":
      editor._toggleListAtRanges("bulleted");
      break;
    case "ordered-list":
      editor._toggleListAtRanges("ordered");
      break;
    case "todo-list":
      editor._toggleListAtRanges("todo");
      break;
    case "blockquote":
      if (this.isActiveMarkup("blockquote")) {
        editor._unwrapBlockquoteAtRanges();
      } else {
        editor._wrapBlockquoteAtRanges();
      }
      break;
    case "horizontal-rule":
      editor._insertHorizontalRule();
      break;
    case "codeblock":
      if (this.isActiveMarkup("codeblock")) {
        editor.setBlocks("paragraph");
      } else {
        editor._insertCodeblock();
      }
      break;
    default:
      if (this.isActiveMarkup(type)) {
        editor.setBlocks("paragraph");
      } else {
        editor.setBlocks(type);
      }
      break;
    }
  };

  handleCreateLink = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.props.editor._wrapLinkAtRange("", { autoFocus: true });
  };

  handleImageClick = () => {
    // simulate a click on the file upload input element
    this.imageFile.click();
  }

  handleFileClick = () => {
    this.file.click();
  }

  handleIndent = (ev, increase) => {
    ev.preventDefault()
    const { editor } = this.props;
    editor._setIndentAtRanges(4, increase)
  }

  toggleList = (ev, type) => {
    ev.preventDefault()
    const { editor } = this.props;
    editor._toggleListAtRanges(type)
  }

  onImagePicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadImageEvent(ev, () => {});
  }

  onFilePicked = (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, () => {});
  }

  renderMarkButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = ev => this.onClickMark(ev, type);
    title = title || type;

    return (
      <BarButton icon={icon} title={title} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderBlockButton = (type, icon) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = ev =>
      this.onClickBlock(ev, type);

    return (
      <BarButton icon={icon} title={type} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  render() {
    return <div className="editor-toolbar">
      <div className="container">
        <HiddenInput
          type="file"
          innerRef={ref => (this.imageFile = ref)}
          onChange={this.onImagePicked}
          accept="image/*"
        />
        <HiddenInput
          type="file"
          innerRef={ref => (this.file = ref)}
          onChange={this.onFilePicked}
          accept="*"
        />
        {this.renderBlockButton("heading2", "heading")}
        <span className="bar-divider"></span>
        {this.renderMarkButton("bold", "bold", "Bold ⌘-b")}
        {this.renderMarkButton("italic", "italic", "Italic ⌘-i")}
        {this.renderMarkButton("strike", "strikethrough", "Strike Through")}
        {this.renderMarkButton("underline", "underline", "Underline ⌘-u")}
        <span className="bar-divider"></span>
        {this.renderBlockButton("bulleted-list", "bulleted-list", "Bulleted list")}
        {this.renderBlockButton("ordered-list", "numbered-list", "Numbered list")}
        <span className="bar-divider"></span>
        <BarButton icon="indent" title="Indent ⌘-[" onMouseDown={e => this.handleIndent(e)} />
        <BarButton icon="outdent" title="Outdent ⌘-[" onMouseDown={e => this.handleIndent(e, false)} />
        <span className="bar-divider"></span>
        {this.renderBlockButton("blockquote", "quote", "Quote")}
        {this.renderBlockButton("codeblock", "code", "Insert Code block")}
        {this.renderBlockButton("horizontal-rule", "hr", "Insert Horizontal line")}
        <span className="bar-divider"></span>
        <BarButton icon="link" title="Insert Link" onMouseDown={this.handleCreateLink} />
        <BarButton icon="image" title="Insert Image" onMouseDown={this.handleImageClick} />
        <BarButton icon="attachment" title="Upload File" onMouseDown={this.handleFileClick} />
      </div>
    </div>
  }
}

const HiddenInput = styled.input`display: none;`;
