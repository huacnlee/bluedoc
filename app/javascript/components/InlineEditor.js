// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';
import RichEditor from 'bluedoc/editor/rich-editor';

const defaultSML = '["root",["p",["span",{"t":1},["span",{"t":0},""]]]]';

export default class InlineEditor extends React.PureComponent {
  inputRef = React.createRef()
  markdownInputRef = React.createRef()
  editorRef = React.createRef()
  editor = null

  componentDidMount() {
    const { name } = this.props;
    const eventName = `reset:inline-editor:${name}`;
    document.addEventListener(eventName, this.resetValue);

    const focusEventName = `focus:inline-editor:${name}`;
    document.addEventListener(focusEventName, this.focus);
  }

  resetValue = () => {
    this.editorRef.current.handleReset({ value: '', format: "markdown" });
  }

  focus = () => {
    setTimeout(() => App.scrollTo("#new_comment"), 50);
    this.editor.focus();
  }

  onChange = (markdownValue, smlValue) => {
    const { format } = this.props;
    if (format === 'markdown') {
      this.inputRef.current.value = markdownValue;
    } else {
      this.inputRef.current.value = smlValue;
      this.markdownInputRef.current.value = markdownValue;
    }
  }

  avoidSubmit = (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    return false;
  }

  setEditor = (editor) => {
    this.editor = editor;
  }

  render() {
    const {
      directUploadURL, blobURLTemplate, name = "body_sml", markdownName = "body", value = '', format = 'markdown',
    } = this.props;

    return <div>
      <textarea name={name} ref={this.inputRef} style={{ display: 'none' }} />
      <textarea name={markdownName} ref={this.markdownInputRef} style={{ display: 'none' }} />
      <form onSubmit={this.avoidSubmit}>
        <RichEditor
          mode="inline"
          title=""
          ref={this.editorRef}
          getEditor={this.setEditor}
          directUploadURL={directUploadURL}
          blobURLTemplate={blobURLTemplate}
          onChange={this.onChange}
          format={format}
          value={value}
        />
      </form>
    </div>;
  }
}
