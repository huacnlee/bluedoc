import React from 'react';
import { DragLayer } from 'react-dnd';
import cn from 'classnames';

const layerStyles = {
  position: 'fixed',
  pointerEvents: 'none',
  display: 'flex',
  zIndex: 100,
  left: 0,
  top: 0,
  width: '100%',
  height: '100%',
};

const getItemStyles = ({ currentOffset }) => {
  if (!currentOffset) {
    return {
      display: 'none',
    };
  }
  const { x, y } = currentOffset;
  const transform = `translate(${x}px, ${y}px)`;
  return {
    transform,
    WebkitTransform: transform,
    opacity: 0.5,
  };
};

const CustomDragLayer = (props) => {
  const { item, isDragging, itemType } = props;
  if (!isDragging || !item || itemType !== 'toc') {
    return null;
  }
  const { title } = item.info;
  return (
    <div style={layerStyles}>
      <div style={getItemStyles(props)}>
        <li className={cn('toc-item', { active: item.active })} style={{
          width: '100%',
          paddingRight: '20px',
          boxShadow: '0 4px 7px 0 rgba(190, 190, 190, 1)',
        }}>
          <div className="item-link">{title}</div>
        </li>
      </div>
    </div>
  );
};

export default DragLayer(monitor => ({
  item: monitor.getItem(),
  itemType: monitor.getItemType(),
  currentOffset: monitor.getSourceClientOffset(),
  isDragging: monitor.isDragging(),
}))(CustomDragLayer);
