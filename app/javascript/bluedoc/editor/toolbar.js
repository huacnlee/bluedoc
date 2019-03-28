import styled from 'styled-components';
import BarButton from './bar-button';

// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"

export default class Toolbar extends React.Component {
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
    return false;
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

    return false;
  };

  handleHeading = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();
    const { editor } = this.props;

    this.headingDropdown.current.removeAttribute('open');

    editor._removeListAtRanges();
    if (this.isActiveMarkup(type)) {
      editor.setBlocks('paragraph');
    } else {
      editor.setBlocks(type);
    }

    return false;
  }

  handleCreateLink = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.props.editor._wrapLinkAtRange('http://', { autoFocus: true });
    return false;
  };

  handleImageClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    // simulate a click on the file upload input element
    this.imageFile.click();

    return false;
  }

  handleFileClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.file.click();

    return false;
  }

  handleVideoClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.videoFile.click();

    return false;
  }

  handleIndent = (ev, increase) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;
    if (editor._isRangeInList()) {
      editor._setListLevelAtRanges(increase);
    } else {
      editor._setIndentAtRanges(4, increase);
    }

    return false;
  }

  handleAlign = (ev, align) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    editor._setTextAlignAtRanges(align);

    return false;
  }

  handleAddTex = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;
    editor._insertMath();

    return false;
  }

  toggleList = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;
    editor._toggleListAtRanges(type);

    return false;
  }

  onImagePicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadImageEvent(ev, () => {});
    ev.target.value = '';
  }

  onFilePicked = (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, () => {});
    ev.target.value = '';
  }

  onVideoPicked = (ev) => {
    const { editor } = this.props;
    editor._uploadVideoEvent(ev, () => {});
    ev.target.value = '';
  }

  handleInsertTable = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    editor._insertTable(3, 2);

    return false;
  }

  handleUndo = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    editor.undo();

    return false;
  }

  handleRedo = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    editor.redo();

    return false;
  }

  handleClearFormat = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    editor._clearMarksAtRanges();

    return false;
  }

  renderMarkButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = (ev) => {
      ev.preventDefault();
      ev.stopPropagation();

      this.onClickMark(ev, type);
      return false;
    };
    title = title || type;

    return (
      <BarButton icon={icon} title={this.t(`.${title}`)} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderAlignButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(`align-${type}`);
    const onMouseDown = (ev) => {
      ev.preventDefault();
      ev.stopPropagation();

      this.handleAlign(ev, type);
      return false;
    };
    title = title || type;

    return (
      <BarButton icon={icon} title={this.t(`.${title}`)} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  renderBlockButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(type);
    const onMouseDown = ev => this.onClickBlock(ev, type);

    return (
      <BarButton icon={icon} title={this.t(`.${title}`)} active={isActive} onMouseDown={onMouseDown} />
    );
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`editor.Editor${key}`);
    }
    return i18n.t(key);
  }

  render() {
    const { mode = 'full', value } = this.props;
    const { t } = this;

    const { data } = value
    const undos = data.get('undos')
    const redos = data.get('redos')


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
        {mode === 'full' && (
        <span>
        <BarButton icon="undo" title={this.t('.Undo')} enable={undos && undos.size > 0} onMouseDown={this.handleUndo} />
        <BarButton icon="redo" title={this.t('.Redo')} enable={redos && redos.size > 0} onMouseDown={this.handleRedo} />
        <span className="bar-divider"></span>
        <details ref={this.headingDropdown} className="dropdown details-reset details-overlay">
          <summary className="bar-button"><i className="fas fa-text-heading"></i><div className="dropdown-caret"></div></summary>
          <div className="dropdown-menu dropdown-menu-se">
            <ul>
              <li className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'paragraph')}>{t('.Paragraph')}</li>
              <li className="dropdown-divider"></li>
              <li className="dropdown-item heading2" onMouseDown={e => this.handleHeading(e, 'heading2')}>{t('.Heading 2')}</li>
              <li className="dropdown-item heading3" onMouseDown={e => this.handleHeading(e, 'heading3')}>{t('.Heading 3')}</li>
              <li className="dropdown-item heading4" onMouseDown={e => this.handleHeading(e, 'heading4')}>{t('.Heading 4')}</li>
              <li className="dropdown-item heading5" onMouseDown={e => this.handleHeading(e, 'heading5')}>{t('.Heading 5')}</li>
              <li className="dropdown-item heading6" onMouseDown={e => this.handleHeading(e, 'heading6')}>{t('.Heading 6')}</li>
            </ul>
          </div>
        </details>
        <span className="bar-divider"></span>
        </span>
        )}
        {this.renderMarkButton('bold', 'bold', 'Bold')}
        {this.renderMarkButton('italic', 'italic', 'Italic')}
        {this.renderMarkButton('strike', 'strikethrough', 'Strike Through')}
        {this.renderMarkButton('underline', 'underline', 'Underline')}
        {this.renderMarkButton('code', 'code', 'Inline Code')}
        <BarButton icon="link" title={this.t('.Insert Link')} onMouseDown={this.handleCreateLink} />
        <span className="bar-divider"></span>
        {this.renderBlockButton('bulleted-list', 'bulleted-list', 'Bulleted list')}
        {this.renderBlockButton('ordered-list', 'numbered-list', 'Numbered list')}
        <span className="bar-divider"></span>
        {mode === 'full' && (
        <span>
          <BarButton icon="outdent" title={this.t('.Outdent')} onMouseDown={e => this.handleIndent(e, false)} />
          <BarButton icon="indent" title={this.t('.Indent')} onMouseDown={e => this.handleIndent(e)} />
          <span className="bar-divider"></span>
          {this.renderAlignButton('left', 'align-left', 'Align Left')}
          {this.renderAlignButton('center', 'align-center', 'Align Center')}
          {this.renderAlignButton('right', 'align-right', 'Align Right')}
          {this.renderAlignButton('justify', 'align-justify', 'Align Justify')}
          <span className="bar-divider"></span>
        </span>
        )}
        {this.renderBlockButton('blockquote', 'quote', 'Quote')}
        {this.renderBlockButton('codeblock', 'codeblock', 'Insert Code block')}
        {mode === 'full' && (
        <span>
          {this.renderBlockButton('plantuml', 'uml', 'Insert PlantUML')}
          <BarButton icon="tex" title={this.t('.Insert TeX')} onMouseDown={e => this.handleAddTex(e)} />
          {this.renderBlockButton('horizontal-rule', 'hr', 'Insert Horizontal line')}
        </span>
        )}
        <span className="bar-divider"></span>
        <BarButton icon="image" title={this.t('.Insert Image')} onMouseDown={this.handleImageClick} />
        <BarButton icon="attachment" title={this.t('.Insert File')} onMouseDown={this.handleFileClick} />
        <BarButton icon="video" title={this.t('.Insert Video')} onMouseDown={this.handleVideoClick} />
        {mode === 'full' && (
        <span>
        <BarButton icon="table" title={this.t('.Insert Table')} onMouseDown={this.handleInsertTable} />
        </span>
        )}
        <span className="bar-divider"></span>
        <BarButton icon="clear-style" title={this.t('.Clear Format')} onMouseDown={this.handleClearFormat} />
      </div>
    </div>;
  }
}

const HiddenInput = styled.input`display: none;`;
