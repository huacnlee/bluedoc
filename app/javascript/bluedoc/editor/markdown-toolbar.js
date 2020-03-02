/* eslint-disable no-underscore-dangle */
import styled from 'styled-components';
import { SetValueOperation } from 'slate';
import BarButton from './bar-button';

export default class Toolbar extends React.Component {
  imageFile = React.createRef();

  file = React.createRef();

  videoFile = React.createRef();

  constructor(props) {
    super(props);

    const { editor } = props;

    this.state = {
      editor,
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`editor.Editor${key}`);
    }
    return i18n.t(key);
  };

  handleImageClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    // simulate a click on the file upload input element
    this.imageFile.current.click();

    return false;
  };

  handleFileClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();

    this.file.current.click();

    return false;
  };

  handleVideoClick = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    this.videoFile.current.click();

    return false;
  };

  onImagePicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, 'image', () => { });
  };

  onFilePicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, 'file', () => { });
  };

  onVideoPicked = async (ev) => {
    const { editor } = this.props;
    editor._uploadFileEvent(ev, 'video', () => { });
  };

  isActiveMarkup = (type) => {
    const { editor } = this.props;
    const cm = editor.codemirror;
    if (!cm) return false;

    const pos = cm.getCursor('start');
    const stat = cm.getTokenAt(pos);
    if (!stat.type) return false;
    const types = stat.type.split(' ');

    for (let i = 0; i < types.length; i++) {
      const mark = types[i];
      if (mark === type) {
        return true;
      }
    }

    return false;
  };


  /**
   * When a mark button is clicked, toggle the current mark.
   *
   * @param {Event} ev
   * @param {String} type
   */
  onClickMark = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    switch (type) {
      case 'bold':
        editor._bold();
        break;
      case 'italic':
        editor._italic();
        break;
      case 'strike':
        editor._strike();
        break;
      case 'link':
        editor._link();
        break;
      case 'image':
        editor._image();
        break;
      case 'code':
        editor._code();
        break;
      case 'numbered-list':
        editor._numberedList();
        break;
      case 'bulleted-list':
        editor._bulletedList();
        break;
      case 'blockquote':
        editor._blockquote();
        break;
      case 'codeblock':
        editor._codeblock();
        break;
      default:
        break;
    }

    return false;
  };


  handleHeading = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    const { editor } = this.props;

    switch (type) {
      case 'heading1':
        editor._heading(1);
        break;
      case 'heading2':
        editor._heading(2);
        break;
      case 'heading3':
        editor._heading(3);
        break;
      case 'heading4':
        editor._heading(4);
        break;
      case 'heading5':
        editor._heading(5);
        break;
      case 'heading6':
        editor._heading(6);
        break;
      default:
        break;
    }

    return false;
  };

  handleUndo = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    const { editor } = this.props;
    editor._undo();
  }

  handleRedo = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    const { editor } = this.props;
    editor._redo();
  }

  renderButton = (type, icon, title) => {
    const isActive = this.isActiveMarkup(type);

    const onMouseDown = (ev) => {
      ev.preventDefault();
      ev.stopPropagation();

      this.onClickMark(ev, type);
      return false;
    };
    title = title || type;

    return (
      <BarButton
        icon={icon}
        active={isActive}
        title={this.t(`.${title}`)}
        onMouseDown={onMouseDown}
      />
    );
  };


  render() {
    const { mode = 'full', value } = this.props;
    const { t } = this;

    return (
      <div className="editor-toolbar markdown-toolbar">
        <div className="container">
          <HiddenInput
            type="file"
            innerRef={this.imageFile}
            onChange={this.onImagePicked}
            accept="image/jpg, image/jpeg, image/png, image/gif, image/tiff"
          />
          <HiddenInput type="file" innerRef={this.file} onChange={this.onFilePicked} accept="*" />
          <HiddenInput
            type="file"
            innerRef={this.videoFile}
            onChange={this.onVideoPicked}
            accept="video/mp4,video/x-m4v,video/*"
          />
          {mode === 'full' && (
            <span>
              <BarButton
                icon="undo"
                title={this.t('.Undo')}
                onMouseDown={this.handleUndo}
              />
              <BarButton
                icon="redo"
                title={this.t('.Redo')}
                onMouseDown={this.handleRedo}
              />
              <span className="bar-divider" />
            </span>
          )}
          <div className="dropdown d-inline-block">
            <button className="bar-button">
              <i className="fas fa-text-heading" />
              <div className="dropdown-caret" />
            </button>
            <div className="dropdown-menu dropdown-menu-se">
              <ul>
                <li
                  className="dropdown-item heading2"
                  onMouseDown={e => this.handleHeading(e, 'heading2')}
                >
                  {t('.Heading 2')}
                </li>
                <li
                  className="dropdown-item heading3"
                  onMouseDown={e => this.handleHeading(e, 'heading3')}
                >
                  {t('.Heading 3')}
                </li>
                <li
                  className="dropdown-item heading4"
                  onMouseDown={e => this.handleHeading(e, 'heading4')}
                >
                  {t('.Heading 4')}
                </li>
                <li
                  className="dropdown-item heading5"
                  onMouseDown={e => this.handleHeading(e, 'heading5')}
                >
                  {t('.Heading 5')}
                </li>
                <li
                  className="dropdown-item heading6"
                  onMouseDown={e => this.handleHeading(e, 'heading6')}
                >
                  {t('.Heading 6')}
                </li>
              </ul>
            </div>
          </div>
          <span className="bar-divider" />
          {this.renderButton('bold', 'bold', 'Bold')}
          {this.renderButton('italic', 'italic', 'Italic')}
          {this.renderButton('strike', 'strikethrough', 'Strike Through')}
          {this.renderButton('link', 'link', 'Insert Link')}
          {this.renderButton('code', 'code', 'Inline Code')}
          <span className="bar-divider" />
          {this.renderButton('blockquote', 'quote', 'Quote')}
          {this.renderButton('codeblock', 'codeblock', 'Insert Code block')}
          <span className="bar-divider" />
          {this.renderButton('bulleted-list', 'bulleted-list', 'Bulleted list')}
          {this.renderButton('numbered-list', 'numbered-list', 'Numbered list')}
          <span className="bar-divider" />
          <BarButton
            icon="image"
            title={this.t('.Insert Image')}
            onMouseDown={this.handleImageClick}
          />
          <BarButton
            icon="attachment"
            title={this.t('.Insert File')}
            onMouseDown={this.handleFileClick}
          />
          <BarButton
            icon="video"
            title={this.t('.Insert Video')}
            onMouseDown={this.handleVideoClick}
          />
        </div>
      </div>
    );
  }
}

const HiddenInput = styled.input`
  display: none;
`;
