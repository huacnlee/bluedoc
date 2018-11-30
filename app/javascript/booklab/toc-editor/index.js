import React from "react";
import { SortableContainer, SortableElement, arrayMove } from 'react-sortable-hoc';
import TocItem from "./toc-item";

const TocItemList = SortableContainer(({ items, onChangeItem, onDeleteItem }) => {
  return (
    <div className="toc-item-list">
      {items.map((item, index) => (
        <TocItem key={`item-${index}`} onChange={onChangeItem} onDelete={onDeleteItem} index={index} item={item} />
      ))}
    </div>
  );
});

class TocEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      items: JSON.parse(props.value)
    }
  }

  updateValue = (newItems) => {
    this.props.onChange(JSON.stringify(newItems));
  }

  onSortEnd = ({ oldIndex, newIndex }) => {
    const newItems = arrayMove(this.state.items, oldIndex, newIndex);
    this.updateValue(newItems);
    this.setState({ items: newItems });
  };

  onChangeItem = (index, item) => {
    const { items } = this.state;
    items[index] = item;

    this.updateValue(items);
  }

  onDeleteItem = (index) => {
    const { items } = this.state;
    items.splice(index, 1);

    this.updateValue(items);
    this.setState({ items: items });
  }

  render() {
    return (
      <div className="toc-editor">
        <TocItemList
          items={this.state.items}
          onChangeItem={this.onChangeItem}
          onDeleteItem={this.onDeleteItem}
          onSortEnd={this.onSortEnd}
          lockAxis="y"
          useDragHandle={true} />
      </div>
    )
  }
}

document.addEventListener("turbolinks:load", () => {
  if ($("form textarea#repository_toc").length == 0) {
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