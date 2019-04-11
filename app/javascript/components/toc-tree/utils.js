import { findDOMNode } from 'react-dom';

const getTreeFromFlatData = ({
  flatData,
  getKey = node => node.id,
  getParentKey = node => node.parentId,
  rootKey = '0',
}) => {
  if (!flatData) {
    return [];
  }

  const childrenToParents = {};
  flatData.forEach((child) => {
    const parentKey = getParentKey(child);

    if (parentKey in childrenToParents) {
      childrenToParents[parentKey].push(child);
    } else {
      childrenToParents[parentKey] = [child];
    }
  });

  if (!(rootKey in childrenToParents)) {
    return [];
  }

  const trav = (parent) => {
    const parentKey = getKey(parent);
    if (parentKey in childrenToParents) {
      return {
        ...parent,
        children: childrenToParents[parentKey].map(child => trav(child)),
      };
    }

    return { ...parent };
  };

  return childrenToParents[rootKey].map(child => trav(child));
};

const getTargetPosition = (dropTargetProps, monitor, component) => {
  if (!component) return '';
  const node = findDOMNode(component);
  if (!node) return '';
  const { dragId } = monitor.getItem();
  const { targetId } = dropTargetProps;
  console.log(dropTargetProps, monitor.getItem());
  if (dragId === targetId) return '';
  const { bottom, top } = node.getBoundingClientRect();
  const { y } = monitor.getClientOffset();
  let position = 'child';
  if (y - top < 5) {
    position = 'left';
  }
  if (bottom - y < 5) {
    position = 'right';
  }
  return position;
};

export { getTreeFromFlatData, getTargetPosition };
