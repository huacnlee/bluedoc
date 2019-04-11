import React, { Component } from 'react';
import {
  DragSource,
  DropTarget,
} from 'react-dnd';
import {
  getTargetPosition,
} from './utils';

class Node extends Component {
  state = {
    position: 'right',
  }

  updatePosition = (position) => {
    if (position !== this.state.position) {
      this.setState({ position });
    }
  }

  render() {
    const {
      info,
      isOver,
      isDragging,
      connectDragSource,
      connectDropTarget,
    } = this.props;
    const { position } = this.state;
    console.log(position);
    return connectDragSource(
      connectDropTarget(
      <div>
        {isOver ? position : ''} {info.title} {isDragging ? 'drag' : ''}
      </div>,
      ),
    );
  }
}

export default DropTarget(
  'toc',
  {
    drop(props, monitor, component) {
      const position = getTargetPosition(props, monitor, component);
      return {
        targetId: props.info.id,
        targetPath: props.path,
        position,
      };
    },
    hover(props, monitor, component) {
      const position = getTargetPosition(props, monitor, component);
      component.updatePosition(position);
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
      dragId: props.info.id,
      originalPath: props.path,
    }),
    endDrag(props, monitor) {
      if (!monitor.didDrop()) return;
      props.moveNode({ ...monitor.getItem(), ...monitor.getDropResult() });
    },
  },
  (connect, monitor) => ({
    connectDragSource: connect.dragSource(),
    isDragging: monitor.isDragging(),
  }),
)(Node));
