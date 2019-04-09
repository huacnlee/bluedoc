// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
import { SortableElement } from 'react-sortable-hoc';
import cn from 'classnames';

class TocItem extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      canEdit: false,
    };
  }

  componentWillReceiveProps(nextProps) {
    const { autoFocus, active } = nextProps;
    if (active && autoFocus !== this.props.autoFocus) {
      this.setState({ canEdit: true, autoFocus });
    } if (!active) {
      this.setState({ canEdit: false });
    }
  }

  // sync
  onChangeField = (e) => {
    e.preventDefault();
    const input = e.currentTarget;
    const field = input.getAttribute('data-field');
    const { item } = this.props;
    this.props.onChangeItem({
      index: item.index,
      item: {
        ...item,
        [field]: input.value,
      },
    });
  }

  onKeyDown = (e) => {
    if (e.keyCode === 13 || e.keyCode === 27) {
      // enter
      e.preventDefault();
      this.setState({ canEdit: false }, () => this.props.onChangeItem({ memory: true }));
    }
  }

  onSelectItem = () => {
    this.props.onSelectItem(this.props.item.index);
  }

  handelFolder = () => {
    const { item, onChangeItem } = this.props;
    onChangeItem({
      index: item.index,
      item: {
        ...item,
        folder: !item.folder,
      },
    });
  }

  handleEdit = () => this.setState({ canEdit: true })

  handleDelete = () => this.props.onDelete(this.props.item.index)

  handelDoneEdit = () => this.setState({
    canEdit: false,
  }, () => this.props.onChangeItem({ memory: true }))

  render() {
    const {
      item: {
        url, title, depth, showFolder = false, folder, id,
      }, active,
    } = this.props;
    return (
      <li
        className={cn('toc-item', { active })}
        style={{ listStyle: 'none' }}
      >
        <a href={url} className={'item-link'}>{title}</a>
      </li>
    );
  }
}

export default SortableElement(TocItem);
