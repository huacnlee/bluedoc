// find visible cur node's sort index
export const getCurNode = (curIndex, items) => items.find(v => v.index === curIndex);

// find visible prev node's sort index
export const getPrevNodeIndex = (curIndex, items) => {
  if (curIndex === -1) return -1;
  const tempIdx = items.findIndex(v => v.index === curIndex) - 1;
  const { index = -1 } = items[tempIdx] || {};
  return index;
};

// find visible next node's sort index
export const getNextNodeIndex = (curIndex, items) => {
  if (curIndex === -1) return -1;
  const tempIdx = items.findIndex(v => v.index === curIndex) + 1;
  const { index = -1 } = items[tempIdx] || {};
  return index;
};

// get folderList length
export const getFolderLength = (curIndex, items) => {
  const curEle = items[curIndex];
  const otherArr = items.slice(curIndex + 1);
  const idx = otherArr.findIndex(v => v.depth <= curEle.depth);
  return idx === -1 ? otherArr.length : idx;
};

// Determine if the current focus is on the input box
export const isFocusInput = () => {
  const inputs = ['input', 'select', 'button', 'textarea'];
  const { activeElement } = document;
  if (activeElement && inputs.indexOf(activeElement.tagName.toLowerCase()) !== -1) {
    return true;
  }
  return false;
};

export const getIndexSameDepth = (curIndex, items, direction = 1) => {
  if (curIndex === -1) return -1;
  const tempIdx = items.findIndex(v => v.index === curIndex);
  const curDepth = items.find(v => v.index === curIndex).depth;
  const Arr = direction === -1 ? items.slice(0, tempIdx).reverse() : items.slice(curIndex + 1);
  const len = Arr.length;
  let result = -1;
  for (let i = 0; i < len; i += 1) {
    const { depth, index } = Arr[i];
    if (curDepth > depth) {
      break;
    } else if (curDepth === depth) {
      result = index;
      break;
    }
  }
  return result;
};

export const getNextIndexSameDepth = (curIndex, items) => {
  if (curIndex === -1) return -1;
};
