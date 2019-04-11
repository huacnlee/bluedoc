import React, { Component } from 'react';
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import update from 'immutability-helper';
import TreeNode from './node';


class Tree extends Component {
  moveNode = ({
    dragId, targetId, position, originalPath, targetPath,
  }) => {
    const { onChange, onMoveNode } = this.props;
    const dragNode = this.findNode(originalPath);
    const newTreeData = this.getNewData({
      originalPath, targetPath, position, dragNode,
    });
    onChange(newTreeData);
    // fetch server
    onMoveNode({ dragId, targetId, position });
  }

  // get changed treedata
  getNewData = ({
    originalPath, targetPath, position, dragNode,
  }) => {
    const tempData = this.getRemoveData(originalPath);
    return this.getAddData({
      treeData: tempData,
      originalPath,
      targetPath,
      position,
      dragNode,
    });
  }

  // remove dragged node
  getRemoveData = (path) => {
    const { treeData } = this.props;
    let pos = {};
    path.reverse().forEach((i, idx) => {
      if (idx > 0) {
        pos = { [i]: { children: pos } };
      } else {
        pos = { $splice: [[i, 1]] };
      }
    });
    return update(treeData, pos);
  }

  // add dragged node
  getAddData = ({
    treeData,
    originalPath,
    targetPath,
    position,
    dragNode,
  }) => {
    const { direction, depth } = this.getDireaction(originalPath, targetPath);
    const newTargetPath = [...targetPath];
    if (depth < newTargetPath.length && direction === 'down') {
      newTargetPath[depth] -= 1;
    }
    if (position === 'right') {
      newTargetPath[newTargetPath.length - 1] += 1;
    }
    let pos = {};
    // if (!direction || !depth) return null;
    newTargetPath.reverse().forEach((i, idx) => {
      if (idx > 0) {
        pos = { [i]: { children: pos } };
      } else if (position === 'child') {
        pos = { [i]: { $merge: { children: [dragNode] } } };
      } else {
        pos = { $splice: [[i, 0, dragNode]] };
      }
    });
    return update(treeData, pos);
  }

  getDireaction = (path, targetPath) => {
    let direction;
    let depth;
    targetPath.some((i, idx) => {
      if (i === path[idx]) return false;
      depth = idx;
      if (i > path[idx]) {
        direction = 'down';
      } else {
        direction = 'up';
      }
      return true;
    });
    return { direction, depth };
  }

  findNode = (path) => {
    const { treeData } = this.props;
    let result = null;
    path.forEach((i, idx) => {
      if (idx > 0) {
        result = result.children[i];
      } else {
        result = treeData[i];
      }
    });
    return result;
  }

  renderTreeNode = (data = [], parentPath = []) => data.map((node, index) => (
    <>
      <TreeNode
        key={node.id}
        info={node}
        path={[...parentPath, index]}
        moveNode={this.moveNode}
      />
      {this.renderTreeNode(node.children, [...parentPath, index])}
    </>
  ))

  render() {
    const { treeData = [] } = this.props;
    return (
      <div style={{ height: 400 }}>
        {
          this.renderTreeNode(treeData, [])
        }
      </div>
    );
  }
}

export default DragDropContext(HTML5Backend)(Tree);
