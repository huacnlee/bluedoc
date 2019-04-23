// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';
import RichEditor from 'bluedoc/editor/rich-editor';

export default class Editor extends React.PureComponent {
  inputRef = React.createRef()
  formatInputRef = React.createRef()
  markdownInputRef = React.createRef()
  titleInputRef = React.createRef()
  editorRef = React.createRef()
  editor = null

  avoidSubmit = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    return false;
  }

  setEditor = (editor) => {
    this.editor = editor;
  }

  onChange = (markdownValue, smlValue) => {
    const { format } = this.props;
    this.markdownInputRef.current.value = markdownValue;
    if (smlValue) {
      this.formatInputRef.current.value = "sml";
      this.inputRef.current.value = smlValue;
    }
  }

  onChangeTitle = (newTitle) => {
    this.titleInputRef.current.value = newTitle;
  }

  render() {
    const {
      plantumlServiceHost, mathJaxServiceHost,
      name = 'body_sml', markdownName = 'body', titleName = 'title', formatName = "format", value = '', title = '', format = 'markdown',
    } = this.props;

    return <div>
      <input name={titleName} ref={this.titleInputRef} value={title} style={{ display: 'none' }} />
      <input name={formatName} ref={this.formatInputRef} value={format} style={{ display: 'none' }} />
      <textarea name={name} ref={this.inputRef} style={{ display: 'none' }} />
      <textarea name={markdownName} ref={this.markdownInputRef} style={{ display: 'none' }} />
      <form onSubmit={this.avoidSubmit}>
        <RichEditor
          title={title}
          ref={this.editorRef}
          getEditor={this.setEditor}
          plantumlServiceHost={plantumlServiceHost}
          mathJaxServiceHost={mathJaxServiceHost}
          onChange={this.onChange}
          onChangeTitle={this.onChangeTitle}
          format={format}
          value={value}
        />
      </form>
    </div>;
  }
}