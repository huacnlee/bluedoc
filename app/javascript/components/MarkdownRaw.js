import CodeMirror from 'react-codemirror'
// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';
require(`codemirror/mode/markdown/markdown`)

export default class MarkdownRaw extends React.PureComponent {
  render() {
    const { value } = this.props;

    return <CodeMirror
        options={{ mode: "markdown" }}
        value={value}
      />
  }
}