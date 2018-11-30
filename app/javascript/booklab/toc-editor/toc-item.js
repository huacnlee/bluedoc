import React from "react";
import { SortableContainer, SortableHandle, SortableElement, arrayMove } from 'react-sortable-hoc';

const DragHandle = SortableHandle(() => <span className="draghandle"><i className="fas fa-bars"></i></span>); // This can be any component you want

const TocItemElement = SortableElement(({
  item,
  editing,
  onIndent,
  onUnindent,
  onShowEditing,
  onCancelEditing,
  onChangeField,
  onDeleteItem,
  titleInput,
  urlInput
}) => {
  return (
    <div className={`toc-item-drageable toc-item toc-item-d${item.depth}`}>
    <DragHandle />
    <div className="indent-buttons">
      <a href="#" onClick={onUnindent} className="indent-left mr-2"><i class="fas fa-arrow-left"></i></a>
      <a href="#" onClick={onIndent} className="indent-right"><i class="fas fa-arrow-right"></i></a>
    </div>
    <a href="#" onClick={onDeleteItem} className="btn-delete"><i class="fas fa-trash-alt"></i></a>

    {editing === "" && (
      <div>
        <div className="title item-editable" data-field="title" onClick={onShowEditing}>{item.title}</div>
        <div className="slug item-editable" data-field="url" onClick={onShowEditing}>{item.url}</div>
      </div>
    )}

    {editing !== "" && (
      <div>
        <input type="text"
            onBlur={onCancelEditing}
            onChange={onChangeField}
            data-field="title"
            ref={(input) => { input && editing === "title" && input.focus() }}
            className="form-control title"
            value={item.title} />
        <input type="text"
            onBlur={onCancelEditing}
            onChange={onChangeField}
            data-field="url"
            ref={(input) => { input && editing === "url" && input.focus() }}
            className="form-control slug"
            value={item.url} />
      </div>
    )}
    </div>
  );
});


export default class TocItem extends React.Component {
  state = {
    item: {},
    editing: "",
  }

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
    this.props.onChange(this.props.index, item);
  }

  onIndent = (e) => {
    e.preventDefault();
    this.indentItem(1);
    return false;
  }

  onUnindent = (e) => {
    e.preventDefault();
    this.indentItem(-1);
    return false;
  }

  onShowEditing = (e) => {
    e.preventDefault();

    const input = e.currentTarget;
    const field = input.getAttribute("data-field");


    this.setState({ editing: field });
  }

  onCancelEditing = (e) => {
    e.preventDefault();
    this.setState({ editing: "" });
  }

  onChangeField = (e) => {
    const input = e.currentTarget;
    const field = input.getAttribute("data-field");

    const item = this.state.item;
    if (field === "title") {
      item.title = input.value;
    } else {
      item.url = input.value;
    }

    this.setState({ item: item });
    this.props.onChange(this.props.index, item);
  }

  onDeleteItem = (e) => {
    this.props.onDelete(this.props.index);
  }

  render() {
    this.state.item = this.props.item;

    return (
      <TocItemElement
        {...this.props}
        item={this.state.item}
        editing={this.state.editing}
        onIndent={this.onIndent}
        onUnindent={this.onUnindent}
        onShowEditing={this.onShowEditing}
        onCancelEditing={this.onCancelEditing}
        onChangeField={this.onChangeField}
        onDeleteItem={this.onDeleteItem} />
    )
  }
}


