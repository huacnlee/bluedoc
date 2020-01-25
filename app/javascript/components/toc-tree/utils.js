import { findDOMNode } from 'react-dom';

const expandedActiveNode = ({ flatData, active }) => {
  if (!active || !flatData) return [];
  const activeNode = flatData.find(node => node.docId === active);
  if (!activeNode || !active) return flatData;
  const newflatData = setNodeExpanded({ flatData, id: activeNode.id });
  return newflatData;
};

function setNodeExpanded({ id, flatData }) {
  const tempArr = [...flatData];
  const nodeIndex = flatData.findIndex(node => node.id === id);
  tempArr[nodeIndex] = { ...tempArr[nodeIndex], expanded: true };
  // console.log('----- expanded', id);
  const { parentId = null } = flatData[nodeIndex];
  if (parentId !== null) {
    // console.log('----- parent', parentId);
    return setNodeExpanded({ id: parentId, flatData: tempArr });
  }
  return tempArr;
}

export const getTreeFromFlatData = ({
  flatData,
  getKey = node => node.id,
  getParentKey = node => node.parentId,
  rootKey = '0',
  active,
}) => {
  if (!flatData) {
    return [];
  }

  const childrenToParents = {};
  let tempFlatData = flatData;
  if (active) {
    tempFlatData = expandedActiveNode({ flatData, active });
  }
  tempFlatData.forEach((child) => {
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

export function getFlatDataFromTree({ treeData, getNodeKey, ignoreCollapsed = true }) {
  if (!treeData || treeData.length < 1) {
    return [];
  }

  const flattened = [];
  walk({
    treeData,
    getNodeKey,
    ignoreCollapsed,
    callback: (nodeInfo) => {
      flattened.push(nodeInfo);
    },
  });

  return flattened;
}

/**
 * Walk descendants depth-first and call a callback on each
 *
 * @param {!Object[]} treeData - Tree data
 * @param {!function} getNodeKey - Function to get the key from the nodeData and tree index
 * @param {function} callback - Function to call on each node
 * @param {boolean=} ignoreCollapsed - Ignore children of nodes without `expanded` set to `true`
 *
 * @return void
 */
export function walk({
  treeData, getNodeKey, callback, ignoreCollapsed = true,
}) {
  if (!treeData || treeData.length < 1) {
    return;
  }

  walkDescendants({
    callback,
    getNodeKey,
    ignoreCollapsed,
    isPseudoRoot: true,
    node: { children: treeData },
    currentIndex: -1,
    path: [],
    lowerSiblingCounts: [],
  });
}

/**
 * Walk all descendants of the given node, depth-first
 *
 * @param {Object} args - Function parameters
 * @param {function} args.callback - Function to call on each node
 * @param {function} args.getNodeKey - Function to get the key from the nodeData and tree index
 * @param {boolean} args.ignoreCollapsed - Ignore children of nodes without `expanded` set to `true`
 * @param {boolean=} args.isPseudoRoot - If true, this node has no real data, and only serves
 *                                        as the parent of all the nodes in the tree
 * @param {Object} args.node - A tree node
 * @param {Object=} args.parentNode - The parent node of `node`
 * @param {number} args.currentIndex - The treeIndex of `node`
 * @param {number[]|string[]} args.path - Array of keys leading up to node to be changed
 * @param {number[]} args.lowerSiblingCounts - An array containing the count of siblings beneath the
 *                                             previous nodes in this path
 *
 * @return {number|false} nextIndex - Index of the next sibling of `node`,
 *                                    or false if the walk should be terminated
 */
function walkDescendants({
  callback,
  getNodeKey,
  ignoreCollapsed,
  isPseudoRoot = false,
  node,
  parentNode = null,
  currentIndex,
  path = [],
  lowerSiblingCounts = [],
}) {
  // The pseudo-root is not considered in the path
  const selfPath = isPseudoRoot ? [] : [...path, getNodeKey({ node, treeIndex: currentIndex })];
  const selfInfo = isPseudoRoot
    ? null
    : {
      node,
      parentNode,
      path: selfPath,
      lowerSiblingCounts,
      treeIndex: currentIndex,
    };

  if (!isPseudoRoot) {
    const callbackResult = callback(selfInfo);

    // Cut walk short if the callback returned false
    if (callbackResult === false) {
      return false;
    }
  }

  // Return self on nodes with no children or hidden children
  if (!node.children || (node.expanded !== true && ignoreCollapsed && !isPseudoRoot)) {
    return currentIndex;
  }

  // Get all descendants
  let childIndex = currentIndex;
  const childCount = node.children.length;
  if (typeof node.children !== 'function') {
    for (let i = 0; i < childCount; i += 1) {
      childIndex = walkDescendants({
        callback,
        getNodeKey,
        ignoreCollapsed,
        node: node.children[i],
        parentNode: isPseudoRoot ? null : node,
        currentIndex: childIndex + 1,
        lowerSiblingCounts: [...lowerSiblingCounts, childCount - i - 1],
        path: selfPath,
      });

      // Cut walk short if the callback returned false
      if (childIndex === false) {
        return false;
      }
    }
  }

  return childIndex;
}

export const getTargetPosition = (dropTargetProps, monitor, component) => {
  if (!component) return '';
  const node = findDOMNode(component);
  if (!node) return '';
  const { dragId } = monitor.getItem();
  const { targetId } = dropTargetProps;
  if (dragId === targetId) return '';
  const { bottom, top } = node.getBoundingClientRect();
  const { y } = monitor.getClientOffset();
  let position = 'child';
  if (y - top < 10) {
    position = 'left';
  }
  if (bottom - y < 10) {
    position = 'right';
  }
  return position;
};

export const getNewUrl = (url) => {
  const pathArr = window.location.pathname.split('/');
  pathArr.splice(-1, 1, url);
  return `${window.location.origin}${pathArr.join('/')}`;
};

// get markdown file content
export const readAsText = blob => new Promise((resolve, reject) => {
  if (!window.FileReader) {
    reject(new Error('浏览器不支持'));
  }
  const reader = new FileReader();
  reader.onload = (evt) => {
    resolve(evt.target.result);
  };
  reader.onerror = reject;
  reader.readAsText(blob, 'utf-8');
});

export const getValidParams = (obj) => {
  const param = {};
  if (isObject(obj)) {
    for (const key in obj) {
      if (obj[key] !== null && obj[key] !== undefined && obj[key] !== '') {
        param[key] = obj[key];
      }
    }
  }
  return param;
};

const isObject = (value) => {
  const type = typeof value;
  return value != null && (type == 'object' || type == 'function');
};

export const getMarkdownTitle = (str) => {
  const index = str.indexOf('\n');
  const result = str.substr(0, index);

  if (result !== null) {
    return result[0].replace('# ', '');
  }
  return null;
};
