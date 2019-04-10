import React, { Component } from 'react';
import {
  DragSource,
  DropTarget,
} from 'react-dnd';

class Node extends Component {
  render() {
    const {
      id,
      info,
      isDragging,
      connectDragSource,
      connectDropTarget,
    } = this.props;
    return connectDragSource(
      connectDropTarget(
      <div>
        {info.title}
      </div>,
      ),
    );
  }
}

export default DropTarget(
  'toc',
  {
    drop(props, monitor) {
      const targetItem = monitor.getItem();
      console.log('drop', targetItem, props);
    },
    hover(props, monitor) {
      const { id: draggedId } = monitor.getItem();
      const { id: overId } = props;
      if (draggedId !== overId) {
        const { index: overIndex } = props.findNode(overId);
        // props.moveNode(draggedId, overIndex);
      }
    },
  },
  (connect, monitor) => ({
    connectDropTarget: connect.dropTarget(),
    isOver: monitor.isOver(),
  }),
)(DragSource(
  'toc',
  {
    beginDrag: props => ({
      id: props.id,
      originalIndex: props.findNode(props.id).index,
    }),
    // drop: () => ({ title: 'isdrop' }),
    endDrag(props, monitor) {
      const { id: droppedId, originalIndex } = monitor.getItem();
      const didDrop = monitor.didDrop();
      const dropResult = monitor.getDropResult();
      console.log('end', dropResult, monitor.getItem(), monitor.didDrop());
      if (didDrop) {
        props.moveNode(droppedId, originalIndex);
      }
    },
    isDragging: (props, monitor) => {
      const dropTargetNode = monitor.getItem().node;
      const draggedNode = props.node;

      return draggedNode === dropTargetNode;
    },
  },
  (connect, monitor) => ({
    connectDragSource: connect.dragSource(),
    isDragging: monitor.isDragging(),
  }),
)(Node));
