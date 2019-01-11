import styled from 'styled-components';
import { BarButton } from './bar-button';

// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"

export class Toolbar extends React.Component {
  state = { }

  headingDropdown = React.createRef()

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
      case 'bulleted-list':
        editor._toggleListAtRanges('bulleted');
        break;
      case 'ordered-list':
        editor._toggleListAtRanges('ordered');
        break;
      case 'todo-list':
        editor._toggleListAtRanges('todo');
        break;
      case 'blockquote':
        if (this.isActiveMarkup('blockquote')) {
          editor._unwrapBlockquoteAtRanges();
        } else {
          editor._wrapBlockquoteAtRanges();
        }
        break;
      case 'horizontal-rule':
        editor._insertHorizontalRule();
        break;
      case 'codeblock':
        if (this.isActiveMarkup('codeblock')) {
          editor.setBlocks('paragraph');
        } else {
          editor._insertCodeblock();
        }
        break;
      case 'plantuml':
        editor._insertPlantUML();
        break;
      default:
        if (this.isActiveMarkup(type)) {
          editor.setBlocks('paragraph');
        } else {
          editor.setBlocks(type);
        }
        break;
    }
  };

  handleHeading = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();
    const { editor } = this.props;

    this.headingDropdown.current.removeAttribute('open');

    if (this.isActiveMarkup(type)) {
      editor.setBlocks('paragraph');
    } else {
      editor.setBlocks(type);
    }
  }

  handleCreateLink = (ev) => {
    ev.preventDefault();

    this.props.editor._wrapLinkAtRange('http://', { autoFocus: true });
  };

  handleImageClick = () => {
    // simulate a click on the file upload input element
    this.imageFile.click();
  }

  handleFileClick = () => {
    this.file.click();
  }

  handleVideoClick = () => {
    this.videoFile.click();
  }

  handleIndent = (ev, increase) => {
    ev.preventDefault();
    const { editor } = this.props;
    if (editor._isRangeInList()) {
      editor._setListLevelAtRanges(increase);
    } else {
      editor._setIndentAtRanges(4, increase);
    }
  }

  handleAlign = (ev, align) => {
    ev.preventDefault();
    const { editor } = this.props;

    editor._setTextAlignAtRanges(align);
  }

  handleAddTex = ev => {
    ev.preventDefault();
    const { editor } = this.props;
    editor._insertMath();
    return false;
  }

  toggleList = (ev, type) => {
    ev.preventDefault();
    const { editor } = this.props;
    editor._toggleListAtRanges(type);
  }

  onImagePicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadImageEvent(ev, () => {});
  }

  onFilePicked = (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, () => {});
  }

  onVideoPicked = (ev) => {
    const { editor } = this.props;
    editor._uploadVideoEvent(ev, () => {});
  }

  renderMarkButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = ev => this.onClickMark(ev, type);
    title = title || type;

    return (
      <BarButton icon={icon} title={title} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderAlignButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup("align-" + type);
    const onMouseDown = ev => this.handleAlign(ev, type);
    title = title || type;

    return (
      <BarButton icon={icon} title={title} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderBlockButton = (type, icon) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = ev => this.onClickBlock(ev, type);

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
        <HiddenInput
          type="file"
          innerRef={ref => (this.videoFile = ref)}
          onChange={this.onVideoPicked}
          accept="video/*"
        />
        <details ref={this.headingDropdown} className="dropdown details-reset details-overlay bar-button">
          <summary><i className="fas fa-text-heading"></i><div className="dropdown-caret"></div></summary>
          <div className="dropdown-menu dropdown-menu-se">
            <ul>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'heading2')}>Heading 2</a></li>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'heading3')}>Heading 3</a></li>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'heading4')}>Heading 4</a></li>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'heading5')}>Heading 5</a></li>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'heading6')}>Heading 6</a></li>
              <li className="dropdown-divider"></li>
              <li><a href="#" className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'paragraph')}>Paragraph</a></li>
            </ul>
          </div>
        </details>
        <span className="bar-divider"></span>
        {this.renderMarkButton('bold', 'bold', 'Bold ⌘-b')}
        {this.renderMarkButton('italic', 'italic', 'Italic ⌘-i')}
        {this.renderMarkButton('strike', 'strikethrough', 'Strike Through')}
        {this.renderMarkButton('underline', 'underline', 'Underline ⌘-u')}
        {this.renderMarkButton('code', 'code', 'Inline Code ⌘-`')}
        <span className="bar-divider"></span>
        {this.renderBlockButton('bulleted-list', 'bulleted-list', 'Bulleted list')}
        {this.renderBlockButton('ordered-list', 'numbered-list', 'Numbered list')}
        <span className="bar-divider"></span>
        <BarButton icon="outdent" title="Outdent ⌘-[" onMouseDown={e => this.handleIndent(e, false)} />
        <BarButton icon="indent" title="Indent ⌘-[" onMouseDown={e => this.handleIndent(e)} />
        <span className="bar-divider"></span>
        {this.renderAlignButton("left", "align-left", "Align Left")}
        {this.renderAlignButton("center", "align-center", "Align center")}
        {this.renderAlignButton("right", "align-right", "Align right")}
        {this.renderAlignButton("justify", "align-justify", "Align justify")}
        <span className="bar-divider"></span>
        {this.renderBlockButton('blockquote', 'quote', 'Quote')}
        {this.renderBlockButton('codeblock', 'codeblock', 'Insert Code block')}
        {this.renderBlockButton('plantuml', 'uml', 'Insert PlantUML')}
        <BarButton icon="tex" title="Insert TeX" onMouseDown={e => this.handleAddTex(e)} />
        {this.renderBlockButton('horizontal-rule', 'hr', 'Insert Horizontal line')}
        <span className="bar-divider"></span>
        <BarButton icon="link" title="Insert Link" onMouseDown={this.handleCreateLink} />
        <BarButton icon="image" title="Insert Image" onMouseDown={this.handleImageClick} />
        <BarButton icon="attachment" title="Insert File" onMouseDown={this.handleFileClick} />
        <BarButton icon="video" title="Insert Video" onMouseDown={this.handleVideoClick} />
      </div>
    </div>;
  }
}

const HiddenInput = styled.input`display: none;`;
