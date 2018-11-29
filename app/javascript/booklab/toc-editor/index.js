import React from "react";
import { SortableContainer, SortableElement, arrayMove } from 'react-sortable-hoc';
import TocItem from "./toc-item";

const TocItemList = SortableContainer(({ items, onChangeItem, onDeleteItem }) => {
  return (
    <ul className="toc-item-list">
      {items.map((item, index) => (
        <TocItem key={`item-${index}`} onChange={onChangeItem} onDelete={onDeleteItem} index={index} item={item} />
      ))}
    </ul>
  );
});

class TocEditor extends React.Component {
  state = {
    items: [],
  };

  updateValue = (newItems) => {
    this.props.onChange(JSON.stringify(newItems));
  }

  onSortEnd = ({ oldIndex, newIndex }) => {
    const newItems = arrayMove(this.state.items, oldIndex, newIndex);
    this.setState({
      items: newItems,
    });

    this.updateValue(newItems);
  };

  onChangeItem = (index, item) => {
    const newItems = this.state.items;
    newItems[index] = item;

    this.updateValue(newItems);
  }

  onDeleteItem = (index) => {
    const newItems = this.state.items;
    newItems.splice(index, 1);

    this.updateValue(newItems);
    this.setState({
      items: newItems,
    });
  }

  render() {
    const value = this.props.value;
    this.state.items = JSON.parse(value);

    return (
      <div className="toc-editor">
        <TocItemList
          items={this.state.items}
          onChangeItem={this.onChangeItem}
          onDeleteItem={this.onDeleteItem}
          onSortEnd={this.onSortEnd}
          useDragHandle={true} />
      </div>
    )
  }
}

document.addEventListener("turbolinks:load", () => {
  if ($("form #repository_toc").length == 0) {
    return;
  }

  const repositoryTocInput = document.getElementById("repository_toc");

  const editorDiv = document.createElement("div");
  editorDiv.className = "toc-editor-container";

  $("form.toc-form").after(editorDiv);

  const onChange = (value) => {
    repositoryTocInput.value = value;
  }

  ReactDOM.render(
    <TocEditor value={repositoryTocInput.value} onChange={onChange} />,
    editorDiv,
  )
});