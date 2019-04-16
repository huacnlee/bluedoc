import React, { Component } from 'react';
import {
  DragSource,
  DropTarget,
} from 'react-dnd';
import { getEmptyImage } from 'react-dnd-html5-backend';
import cn from 'classnames';
import { getTargetPosition } from './utils';
import confirm from './modal';

class Node extends Component {
  constructor(props) {
    super(props);

    this.state = {
      position: '',
    };

    this.menu = React.createRef();
  }

  componentDidMount() {
    const { connectDragPreview } = this.props;
    if (connectDragPreview) {
      connectDragPreview(getEmptyImage(), { captureDraggingState: true });
    }
  }

  handleLink = () => window.Turbolinks.visit(this.getUrl())

  getUrl = () => {
    const { info: { url }, repository } = this.props;
    if (url && !url.includes('/')) {
      return `${repository.path}/${url}`;
    }
    return url;
  }

  updatePosition = (position) => {
    if (position !== this.state.position) {
      this.setState({ position });
    }
  }

  handleDelete = () => {
    const {
      onDeleteNode, info: { id }, path, active,
    } = this.props;
    onDeleteNode({ id, path, reload: active });
  }

  handleUpdate = () => {
    const {
      info, t, path, onUpdateNode, active,
    } = this.props;
    confirm({
      info,
      t,
      active,
      onSuccessBack: (result) => {
        onUpdateNode({
          result,
          path,
          reload: info.title !== result.title,
        });
      },
    });
  }

  toggleMenu = () => {
    if (this.props.editMode && this.menu) {
      this.menu.current.removeAttribute('open');
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
      t,
    } = this.props;
    const { position } = this.state;
    const depth = path.length - 1;
    const isParent = this.isParent(info);
    const { expanded, title } = info;
    return connectDragSource(
      connectDropTarget(
        <li
          className={cn('toc-item', {
            [`drop-${position}`]: isOver && canDrop && !!position,
          }, { active })}
          style={{
            marginLeft: `${depth * 15}px`,
            opacity: isDragging ? 0.6 : 1,
          }}
          onMouseLeave={this.toggleMenu}
        >
          {isParent && <i onClick={() => toggleExpaned({ path, expanded })} className={cn('fas fa-arrow', { folder: expanded })} />}
          <div className="item-link" onClick={this.handleLink}>{title}</div>
          <div className="item-slug" onClick={this.handleLink}>{info.url}</div>
          {editMode && (
            <details
              className="item-more dropdown details-overlay details-reset d-inline-block"
              ref={this.menu}
            >
              <summary><i className="fas fa-ellipsis"></i></summary>
              <ul className="dropdown-menu dropdown-menu-sw">
                <li><a href={`${info.url}/edit`} className="dropdown-item">{t('.Edit doc')}</a></li>
                <li className='dropdown-item' onClick={this.handleUpdate}>{t('.Setting Doc')}</li>
                <li className='dropdown-divider'></li>
                <li className='dropdown-item' onClick={this.handleDelete}>{t('.Delete doc')}</li>
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
      info: props.info,
      active: props.active,
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
    connectDragPreview: connect.dragPreview(),
    isDragging: monitor.isDragging(),
  }),
)(Node));
