import { SortableContainer } from 'react-sortable-hoc';
import TocItem from './toc-item';
import DocItem from './doc-item';
import { getFolderLength, getNextNodeIndex, getPrevNodeIndex } from './utils';

const TocItemList = SortableContainer(({
  items, onChangeItem, onDeleteItem, activeIndex, onSelectItem, autoFocus, onIndent,
}) => (
  <div className="toc-item-list" >
    {items.map(item => (
      <TocItem
        key={`item-${item.key}`}
        autoFocus={autoFocus}
        onChangeItem={onChangeItem}
        onIndent={onIndent}
        onDelete={onDeleteItem}
        index={item.index}
        item={item}
        active={activeIndex === item.index}
        onSelectItem={onSelectItem}
      />
    ))}
  </div>
));

const DocItemList = ({ items, onAddItem }) => (
  <div className="doc-item-list">
    {items.map((item, index) => (
      <DocItem key={`item-${index}`} onAddItem={onAddItem} index={index} item={item} />
    ))}
  </div>
);

class TocEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: props.value,
      docItems: this.initDocList(),
      items: this.initTocList(),
      activeIndex: -1,
      autoFocus: 1,
    };
    this.formatTocList = this.formatList();
    this.sorting = false;
  }

  componentDidMount() {
    window.addEventListener('keydown', this.handleHotKey, true);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleHotKey, true);
  }

  // init Toc List
  initTocList = () => {
    const items = JSON.parse(this.props.value);
    // eslint-disable-next-line no-undef
    return items.map(v => ({ ...v, folder: false, key: _.uniqueId() }));
  }

  // init Doc List
  initDocList = () => {
    const docItems = JSON.parse(this.props.docsValue);
    const items = JSON.parse(this.props.value);
    docItems.unshift({ isNew: true, depth: 0 });
    return this.filterDocItems(docItems, items);
  }

  formatList = (items = []) => items.reduce((acc, cur, index, arr) => {
    const { activeIndex } = this.state;
    const { depth } = cur;
    let { folder } = cur;
    const showFolder = arr[index + 1] ? depth < arr[index + 1].depth : false;
    const maxDepth = arr[index - 1] ? arr[index - 1].depth + 1 : depth;
    if (index === activeIndex && this.sorting) {
      folder = true;
    }
    if (!showFolder) {
      folder = false;
    }
    const curItem = {
      index, showFolder, maxDepth, folder,
    };
    if (depth > 0) {
      const prev = acc[acc.length - 1] || {};
      if (prev.depth < depth && prev.folder) {
        return acc;
      }
    }
    return [...acc, { ...cur, ...curItem }];
  }, []);

  handleHotKey = (e) => {
    const { keyCode, shiftKey } = e;
    const { activeIndex, items } = this.state;
    const inputs = ['input', 'select', 'button', 'textarea'];
    const { activeElement } = document;
    if (activeElement && inputs.indexOf(activeElement.tagName.toLowerCase()) !== -1) {
      return;
    }
    if (activeIndex === -1) return;
    // Tab && Tab + Shift
    if (keyCode === 9) {
      e.preventDefault();
      if (shiftKey) {
        this.changeItemIndent(activeIndex, -1);
      } else {
        this.changeItemIndent(activeIndex, 1);
      }
    }
    // up
    if (keyCode === 38 && !shiftKey) {
      e.preventDefault();
      const prevIndex = getPrevNodeIndex(activeIndex, this.formatTocList);
      if (activeIndex > 0) this.onSelectItem(prevIndex);
    }
    // down
    if (keyCode === 40 && !shiftKey) {
      e.preventDefault();
      const nextIndex = getNextNodeIndex(activeIndex, this.formatTocList);
      if (activeIndex < items.length - 1) this.onSelectItem(nextIndex);
    }
    // enter
    if (keyCode === 13 && activeIndex !== -1) {
      this.setState({ autoFocus: this.state.autoFocus + 1 });
    }
  }

  filterDocItems = (docItems, newItems) => docItems.map((item) => {
    const exist = newItems.findIndex(({ url = '', id = '' }) => (url === item.url || id === item.id)) !== -1;
    return {
      ...item,
      exist,
    };
  })

  // Update TocList
  updateValue = (newItems, nextActiveIndex = this.state.activeIndex) => {
    const docItems = this.filterDocItems(this.state.docItems, newItems);
    this.setState({ docItems, items: [...newItems], activeIndex: nextActiveIndex }, () => {
      this.props.onChange(newItems);
    });
  }

  // sort Toc Node
  onSortEnd = ({ oldIndex, newIndex }) => {
    this.sorting = false;
    const { items, activeIndex } = this.state;
    const array = items.slice(0);
    const length = getFolderLength(oldIndex, items);
    let tempIndex = newIndex;
    const direction = oldIndex > newIndex ? 'up' : 'down';
    if (direction === 'down') {
      tempIndex += getFolderLength(newIndex, items);
    }
    if (direction === 'down') {
      tempIndex -= length;
    }
    let tempArr = array.splice(oldIndex, length + 1);
    const curDepth = items[oldIndex].depth;
    if (tempIndex === 0 && curDepth > 0) {
      tempArr = tempArr.map(v => ({
        ...v,
        depth: v.depth - curDepth,
      }));
    }
    array.splice(tempIndex, 0, ...tempArr);
    // change activeIndex
    if (activeIndex !== -1) {
      const activeEle = items[activeIndex];
      const arr = this.formatList(array);
      const nextActiveIndex = array.findIndex(({ key }) => key === activeEle.key);
      const isShow = arr.findIndex(v => v.index === nextActiveIndex);
      this.setState({ activeIndex: isShow ? nextActiveIndex : -1 });
    }
    this.updateValue(array);
  };

  // sort start Toc
  onSortStart = ({ index }) => {
    this.sorting = true;
    this.setState({ activeIndex: index });
  }

  // update TocNode Content
  onChangeItem = (index, item) => {
    const { items } = this.state;
    items[index] = item;
    this.updateValue(items);
  }

  // delete a TocNode
  onDeleteItem = (index) => {
    const { items } = this.state;
    const length = getFolderLength(index, items) + 1;
    items.splice(index, length);
    this.updateValue(items);
  }

  // add a TocNode
  onAddItem = (index, item) => {
    const { items, activeIndex } = this.state;
    // eslint-disable-next-line no-undef
    const newItem = { ...item, key: _.uniqueId(), folder: false };
    const nextIdx = getNextNodeIndex(activeIndex, this.formatTocList);
    if (nextIdx === -1) {
      items.push(newItem);
    } else {
      const { depth, folder, showFolder } = this.formatTocList.find(v => v.index === activeIndex);
      items.splice(nextIdx, 0, { ...newItem, depth: (showFolder && !folder) ? depth + 1 : depth });
    }
    this.updateValue(items);
  }

  // change TocNode depth
  changeItemIndent = (index, direction) => {
    const curItem = this.formatTocList.find(v => v.index === index);
    if (!curItem) return;
    const { depth, maxDepth } = curItem;
    const nextDepth = depth + direction;
    if (nextDepth < 0 || nextDepth > maxDepth) return;
    const { items } = this.state;
    const length = getFolderLength(index, items);
    let folderArr = items.slice(index, index + length + 1);
    folderArr = folderArr.map(v => ({ ...v, depth: v.depth + direction }));
    items.splice(index, length + 1, ...folderArr);
    this.updateValue(items);
  }

  onSelectItem = index => this.setState({ activeIndex: index })

  render() {
    const {
      docItems, items, activeIndex, autoFocus,
    } = this.state;
    this.formatTocList = this.formatList(items);
    return (
      <div className="toc-editor">
        <DocItemList
          items={docItems}
          onAddItem={this.onAddItem}
        />
        <TocItemList
          helperClass="sorting active"
          distance={5}
          autoFocus={autoFocus}
          items={this.formatTocList}
          activeIndex={activeIndex}
          onChangeItem={this.onChangeItem}
          onDeleteItem={this.onDeleteItem}
          onSortStart={this.onSortStart}
          onSortEnd={this.onSortEnd}
          onSelectItem={this.onSelectItem}
          lockAxis="y"
          onIndent={this.changeItemIndent}
        />
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

  const onChange = (items) => {
    items.map(({
      depth,
      id,
      index,
      title,
      url,
    }) => ({
      depth,
      id,
      index,
      title,
      url,
    }));
    const value = JSON.stringify(items);
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
