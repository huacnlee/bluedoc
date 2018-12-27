import TocList from './toc-list';
import DocList from './doc-list';
import Hotkeys from './HotKeys';
import {
  getFolderLength,
  getNextNodeIndex,
  getPrevNodeIndex,
  getCurNode,
  isFocusInput,
  getIndexSameDepth,
} from './utils';

const hotKeyMap = [
  'up',
  'down',
  'tab',
  'shift+tab',
  'command+up',
  'command+down',
  'command+left',
  'command+right',
  'command+backspace',
  'enter'
];

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

  // init Toc List
  initTocList = () => {
    const items = JSON.parse(this.props.value);
    // eslint-disable-next-line no-undef
    return items.map(v => ({ ...v, folder: false, key: _.uniqueId() }));
  }
  // init Doc List
  initDocList = () => JSON.parse(this.props.docsValue);

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

  handleHotKey = (key, event) => {
    if (isFocusInput()) return;
    const { activeIndex } = this.state;
    event.preventDefault();
    switch (key) {
      case 'up':
        this.handleHotKeySelect(-1);
        break;
      case 'down':
        this.handleHotKeySelect(1);
        break;
      case 'tab':
        this.changeItemIndent(activeIndex, 1);
        break;
      case 'shift+tab':
        this.changeItemIndent(activeIndex, -1);
        break;
      case 'command+right':
        this.changeItemIndent(activeIndex, 1);
        break;
      case 'command+left':
        this.changeItemIndent(activeIndex, -1);
        break;
      case 'command+up':
        this.handleHotKeySort(-1);
        break;
      case 'command+down':
        this.handleHotKeySort(1);
        break;
      case 'enter':
        this.setState({ autoFocus: this.state.autoFocus + 1 });
        break;
      case 'command+backspace':
        this.onDeleteItem(activeIndex);
        break;
      default:
        break;
    }
  }

  // hotkey to sort
  handleHotKeySort = (direction) => {
    const { items, activeIndex } = this.state;
    if (direction !== 1 && direction !== -1) {
      return;
    }
    const tempIndex = getIndexSameDepth(activeIndex, this.formatTocList, direction);
    const { depth = -1 } = items[tempIndex] || {};
    if (depth === items[activeIndex].depth) {
      this.onSortEnd({ oldIndex: activeIndex, newIndex: tempIndex });
    }
  }

  // hotkey to select
  handleHotKeySelect = (direction) => {
    const { activeIndex } = this.state;
    if (direction === 1) {
      const nextIndex = getNextNodeIndex(activeIndex, this.formatTocList);
      nextIndex > -1 && this.onSelectItem(nextIndex);
    }
    if (direction === -1) {
      const prevIndex = getPrevNodeIndex(activeIndex, this.formatTocList);
      prevIndex > -1 && this.onSelectItem(prevIndex);
    }
  }

  // Update TocList
  updateValue = (newItems, nextActiveIndex = this.state.activeIndex) => {
    this.setState({ items: [...newItems], activeIndex: nextActiveIndex }, () => {
      this.props.onChange(newItems);
    });
  }

  // sort Toc Node
  onSortEnd = ({ oldIndex, newIndex }) => {
    const isDrag = this.sorting;
    const { items, activeIndex } = this.state;
    const array = items.slice(0);
    const length = getFolderLength(oldIndex, items);
    const direction = oldIndex > newIndex ? 'up' : 'down';
    const oldDepth = items[oldIndex].depth;
    let targetIndex = newIndex;
    let tempIndex = newIndex;
    this.sorting = false;
    if (direction === 'up') {
      targetIndex = getPrevNodeIndex(newIndex, this.formatTocList);
    }
    if (direction === 'down') {
      const { showFolder = false, folder = false } = getCurNode(oldIndex, this.formatTocList) || {};
      if (showFolder && folder) {
        tempIndex += getFolderLength(newIndex, items);
      }
      if (!isDrag) {
        tempIndex += getFolderLength(newIndex, items);
      }
      tempIndex -= length;
    }
    const {
      depth = 0,
      showFolder = false,
      folder = false,
    } = getCurNode(targetIndex, this.formatTocList) || {};
    const targetDepth = showFolder && !folder ? depth + 1 : depth;
    const disDepth = isDrag ? oldDepth - targetDepth : 0;
    const tempArr = array.splice(oldIndex, length + 1).map(v => ({
      ...v,
      depth: v.depth - disDepth,
    }));
    array.splice(tempIndex, 0, ...tempArr);
    // change activeIndex
    if (activeIndex !== -1) {
      const activeEle = items[activeIndex];
      const nextActiveIndex = array.findIndex(({ key }) => key === activeEle.key);
      this.setState({ activeIndex: nextActiveIndex });
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
    let nextActive = index;
    if(index > items.length - length) {
      nextActive = items.length - length;
    }
    this.updateValue(items, nextActive);
  }

  // add a TocNode
  onAddItem = (item) => {
    const { items, activeIndex } = this.state;
    // eslint-disable-next-line no-undef
    const newItem = { ...item, key: _.uniqueId(), folder: false };
    const nextIdx = getNextNodeIndex(activeIndex, this.formatTocList);
    const curNode = getCurNode(activeIndex, this.formatTocList);
    let nextActive = items.length;
    if (nextIdx === -1 || !curNode) {
      items.push(newItem);
    } else {
      const { depth, folder, showFolder } = curNode;
      items.splice(nextIdx, 0, { ...newItem, depth: (showFolder && !folder) ? depth + 1 : depth });
      nextActive = nextIdx;
    }
    this.updateValue(items, nextActive);
  }

  // change TocNode depth
  changeItemIndent = (index, direction) => {
    const curNode = getCurNode(index, this.formatTocList);
    if (!curNode) return;
    const { depth, maxDepth } = curNode;
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
        <DocList
          docItems={docItems}
          tocItems={items}
          onAddItem={this.onAddItem}
        />
        <TocList
          helperClass="sorting active"
          distance={5}
          autoFocus={autoFocus}
          items={this.formatTocList}
          activeIndex={activeIndex}
          onChangeItem={this.onChangeItem}
          onSortStart={this.onSortStart}
          onSortEnd={this.onSortEnd}
          onSelectItem={this.onSelectItem}
          onIndent={this.changeItemIndent}
        />
        <Hotkeys keyName={hotKeyMap.join(',')} onKeyDown={this.handleHotKey}></Hotkeys>
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
      depth, id, index, title, url,
    }) => ({
      depth, id, index, title, url,
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
