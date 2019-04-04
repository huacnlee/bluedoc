const HILIGHT_COLORS = [
  "#D50000",
  "#6f42c1",
  "#AA00FF",
  "#304FFE",
  "#0091EA",
  "#00BFA5",
  "#64DD17",
  "#FFD600",
  "#FF6D00",
  "#3E2723",
]

const COLORS = {
  "red": [
     "#b71c1c",
     "#c62828",
     "#d32f2f",
     "#e53935",
     "#f44336",
     "#ef5350",
     "#e57373",
     "#ef9a9a",
     "#ffcdd2",
    "#ffebee",
  ],
  "purple": [
    "#4a148c",
    "#6a1b9a",
    "#7b1fa2",
    "#8e24aa",
    "#9c27b0",
    "#ab47bc",
    "#ba68c8",
    "#ce93d8",
    "#e1bee7",
    "#f3e5f5",
  ],
  "indigo": [
    "#1a237e",
    "#283593",
    "#303f9f",
    "#3949ab",
    "#3f51b5",
    "#5c6bc0",
    "#7986cb",
    "#9fa8da",
    "#c5cae9",
    "#e8eaf6",
  ],
  "lightblue": [
    "#01579b",
    "#0277bd",
    "#0288d1",
    "#039be5",
    "#03a9f4",
    "#29b6f6",
    "#4fc3f7",
    "#81d4fa",
    "#b3e5fc",
    "#e1f5fe",
  ],
  "teal": [
    "#004d40",
    "#00695c",
    "#00796b",
    "#00897b",
    "#009688",
    "#26a69a",
    "#4db6ac",
    "#80cbc4",
    "#b2dfdb",
    "#e0f2f1",
  ],
  "lightgreen": [
    "#33691e",
    "#558b2f",
    "#689f38",
    "#7cb342",
    "#8bc34a",
    "#9ccc65",
    "#aed581",
    "#c5e1a5",
    "#dcedc8",
    "#f1f8e9",
  ],
  "yellow": [
    "#f57f17",
    "#f9a825",
    "#fbc02d",
    "#fdd835",
    "#ffeb3b",
    "#ffee58",
    "#fff176",
    "#fff59d",
    "#fff9c4",
    "#fffde7",
  ],
  "orange": [
    "#e65100",
    "#ef6c00",
    "#f57c00",
    "#fb8c00",
    "#ff9800",
    "#ffa726",
    "#ffb74d",
    "#ffcc80",
    "#ffe0b2",
    "#fff3e0",
  ],
  "brown": [
    "#3e2723",
    "#4e342e",
    "#5d4037",
    "#6d4c41",
    "#795548",
    "#8d6e63",
    "#a1887f",
    "#bcaaa4",
    "#d7ccc8",
    "#efebe9",
  ],
  "grey": [
    "#212121",
    "#424242",
    "#616161",
    "#757575",
    "#9e9e9e",
    "#bdbdbd",
    "#e0e0e0",
    "#eeeeee",
    "#f5f5f5",
    "#fafafa",
  ],
}

export class ColorPicker extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      color: props.color,
      previewColor: props.color,
    }
  }

  onChange = (color) => {
    const { onChange } = this.props;

    if (onChange) {
      onChange(color);
    }

    this.setState({
      color: color,
      previewColor: color,
    })
  }

  onPreview = (color) => {
    this.setState({
      previewColor: color,
    })
  }

  render() {
    let { className = "dropdown-menu-sw" } = this.props;
    const { color, previewColor } = this.state;

    className = `color-picker dropdown-menu ${className}`;

    return <div className={className}>
      <div className="color-highlights">
        {HILIGHT_COLORS.map(val => <ColorItem activeColor={color} onHover={this.onPreview} onSelect={this.onChange} color={val} />)}
      </div>
      <div className="colors">
        {Object.entries(COLORS).map(([key, colors]) => {
          return (<div className="colors-group">
            {colors.map(val => <ColorItem activeColor={color} onHover={this.onPreview} onSelect={this.onChange} color={val} />)}
          </div>)
        })}
      </div>

      <div className="color-preview">
        <ColorItem color={previewColor} />
        <span className="color-name">{previewColor}</span>
      </div>
    </div>
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

    return <div className="color-picker-item" onMouseOver={this.onHover} active={activeColor == color} onClick={this.onSelect} style={{ background: color }} />
  }
}