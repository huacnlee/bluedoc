import React, { Component } from 'react';
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import update from 'immutability-helper';
import TreeNode from './node';


class Tree extends Component {
  moveNode = ({
    dragId, targetId, position, originalPath, targetPath,
  }) => {
    const { treeData, onChange } = this.props;
    const { node, index } = this.findNode(dragId);
    const newTreeData = update(treeData, {
      $splice: [[originalPath, 1], [targetPath, 0, node]],
    });
    console.log('move', newTreeData);
    onChange(newTreeData);
  }

  findNode = (id) => {
    const { treeData } = this.props;
    const node = treeData.filter(i => i.id === id)[0];
    return {
      node,
      index: treeData.indexOf(node),
    };
  }

  render() {
    const { treeData = [] } = this.props;
    return (
      <div style={{ height: 400 }}>
        {
          treeData.map((node, index) => (
            <TreeNode
              key={node.id}
              info={node}
              path={index}
              moveNode={this.moveNode}
            />
          ))
        }
      </div>
    );
  }
}

export default DragDropContext(HTML5Backend)(Tree);
