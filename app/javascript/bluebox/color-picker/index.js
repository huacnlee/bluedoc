const HILIGHT_COLORS = [
  '#D50000',
  '#6f42c1',
  '#AA00FF',
  '#304FFE',
  '#0091EA',
  '#00BFA5',
  '#64DD17',
  '#FFD600',
  '#FF6D00',
  '#3E2723',
];

const COLORS = {
  red: [
    '#b71c1c',
    '#c62828',
    '#d32f2f',
    '#e53935',
    '#f44336',
    '#ef5350',
    '#e57373',
    '#ef9a9a',
    '#ffcdd2',
    '#ffebee',
  ],
  purple: [
    '#4a148c',
    '#6a1b9a',
    '#7b1fa2',
    '#8e24aa',
    '#9c27b0',
    '#ab47bc',
    '#ba68c8',
    '#ce93d8',
    '#e1bee7',
    '#f3e5f5',
  ],
  blue: [
    '#0d47a1',
    '#1565c0',
    '#1976d2',
    '#1e88e5',
    '#2196f3',
    '#42a5f5',
    '#64b5f6',
    '#90caf9',
    '#bbdefb',
    '#e3f2fd',
  ],
  cyan: [
    '#006064',
    '#00838f',
    '#0097a7',
    '#00acc1',
    '#00bcd4',
    '#26c6da',
    '#4dd0e1',
    '#80deea',
    '#b2ebf2',
    '#e0f7fa',
  ],
  green: [
    '#1b5e20',
    '#2e7d32',
    '#388e3c',
    '#43a047',
    '#4caf50',
    '#66bb6a',
    '#81c784',
    '#a5d6a7',
    '#c8e6c9',
    '#e8f5e9',
  ],
  lightgreen: [
    '#33691e',
    '#558b2f',
    '#689f38',
    '#7cb342',
    '#8bc34a',
    '#9ccc65',
    '#aed581',
    '#c5e1a5',
    '#dcedc8',
    '#f1f8e9',
  ],
  yellow: [
    '#f57f17',
    '#f9a825',
    '#fbc02d',
    '#fdd835',
    '#ffeb3b',
    '#ffee58',
    '#fff176',
    '#fff59d',
    '#fff9c4',
    '#fffde7',
  ],
  orange: [
    '#e65100',
    '#ef6c00',
    '#f57c00',
    '#fb8c00',
    '#ff9800',
    '#ffa726',
    '#ffb74d',
    '#ffcc80',
    '#ffe0b2',
    '#fff3e0',
  ],
  brown: [
    '#3e2723',
    '#4e342e',
    '#5d4037',
    '#6d4c41',
    '#795548',
    '#8d6e63',
    '#a1887f',
    '#bcaaa4',
    '#d7ccc8',
    '#efebe9',
  ],
  grey: [
    '#212121',
    '#424242',
    '#616161',
    '#757575',
    '#9e9e9e',
    '#bdbdbd',
    '#e0e0e0',
    '#eeeeee',
    '#f5f5f5',
    '#fafafa',
  ],
};

export class ColorPicker extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      color: props.color,
      previewColor: props.color,
    };
  }

  onChange = (color) => {
    const { onChange } = this.props;

    if (onChange) {
      onChange(color);
    }

    this.setState({
      color,
      previewColor: color,
    });
  }

  onPreview = (color) => {
    this.setState({
      previewColor: color,
    });
  }

  render() {
    let { className = 'dropdown-menu-sw', mode = 'full' } = this.props;
    const { color, previewColor } = this.state;

    className = `color-picker dropdown-menu ${className}`;

    const colors = Object.entries(COLORS);

    return <div className={className}>
      <div className="color-highlights">
        {HILIGHT_COLORS.map(val => <ColorItem activeColor={color} onHover={this.onPreview} onSelect={this.onChange} color={val} />)}
      </div>
      <div className="colors">
        {colors.map(([key, colors]) => (<div className="colors-group">
            {colors.map(val => <ColorItem activeColor={color} onHover={this.onPreview} onSelect={this.onChange} color={val} />)}
          </div>))}
      </div>

      <div className="color-preview">
        <ColorItem color={previewColor} />
        <span className="color-name">{previewColor}</span>
      </div>
    </div>;
  }
}

export class ColorItem extends React.Component {
  onSelect = (e) => {
    const { onSelect } = this.props;

    if (onSelect) {
      onSelect(this.props.color);
    }
  }

  onHover = (e) => {
    const { onHover } = this.props;

    if (onHover) {
      onHover(this.props.color);
    }
  }

  render() {
    const { activeColor, color } = this.props;

    return <div className="color-picker-item" onMouseOver={this.onHover} active={activeColor == color} onClick={this.onSelect} style={{ background: color }} />;
  }
}
