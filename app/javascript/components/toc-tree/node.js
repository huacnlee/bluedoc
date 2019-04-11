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
    position: '',
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
      canDrop,
      connectDragSource,
      connectDropTarget,
      path,
      children,
    } = this.props;
    const { position } = this.state;
    const depth = path.length;
    const styleList = {
      left: {
        borderTop: '2px solid blue',
      },
      right: {
        borderBottom: '2px solid blue',
      },
      child: {
        background: 'blue',
      },
    };
    const style = (isOver && canDrop && !!position) ? styleList[position] : {};
    return connectDragSource(
      connectDropTarget(
      <li className="toc-item" style={{
        ...style,
        marginLeft: `${depth * 15}px`,
        opacity: isDragging ? 0.2 : 1,
      }}>
        {!!info.children && <i className={'fas fa-arrow folder'}></i>}
        <a className="item-link" href={info.url}>{info.title}</a>
      </li>,
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
    canDrop(props, monitor, component) {
      const { originalPath } = monitor.getItem();
      const { path } = props;
      return !originalPath.every((i, idx) => i === path[idx]);
    },
  },
  (connect, monitor) => ({
    connectDropTarget: connect.dropTarget(),
    isOver: !!monitor.isOver(),
    canDrop: !!monitor.canDrop(),
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
    isDragging(props, monitor) {
      const { originalPath } = monitor.getItem();
      const { path } = props;
      return originalPath.every((i, idx) => i === path[idx]);
    },
  },
  (connect, monitor) => ({
    connectDragSource: connect.dragSource(),
    isDragging: monitor.isDragging(),
  }),
)(Node));
