import React, { Component } from 'react';
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import update from 'immutability-helper';
import TreeNode from './node';


class Tree extends Component {
  // del node event
  delNode = ({
    id,
    path,
    reload,
  }) => {
    const { onChange, onDeleteNode } = this.props;
    const newTreeData = this.getRemoveData(path);
    !reload && onChange(newTreeData);
    onDeleteNode({ id }, reload);
  }

  // update node info event
  updateNode = ({
    result,
    path,
  }) => {
    const { treeData, onChange } = this.props;

    let pos;
    [...path].reverse().forEach((i, idx) => {
      if (idx > 0) {
        pos = { [i]: { children: pos } };
      } else {
        pos = { [i]: { $merge: { ...result } } };
      }
    });
    const newTreeData = update(treeData, pos);
    onChange(newTreeData);
  }

  // move node event
  moveNode = ({
    dragId, targetId, position, originalPath, targetPath,
  }) => {
    const { onChange, onMoveNode } = this.props;
    const dragNode = this.findNodeByPath(originalPath);
    const dropNode = this.findNodeByPath(targetPath);
    const newTreeData = this.getNewData({
      originalPath, targetPath, position, dragNode, dropNode,
    });
    onChange(newTreeData);
    // fetch server
    onMoveNode({ dragId, targetId, position });
  }

  // get changed treedata
  getNewData = ({
    originalPath, targetPath, position, dragNode, dropNode,
  }) => {
    const tempData = this.getRemoveData(originalPath);
    return this.getAddData({
      treeData: tempData,
      originalPath,
      targetPath,
      position,
      dragNode,
      dropNode,
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
    dropNode,
  }) => {
    const isMove = this.getIsMove(originalPath, targetPath);
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
        if (!dropNode.children) {
          pos = { [i]: { $merge: { children: [dragNode] } } };
        } else {
          pos = { [i]: { children: { $push: [dragNode] } } };
        }
      } else {
        pos = { $splice: [[i, 0, dragNode]] };
      }
    });
    return update(treeData, pos);
  }

  // when originalNode remove influence targetNode's path
  getIsMove = (path, targetPath) => {
    if (targetPath.length < path.length) return false;
    const flag = path.slice(0, -1).every((i, idx) => i === targetPath[idx]);
    return flag && targetPath[path.length - 1] > path[path.length - 1];
  }

  toggleExpaned = ({ path, expanded }) => {
    let pos = {};
    [...path].reverse().forEach((i, idx) => {
      if (idx > 0) {
        pos = { [i]: { children: pos } };
      } else {
        pos = { [i]: { $merge: { expanded: !expanded } } };
      }
    });
    const newTreeData = update(this.props.treeData, pos);
    this.props.onChange(newTreeData);
  }

  findNodeByPath = (path) => {
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

  // 是否折叠 true(折叠)， false(展开)
  getExpanded = ({ children, expanded }, parentPath) => {
    const { expandedDepth } = this.props;
    // 没有子项
    if (!children) return true;
    // 有折叠参数
    if (typeof expanded !== 'undefined') return expanded;
    return parentPath.length >= expandedDepth - 1;
  }

  renderTreeNode = (data = [], parentPath = []) => {
    const {
      repository, editMode, viewMode, currentDocId, t,
    } = this.props;
    return data.map((node, index) => {
      const expanded = this.getExpanded(node, parentPath);
      return (
        <>
          <TreeNode
            key={node.id}
            info={{ expanded, ...node }}
            repository={repository}
            path={[...parentPath, index]}
            moveNode={this.moveNode}
            editMode={editMode}
            viewMode={viewMode}
            active={node.docId === currentDocId}
            toggleExpaned={this.toggleExpaned}
            onDeleteNode={this.delNode}
            onUpdateNode={this.updateNode}
            t={t}
          />
          {!expanded && this.renderTreeNode(node.children, [...parentPath, index])}
        </>);
    });
  }

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
