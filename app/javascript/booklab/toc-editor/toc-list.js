import { SortableContainer } from 'react-sortable-hoc';
import TocItem from './toc-item';

export default SortableContainer(({
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