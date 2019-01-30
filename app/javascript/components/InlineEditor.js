// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';
import RichEditor from 'booklab/editor/rich-editor';

export default class InlineEditor extends React.PureComponent {
  inputRef = React.createRef()

  editorRef = React.createRef()

  componentDidMount() {
    const { name } = this.props;
    const eventName = `reset:inline-editor:${name}`;
    document.addEventListener(eventName, this.resetValue);
  }

  resetValue = () => {
    this.editorRef.current.handleReset({ value: '', format: this.props.format });
  }

  onChange = (markdownValue, smlValue) => {
    const { format } = this.props;
    if (format === 'markdown') {
      this.inputRef.current.value = markdownValue;
    } else {
      this.inputRef.current.value = smlValue;
    }
  }

  render() {
    const {
      directUploadURL, blobURLTemplate, name, value = '', format = 'markdown',
    } = this.props;

    return <div>
      <textarea name={name} ref={this.inputRef} style={{ display: 'none' }} />
      <RichEditor
        mode="inline"
        title=""
        ref={this.editorRef}
        directUploadURL={directUploadURL}
        blobURLTemplate={blobURLTemplate}
        onChange={this.onChange}
        format={format}
        value={value}
      />
    </div>;
  }
}
