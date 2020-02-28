/* eslint-disable no-underscore-dangle */
import styled from 'styled-components';
import BarButton from './bar-button';

// import LinkToolbar from "rich-md-editor/lib/components/Toolbar/LinkToolbar"

export default class Toolbar extends React.Component {
  state = {};

  imageFile = React.createRef();

  file = React.createRef();

  videoFile = React.createRef();

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


  handleHeading = (ev, type) => {
    ev.preventDefault();
    ev.stopPropagation();

    // TODO: Heading

    return false;
  };


  renderButton = (type, icon, title) => {
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
          <div className="dropdown d-inline-block">
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
          {this.renderButton('underline', 'underline', 'Underline')}
          {this.renderButton('code', 'code', 'Inline Code')}
          {this.renderButton('link', 'link', 'Insert Link')}
          <span className="bar-divider" />
          {this.renderButton('blockquote', 'quote', 'Quote')}
          {this.renderButton('codeblock', 'codeblock', 'Insert Code block')}
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
