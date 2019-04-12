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
    [...path].reverse().forEach((i, idx) => {
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
    const isMove = this.getDireaction(originalPath, targetPath);
    const newTargetPath = [...targetPath];
    if (isMove) {
      newTargetPath[originalPath.length - 1] -= 1;
    }
    if (position === 'right') {
      newTargetPath[newTargetPath.length - 1] += 1;
    }
    let pos = {};
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
    if (targetPath.length < path.length) return false;
    const flag = path.slice(0, -1).every((i, idx) => i === targetPath[idx]);
    return flag && targetPath[path.length - 1] > path[path.length - 1];
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
        editMode={this.props.editMode}
        active={node.docId === this.props.currentDocId}
      />
      {node.children && this.renderTreeNode(node.children, [...parentPath, index])}
    </>
  ))

  render() {
    const { treeData = [] } = this.props;
    return (
      <ul className="toc-items">
        {this.renderTreeNode(treeData)}
      </ul>
    );
  }
}

export default DragDropContext(HTML5Backend)(Tree);
