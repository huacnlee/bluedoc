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
        break;
      case 'italic':
        break;
      case 'strike':
        break;
      case 'ordered-list':
        break;
      case 'blockquote':
        break;
      case 'codeblock':
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
        break;
      case 'heading2':
        break;
      case 'heading3':
        break;
      default:
        break;
    }

    return false;
  };

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
          {/* <div className="dropdown d-inline-block">
            <button className="bar-button">
              <i className="fas fa-text-heading" />
              <div className="dropdown-caret" />
            </button>
            <div className="dropdown-menu dropdown-menu-se">
              <ul>
                <li className="dropdown-item" onMouseDown={e => this.handleHeading(e, 'paragraph')}>
                  {t('.Paragraph')}
                </li>
                <li className="dropdown-divider" />
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
              </ul>
            </div>
          </div>
          <span className="bar-divider" />
          {this.renderButton('bold', 'bold', 'Bold')}
          {this.renderButton('italic', 'italic', 'Italic')}
          {this.renderButton('strike', 'strikethrough', 'Strike Through')}
          {this.renderButton('underline', 'underline', 'Underline')}
          {this.renderButton('code', 'code', 'Inline Code')}
          {this.renderButton('link', 'link', 'Insert Link')}
          <span className="bar-divider" />
          {this.renderButton('blockquote', 'quote', 'Quote')}
          {this.renderButton('codeblock', 'codeblock', 'Insert Code block')}
          <span className="bar-divider" /> */}
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
