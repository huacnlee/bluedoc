import React from "react";
import { SortableContainer, SortableHandle, SortableElement, arrayMove } from 'react-sortable-hoc';

const DragHandle = SortableHandle(() => <span className="draghandle"><i className="fas fa-news-feed"></i></span>); // This can be any component you want

const TocItemElement = SortableElement(({
  item: {url = '', title = '', depth },
  onIndent,
  onUnindent,
  onDeleteItem,
  onKeyPressEdit,
  onChange,
}) => {
  return (
    <div className={`toc-item-drageable toc-item toc-item-d${depth}`}>
      {/* drag */}
      <DragHandle />
      {/* indentation */}
      <div onClick={onUnindent} className="indent-left mr-2"><i class="fas fa-left"></i></div>
      <div onClick={onIndent} className="indent-right"><i class="fas fa-right"></i></div>
      {/* delete */}
      <div onClick={onDeleteItem} className="btn-delete"><i class="fas fa-minus"></i></div>
      {/* show && edit */}
      <form className={'cell-wrap'}>
        <input type="text"
          onChange={onChange}
          onKeyUp={onKeyPressEdit}
          data-field="title"
          placeholder="title"
          className="form-edit title"
          value={title} />
        <input type="text"
          onChange={onChange}
          onKeyUp={onKeyPressEdit}
          data-field="url"
          placeholder="url"
          className="form-edit slug"
          value={url} />
      </form>
    </div>
  );
});


export default class TocItem extends React.PureComponent {
  constructor(props) {
    super(props);
  }

  // indent
  indentItem = (step) => {
    const { item } = this.props;
    let depth = item.depth;
    if (!depth) {
      depth = 0;
    }
    if (depth == 1 && depth >= 5) {
      return false;
    }
    if (depth == -1 && depth == 0) {
      return false;
    }
    depth += step;
    this.saveChange({...item, depth});
  }

  saveChange = (item = this.props.item) => {
    this.props.onChangeItem(this.props.index, item);
  }

  // indent
  onIndent = (e) => this.indentItem(1)

  // unindent
  onUnindent = (e) => this.indentItem(-1)

  // sync
  onChangeField = (e) => {
    e.preventDefault();
    const input = e.currentTarget;
    const field = input.getAttribute("data-field");
    this.saveChange({
      ...this.props.item,
      [field]: input.value
    })
  }

  // remove item
  onDeleteItem = () => this.props.onDelete(this.props.index)

  onKeyPress = (e) => {
    const input = e.currentTarget;
    if (e.keyCode === 13) {
      // enter
      input.blur();
    } else if (e.keyCode === 27) {
      // esc
      // FIXME: to cancel edit
    }
  }

  render() {
    const {index, item} = this.props;
    return (
      <TocItemElement
        index={index}
        item={item}
        onIndent={this.onIndent}
        onChange={this.onChangeField}
        onUnindent={this.onUnindent}
        onKeyPressEdit={this.onKeyPress}
        onDeleteItem={this.onDeleteItem} />
    )
  }
}
