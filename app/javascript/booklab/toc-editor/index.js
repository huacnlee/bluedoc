import { SortableContainer, arrayMove } from 'react-sortable-hoc';
import TocItem from './toc-item';
import DocItem from './doc-item';

const TocItemList = SortableContainer(({
  items, onChangeItem, onDeleteItem, activeIndex, onSelectItem,
}) => (
  <div className="toc-item-list">
    {items.map((item, index) => (
      <TocItem
        key={`item-${index}`}
        onChangeItem={onChangeItem}
        onDelete={onDeleteItem}
        index={index}
        item={item}
        active={activeIndex === index}
        onSelectItem={onSelectItem}
      />
    ))}
  </div>
));

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

    let docItems = JSON.parse(props.docsValue);

    docItems.unshift({
      isNew: true,
      depth: 0,
    });
    const items = JSON.parse(props.value);
    docItems = this.filterDocItems(docItems, items);

    this.state = {
      value: props.value,
      docItems,
      items,
      activeIndex: -1,
    };
  }

  componentDidMount() {
    window.addEventListener('keydown', this.handleHotKey);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleHotKey);
  }

  handleHotKey = (e) => {
    const { keyCode, shiftKey } = e;
    const { activeIndex, items } = this.state;
    const activeItem = items[activeIndex];
    const { depth } = activeItem;
    const { activeElement } = document;
    const inputs = ['input', 'select', 'button', 'textarea'];
    if (activeElement && inputs.indexOf(activeElement.tagName.toLowerCase()) !== -1) {
      return;
    }
    if (activeIndex === -1) return;
    // Tab && Tab + Shift
    if (keyCode === 9) {
      e.preventDefault();
      let step = 0;
      if (shiftKey) {
        if (depth <= 0) return;
        step = -1;
      } else {
        if (depth >= 5) return;
        step = 1;
      }
      this.onChangeItem(activeIndex, { ...activeItem, depth: depth + step });
    }
    // ↑
    if (keyCode === 38 && !shiftKey) {
      e.preventDefault();
      if (activeIndex > 0) this.onSelectItem(activeIndex - 1);
    }
    // ↓
    if (keyCode === 40 && !shiftKey) {
      e.preventDefault();
      if (activeIndex < items.length - 1) this.onSelectItem(activeIndex + 1);
    }
    // ↑ + shift
    if (keyCode === 38 && shiftKey) {
      e.preventDefault();
      if (activeIndex <= 0) return;
      const newIndex = activeIndex - 1;
      this.setState({ activeIndex: newIndex }, () => {
        this.onSortEnd({ oldIndex: activeIndex, newIndex });
      });
    }
    // ↓ + shift
    if (keyCode === 40 && shiftKey) {
      e.preventDefault();
      if (activeIndex >= items.length - 1) return;
      const newIndex = activeIndex + 1;
      this.setState({ activeIndex: newIndex }, () => {
        this.onSortEnd({ oldIndex: activeIndex, newIndex });
      });
    }
  }


  filterDocItems = (docItems, newItems) => docItems.map((item) => {
    const exist = newItems.findIndex(({ url = '', id = '' }) => (url === item.url || id === item.id)) !== -1;
    return {
      ...item,
      exist,
    };
  })

  updateValue = (newItems) => {
    const docItems = this.filterDocItems(this.state.docItems, newItems);
    this.setState({ docItems, items: [...newItems] });
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
    const { items, activeIndex } = this.state;
    const newItem = Object.assign({}, item);
    if (activeIndex === -1) {
      items.push(newItem);
    } else {
      items.splice(activeIndex + 1, 0, newItem);
    }
    this.updateValue(items);
  }

  onSelectItem = (index) => {
    this.setState({ activeIndex: index });
  }

  render() {
    const { docItems, items, activeIndex } = this.state;
    return (
      <div className="toc-editor">
        <DocItemList
          items={docItems}
          onAddItem={this.onAddItem}
        />
        <TocItemList
          items={items}
          activeIndex={activeIndex}
          onChangeItem={this.onChangeItem}
          onDeleteItem={this.onDeleteItem}
          onSortEnd={this.onSortEnd}
          onSelectItem={this.onSelectItem}
          lockAxis="y"
          useDragHandle={true} />
      </div>
    );
  }
}

document.addEventListener('turbolinks:load', () => {
  if ($('form textarea#repository_toc').length === 0) {
    return;
  }

  const repositoryTocInput = document.getElementById('repository_toc');
  const repositoryTocByDocsInput = document.getElementById('repository_toc_by_docs');

  const editorDiv = document.createElement('div');
  editorDiv.className = 'toc-editor-container';

  $('form.toc-form').after(editorDiv);

  const onChange = (value) => {
    repositoryTocInput.value = value;
  };

  // eslint-disable-next-line no-undef
  ReactDOM.render(
    <TocEditor
      value={repositoryTocInput.value}
      docsValue={repositoryTocByDocsInput.value}
      onChange={onChange}
    />,
    editorDiv,
  );
});
