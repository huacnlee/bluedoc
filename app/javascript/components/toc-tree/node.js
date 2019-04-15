import React, { Component } from 'react';
import {
  DragSource,
  DropTarget,
} from 'react-dnd';
import cn from 'classnames';
import { getTargetPosition } from './utils';

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
      onDeleteNode,
      t,
    } = this.props;
    const { position, url } = this.state;
    const depth = path.length - 1;
    const isParent = this.isParent(info);
    const { expanded = false, title, id } = info;
    return connectDragSource(
      connectDropTarget(
      <li className={cn('toc-item', {
        [`drop-${position}`]: isOver && canDrop && !!position,
      }, {
        active,
      })} style={{
        marginLeft: `${depth * 15}px`,
        opacity: isDragging ? 0.6 : 1,
      }}>
        {isParent && <i onClick={() => toggleExpaned({ path, expanded })} className={cn('fas fa-arrow', { folder: !expanded })} />}
        <a className="item-link" href={url}>{title}</a>
        <a className="item-slug" href={url}>{info.url}</a>
        {editMode && (
          <details className="item-more dropdown details-overlay details-reset d-inline-block">
          <summary className="btn-link"><i className="fas fa-ellipsis"></i></summary>
          <ul className="dropdown-menu dropdown-menu-sw">
            <li><a href={`${info.url}/edit`} className="dropdown-item">{t(".Edit doc")}</a></li>
            <li className='dropdown-divider'></li>
            <li className='dropdown-item' onClick={() => onDeleteNode({ id })}>{t(".Delete doc")}</li>
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
      return {
        targetId: props.info.id,
        targetPath: props.path,
        position,
        canDrop: true,
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
