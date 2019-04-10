import React, { Component } from 'react';
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import update from 'immutability-helper';
import TreeNode from './node';


class Tree extends Component {
  moveNode = (id, targetId, position = 'right') => {
    const { treeData, onChange } = this.props;
    const { node, index } = this.findNode(id);
    console.log(id, targetId);
    const newTreeData = update(treeData, {
      $splice: [[index, 1], [targetId, 0, node]],
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
    const { treeData = [{ id: 1, title: 'hahaha' }] } = this.props;
    return (
      <div style={{ height: 400 }}>
        {
          treeData.map(node => (
            <TreeNode
              key={node.id}
              info={node}
              id={node.id}
              moveNode={this.moveNode}
              findNode={this.findNode}
            />
          ))
        }
      </div>
    );
  }
}

export default DragDropContext(HTML5Backend)(Tree);
