import Draft from 'draft-js/lib/Draft';

const Immutable = require('immutable');

const customBlockRenderMap = Immutable.Map({
  unstyled: {
    element: 'p',
  },
  'code-block': {
    element: 'pre',
  },
});

export const blockRenderMap = Draft.DefaultDraftBlockRenderMap.merge(customBlockRenderMap);
