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

export { getTreeFromFlatData };
