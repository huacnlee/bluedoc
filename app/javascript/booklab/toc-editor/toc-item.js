// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
import { SortableElement } from 'react-sortable-hoc';

class TocItem extends React.PureComponent {
  constructor(props) {
    super(props);
    this.inputRef = React.createRef();
  }

  componentDidUpdate(prev) {
    const { active, autoFocus } = this.props;
    if (active && autoFocus !== prev.autoFocus) {
      this.inputRef && this.inputRef.current.focus();
    }
  }

  saveChange = (item = this.props.item) => {
    this.props.onChangeItem(this.props.item.index, item);
  }

  // sync
  onChangeField = (e) => {
    e.preventDefault();
    const input = e.currentTarget;
    const field = input.getAttribute('data-field');
    this.saveChange({
      ...this.props.item,
      [field]: input.value,
    });
  }

  // remove item
  onDeleteItem = () => this.props.onDelete(this.props.item.index)

  onKeyPress = (e) => {
    const input = e.currentTarget;
    if (e.keyCode === 13 || e.keyCode === 27) {
      // enter
      e.preventDefault();
      input.blur();
    }
  }

  onSelectItem = () => {
    this.props.onSelectItem(this.props.item.index);
  }

  handelFolder = () => {
    const { item } = this.props;
    this.saveChange({ ...item, folder: !item.folder });
  }

  render() {
    const {
      item: {
        url, title, depth, showFolder = false, index, folder, id,
      }, active,
    } = this.props;
    return (
      <div index={index} className={`toc-item-drageable toc-item toc-item-d${depth} ${active ? 'active' : ''}`} onClick={this.onSelectItem}>
        {showFolder && <div onClick={this.handelFolder} className={`folder ${folder ? 'rotate' : ''}`}>
          <i class="fas fa-caret"></i>
        </div>}
        <div onClick={this.onDeleteItem} className="btn-delete"><i class="fas fa-minus"></i></div>
        {/* show && edit */}
        <form className={'cell-wrap'}>
          <input
            type="text"
            ref={this.inputRef}
            onChange={this.onChangeField}
            onKeyDown={this.onKeyPress}
            data-field="title"
            placeholder="title"
            className="form-edit title"
            value={title}
          />
          <input
            type="text"
            onChange={this.onChangeField}
            onKeyDown={this.onKeyPress}
            data-field="url"
            placeholder="url"
            className="form-edit slug"
            value={url}
            readOnly={!!id}
          />
        </form>
      </div>
    );
  }
}

export default SortableElement(TocItem);
