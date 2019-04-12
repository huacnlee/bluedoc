import React, { Component } from 'react';
import {
  DragSource,
  DropTarget,
} from 'react-dnd';
import cn from 'classnames';
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

  isParent = ({ children = [] }) => children && children.length > 0

  render() {
    const {
      info,
      isOver,
      isDragging,
      canDrop,
      connectDragSource,
      connectDropTarget,
      path,
    } = this.props;
    const { position } = this.state;
    const depth = path.length - 1;
    const isParent = this.isParent(info);
    return connectDragSource(
      connectDropTarget(
      <li className={cn('toc-item', {
        [`drop-${position}`]: isOver && canDrop && !!position && !(isParent && position === 'child'),
      })} style={{
        marginLeft: `${depth * 15}px`,
        opacity: isDragging ? 0.2 : 1,
      }}>
        {isParent && <i className={'fas fa-arrow folder'}></i>}
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
      const hasChild = props.info.children && props.info.children.length > 1;
      return {
        targetId: props.info.id,
        targetPath: props.path,
        position,
        canDrop: !(position === 'child' && hasChild),
      };
    },
    hover(props, monitor, component) {
      const position = getTargetPosition(props, monitor, component);
      component.updatePosition(position);
    },
    canDrop(props, monitor) {
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
      const { canDrop, ...resultDrop } = monitor.getDropResult();
      if (!canDrop) return;
      props.moveNode({ ...monitor.getItem(), ...resultDrop });
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
