export default class Tab extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selecteIndex: this.props.selecteIndex || 0,
    };
  }

  onSelect = (e) => {
    e.preventDefault();

    const index = e.target.getAttribute('index');

    this.setState({
      selecteIndex: index,
    });

    const { onSelect } = this.props;
    if (onSelect) {
      onSelect(index);
    }

    return false;
  };

  render() {
    const { items } = this.props;
    const { selecteIndex } = this.state;

    return (
      <div className="tab">
        {items.map((item, index) => (
          <a
            href="#"
            className={`tab-item ${index == selecteIndex ? 'selected' : ''}`}
            index={index}
            onClick={this.onSelect}
          >
            {item}
          </a>
        ))}
      </div>
    );
  }
}
