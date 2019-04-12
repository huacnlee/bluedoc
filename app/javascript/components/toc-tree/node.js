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
  constructor(props) {
    super(props);

    const { info, repository } = props;

    let { url } = info;
    if (url && !url.includes('/')) {
      url = `${repository.path}/${url}`;
    }

    this.state = {
      position: '',
      url,
    };
  }

  updatePosition = (position) => {
    if (position !== this.state.position) {
      this.setState({ position });
    }
  }

  isParent = ({ children = [] }) => children && children.length > 0

  render() {
    const {
      active,
      info,
      isOver,
      isDragging,
      canDrop,
      connectDragSource,
      connectDropTarget,
      path,
      editMode,
      toggleExpaned,
    } = this.props;
    const { position, url } = this.state;
    const depth = path.length - 1;
    const isParent = this.isParent(info);
    const { expanded = false } = info;
    return connectDragSource(
      connectDropTarget(
      <li className={cn('toc-item', {
        [`drop-${position}`]: isOver && canDrop && !!position && !(isParent && position === 'child'),
      }, {
        active,
      })} style={{
        marginLeft: `${depth * 15}px`,
        opacity: isDragging ? 0.6 : 1,
      }}>
        {isParent && <i onClick={() => toggleExpaned({ path, expanded })} className={cn('fas fa-arrow', { folder: !expanded })} />}
        <a className="item-link" href={url}>{info.title}</a>
        <a className="item-slug" href={url}>{info.url}</a>
        {editMode && (
          <details className="item-more dropdown details-overlay details-reset d-inline-block">
          <summary className="btn-link"><i className="fas fa-ellipsis"></i></summary>
          <ul className="dropdown-menu dropdown-menu-sw">
            <li><a href={`${info.url}/edit`} className="dropdown-item">编辑文档</a></li>
            <li><a href="#" className="dropdown-item">重命名</a></li>
            <li className="dropdown-divider"></li>
            <li><a href="#" className="dropdown-item">删除</a></li>
          </ul>
        </details>
        )}
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
    canDrag(props) {
      return props.editMode;
    },
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
