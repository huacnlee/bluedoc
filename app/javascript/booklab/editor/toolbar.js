import { BarButton } from "./bar-button"
import styled from "styled-components";
// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"

export class Toolbar extends React.Component {
  state = { }

  hasMark = (type) => {
    try {
      return this.props.editor.value.marks.some(mark => mark.type === type);
    } catch (_err) {
      return false;
    }
  }

  isBlock = (type) => {
    const startBlock = this.props.editor.value.startBlock;
    return startBlock && startBlock.type === type;
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
    default:
      editor.change(change => change.setBlocks(type));
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
    const isActive = this.hasMark(type);
    const onMouseDown = ev => this.onClickMark(ev, type);
    title = title || type;

    return (
      <BarButton icon={icon} title={title} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderBlockButton = (type, icon) => {
    const isActive = this.isBlock(type);
    const onMouseDown = ev =>
      this.onClickBlock(ev, isActive ? "paragraph" : type);

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
        <BarButton icon="bulleted-list" title="Bulleted list" onMouseDown={e => this.toggleList(e, "bulleted")} />
        <BarButton icon="numbered-list" title="Numbered list" onMouseDown={e => this.toggleList(e, "ordered")} />
        <span className="bar-divider"></span>
        <BarButton icon="indent" title="Indent ⌘-[" onMouseDown={e => this.handleIndent(e)} />
        <BarButton icon="outdent" title="Outdent ⌘-[" onMouseDown={e => this.handleIndent(e, false)} />
        <span className="bar-divider"></span>
        {this.renderBlockButton("block-quote", "quote", "Quote")}
        {this.renderBlockButton("code", "code", "Insert Code block")}
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
