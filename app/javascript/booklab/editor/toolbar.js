import { BarButton } from "./bar-button"
import styled from "styled-components";
// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"
import { insertImageFile, insertFile } from "./changes"

function getLinkInSelection(value) {
  try {
    const selectedLinks = value.document
      .getInlinesAtRange(value.selection)
      .filter(node => node.type === "link");

    if (selectedLinks.size) {
      const link = selectedLinks.first();
      if (value.selection.hasEdgeIn(link)) return link;
    }
  } catch (err) {
    // It's okay.
  }
}

function getDataTransferFiles(event) {
  let dataTransferItemsList = [];

  if (event.dataTransfer) {
    const dt = event.dataTransfer;
    if (dt.files && dt.files.length) {
      dataTransferItemsList = dt.files;
    } else if (dt.items && dt.items.length) {
      // During the drag even the dataTransfer.files is null
      // but Chrome implements some drag store, which is accesible via dataTransfer.items
      dataTransferItemsList = dt.items;
    }
  } else if (event.target && event.target.files) {
    dataTransferItemsList = event.target.files;
  }
  // Convert from DataTransferItemsList to the native Array
  return Array.prototype.slice.call(dataTransferItemsList);
}

export class Toolbar extends React.Component {
  state = {
    link: undefined
  }

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

    this.props.editor.change(change => {
      change.toggleMark(type);

      // ensure we remove any other marks on inline code
      // we don't allow bold / italic / strikethrough code.
      const isInlineCode = this.hasMark("code") || type === "code";
      if (isInlineCode) {
        change.value.marks.forEach(mark => {
          if (mark.type !== "code") change.removeMark(mark);
        });
      }
    });
  };

  onClickBlock = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.props.editor.change(change => change.setBlocks(type));
  };

  handleCreateLink = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const data = { href: "" };
    this.props.editor.change(change => {
      change.wrapInline({ type: "link", data });
      this.showLinkToolbar(ev);
    });
  };

  showLinkToolbar = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const link = getLinkInSelection(this.props.value);
    this.setState({ link: link })
  }

  hideLinkToolbar = () => {
    this.setState({ link: undefined })
  }

  handleImageClick = () => {
    // simulate a click on the file upload input element
    this.imageFile.click();
  }

  handleFileClick = () => {
    this.file.click();
  }

  onImagePicked = async (ev) => {
    const files = getDataTransferFiles(ev);
    const { editor } = this.props;

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      editor.change(change => change.call(insertImageFile, file, editor));
    }
  }

  onFilePicked = async (ev) => {
    const files = getDataTransferFiles(ev);
    const { editor } = this.props;

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      editor.change(change => change.call(insertFile, file, editor));
    }
  }

  renderMarkButton = (type, icon) => {
    const isActive = this.hasMark(type);
    const onMouseDown = ev => this.onClickMark(ev, type);

    return (
      <BarButton icon={icon} title={type} active={isActive} onMouseDown={onMouseDown} />
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
        {this.renderMarkButton("bold", "bold")}
        {this.renderMarkButton("italic", "italic")}
        {this.renderMarkButton("deleted", "strikethrough")}
        {this.renderMarkButton("underlined", "underline")}
        <span className="bar-divider"></span>
        {this.renderBlockButton("bulleted-list", "bulleted-list")}
        {this.renderBlockButton("ordered-list", "numbered-list")}
        <span className="bar-divider"></span>
        {this.renderBlockButton("block-quote", "quote")}
        {this.renderBlockButton("code", "code")}
        {this.renderBlockButton("horizontal-rule", "hr")}
        <span className="bar-divider"></span>
        <BarButton icon="link" title="Insert Link" onMouseDown={this.handleCreateLink} />
        <BarButton icon="image" title="Insert Image" onMouseDown={this.handleImageClick} />
        <BarButton icon="attachment" title="Upload File" onMouseDown={this.handleFileClick} />
      </div>
    </div>
  }
}

const HiddenInput = styled.input`display: none;`;
