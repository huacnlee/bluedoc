import React from "react";
import { SortableContainer, SortableHandle, SortableElement, arrayMove } from 'react-sortable-hoc';

const DragHandle = SortableHandle(() => <span className="draghandle"><i className="fas fa-bars"></i></span>); // This can be any component you want

const TocItemElement = SortableElement(({
  item,
  editing,
  onIndent,
  onUnindent,
  onShowEditing,
  onDeleteItem,
  onKeyPressEdit,
  onChangeField,
  onChange,
  onBlurEdit
}) => {
  let url = item.url || "";
  let title = item.title || "";
  let urlClass = "";
  let titleClass = "";

  if (url.trim().length === 0) {
    url = "no-link";
    urlClass = "placeholder";
  }
  if (title.trim().length === 0) {
    title = "New item";
    titleClass = "placeholder";
  }

  return (
    <div className={`toc-item-drageable toc-item toc-item-d${item.depth}`}>
    <DragHandle />
    <div className="indent-buttons">
      <a href="#" onClick={onUnindent} className="indent-left mr-2"><i class="fas fa-arrow-left"></i></a>
      <a href="#" onClick={onIndent} className="indent-right"><i class="fas fa-arrow-right"></i></a>
    </div>
    <a href="#" onClick={onDeleteItem} className="btn-delete"><i class="fas fa-minus"></i></a>

    {editing === "" && (
      <div>
        <div className={`title item-editable ${titleClass}`} data-field="title" onClick={onShowEditing}>{title}</div>
        <div className={`slug item-editable ${urlClass}`} data-field="url" onClick={onShowEditing}>{url}</div>
      </div>
    )}

    {editing !== "" && (
      <div>
        <input type="text"
            onBlur={onBlurEdit}
            onChange={onChange}
            onKeyUp={onKeyPressEdit}
            data-field="title"
            placeholder="title"
            ref={(input) => { input && editing === "title" && input.focus() }}
            className="form-inplace-edit title"
            value={item.title} />
        <input type="text"
            onBlur={onBlurEdit}
            onChange={onChange}
            onKeyUp={onKeyPressEdit}
            data-field="url"
            placeholder="url"
            ref={(input) => { input && editing === "url" && input.focus() }}
            className="form-inplace-edit slug"
            value={item.url} />
      </div>
    )}
    </div>
  );
});


export default class TocItem extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      item: props.item,
      editing: (props.item.isNew == true ? "title" : ""),
    };
  }

  // indent
  indentItem = (depth) => {
    const item = this.state.item;
    if (!item.depth) {
      item.depth = 0;
    }
    if (depth == 1 && item.depth >= 5) {
      return false;
    }
    if (depth == -1 && item.depth == 0) {
      return false;
    }

    item.depth += depth;

    this.setState({ item: item });
    this.saveChange(item);
  }

  saveChange = (item) => {
    this.props.onChangeItem(this.props.index, item);
  }

  // indent
  onIndent = (e) => {
    e.preventDefault();
    this.indentItem(1);
  }

  // unindent
  onUnindent = (e) => {
    e.preventDefault();
    this.indentItem(-1);
  }

  // switch to editing mode
  onShowEditing = (e) => {
    e.preventDefault();

    const input = e.currentTarget;
    const field = input.getAttribute("data-field");

    this.setState({ editing: field });
  }

  onChangeField = (e) => {
    e.preventDefault();
    const input = e.currentTarget;
    const field = input.getAttribute("data-field");

    const item = this.state.item;
    if (field === "title") {
      item.title = input.value;
    } else {
      item.url = input.value;
    }

    this.setState({ item: item });
  }

  // remove item
  onDeleteItem = (e) => {
    e.preventDefault();
    this.props.onDelete(this.props.index);
  }

  onBlurEdit = (e) => {
    e.preventDefault();
    this.onChangeField(e);
    this.saveChange(this.state.item);
    this.switchReadonly(e);
  }

  switchReadonly = (e) => {
    e.preventDefault();
    this.setState({ editing: "" });
  }

  onKeyPress = (e) => {
    const input = e.currentTarget;
    const field = input.getAttribute("data-field");

    if (e.keyCode === 13) {
      // enter
      this.onChangeField(e);
      this.saveChange(this.state.item);
      this.switchReadonly(e);
      return;
    } else if (e.keyCode === 27) {
      // esc
      this.switchReadonly(e);
      // FIXME: to cancel edit
    }
  }

  render() {
    this.state.item = this.props.item;

    return (
      <TocItemElement
        {...this.props}
        item={this.state.item}
        editing={this.state.editing}
        onIndent={this.onIndent}
        onChange={this.onChangeField}
        onUnindent={this.onUnindent}
        onShowEditing={this.onShowEditing}
        onKeyPressEdit={this.onKeyPress}
        onBlurEdit={this.onBlurEdit}
        onDeleteItem={this.onDeleteItem} />
    )
  }
}


