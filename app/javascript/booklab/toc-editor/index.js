import React from "react";
import { SortableContainer, SortableElement, arrayMove } from 'react-sortable-hoc';
import TocItem from "./toc-item";
import DocItem from "./doc-item";
const _ = require("lodash");

const TocItemList = SortableContainer(({ className, items, onChangeItem, onDeleteItem }) => {
  return (
    <div className="toc-item-list">
      {items.map((item, index) => (
        <TocItem key={`item-${index}`} onChangeItem={onChangeItem} onDelete={onDeleteItem} index={index} item={item} />
      ))}
    </div>
  );
});

class DocItemList extends React.Component {
  render() {
    const { items, onAddItem } = this.props;

    return (
      <div className="doc-item-list">
        {items.map((item, index) => (
          <DocItem key={`item-${index}`} onAddItem={onAddItem} index={index} item={item} />
        ))}
      </div>
    );
  }
}


class TocEditor extends React.Component {
  constructor(props) {
    super(props);

    const docItems = JSON.parse(props.docsValue);

    docItems.unshift({
      isNew: true,
      depth: 0
    })

    const items = JSON.parse(props.value);

    this.filterDocItems(docItems, items);

    this.state = {
      value: props.value,
      docItems: docItems,
      items: items
    }
  }

  filterDocItems = (docItems, newItems) => {
    const newItemHash = {};
    const newItemIdHash = {};
    newItems.forEach((item) => {
      newItemHash[item.url] = item;
      newItemIdHash[item.id] = item;
    });

    docItems.forEach((item) => {
      item.exist = false;

      if (!item.url) return false;
      if (newItemHash.hasOwnProperty(item.url) || newItemIdHash.hasOwnProperty(item.id)) {
        item.exist = true;
      }
    });
  }

  updateValue = (newItems) => {
    const { docItems } = this.state;
    this.filterDocItems(docItems, newItems);
    this.setState({ docItems: docItems, items: newItems });
    this.props.onChange(JSON.stringify(newItems));
  }

  onSortEnd = ({ oldIndex, newIndex }) => {
    const newItems = arrayMove(this.state.items, oldIndex, newIndex);
    this.updateValue(newItems);
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
  }

  onAddItem = (index, item) => {
    let { items, docItems } = this.state;
    const newItem = Object.assign({}, item);
    items.push(newItem);

    this.updateValue(items);
  }

  render() {
    const { docItems, items } = this.state;

    return (
      <div className="toc-editor">
        <DocItemList
          items={docItems}
          onAddItem={this.onAddItem}
        />

        <TocItemList
          items={items}
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
  const repositoryTocByDocsInput = document.getElementById("repository_toc_by_docs");

  const editorDiv = document.createElement("div");
  editorDiv.className = "toc-editor-container";

  $("form.toc-form").after(editorDiv);

  const onChange = (value) => {
    repositoryTocInput.value = value;
  }

  ReactDOM.render(
    <TocEditor value={repositoryTocInput.value} docsValue={repositoryTocByDocsInput.value} onChange={onChange} />,
    editorDiv,
  )
});