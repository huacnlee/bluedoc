import React from 'react';
import { DragLayer } from 'react-dnd';
import cn from 'classnames';
import { FormHelperText } from '@material-ui/core';

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

const getItemStyles = ({ initialOffset, currentOffset }) => {
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
  const { item, isDragging } = props;
  if (!isDragging || !item) {
    return null;
  }
  const { title, children, expanded } = item.info;
  const isParent = children && children.length > 0;
  return (
    <div style={layerStyles}>
      <div style={getItemStyles(props)}>
        <li className={cn('toc-item', { active: item.active })}>
          <div className="item-link" href="#">{title}</div>
        </li>
      </div>
    </div>
  );
};

export default DragLayer(monitor => ({
  item: monitor.getItem(),
  currentOffset: monitor.getSourceClientOffset(),
  isDragging: monitor.isDragging(),
}))(CustomDragLayer);
