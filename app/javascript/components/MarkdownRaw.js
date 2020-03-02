import CodeMirror from 'react-codemirror';

require('codemirror/mode/markdown/markdown.js');
require('codemirror/mode/gfm/gfm.js');

export default class MarkdownRaw extends React.PureComponent {
  render() {
    const { value } = this.props;

    return <CodeMirror
      options={{ mode: 'gfm', lineWrapping: true }}
      value={value}
    />;
  }
}
