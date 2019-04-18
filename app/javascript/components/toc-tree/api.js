import { graph } from 'bluedoc/graphql';

// fetch toc list
export const getTocList = graph(`
  query (@autodeclare) {
    repositoryTocs(repositoryId: $repositoryId) {
      id,
      docId,
      title,
      url,
      parentId,
      depth
    }
  }
`);

// move toc and sort
export const moveTocList = graph(`
  mutation (@autodeclare) {
    moveToc(id: $id, targetId: $targetId, position: $position )
  }
`);

// delete toc node
export const deleteToc = graph(`
  mutation (@autodeclare) {
    deleteToc(id: $id)
  }
`);

// update toc info {title , url}
export const updateToc = graph(`
  mutation (
    $id: ID!,
    $title: String!,
    $url: String,
  ) {
    updateToc(id: $id, title: $title, url: $url)
  }
`);

// create toc
export const createToc = graph(`
  mutation (
    $repositoryId: ID!,
    $title: String!,
    $url: String,
    $external: Boolean,
    $targetId: ID,
    $position: String
  ) {
    createToc(
      repositoryId: $repositoryId,
      title: $title,
      url: $url,
      external: $external,
      targetId: $targetId,
      position: $position
    ) {
      id,
      title,
      url,
    }
  }
`);

export const Fetch = ({
  api,
  params,
  onSuccess,
  onError = handleError,
}) => {
  if (!api) return;
  api(params)
    .then((result) => {
      if (result.error) {
        onError(result);
      } else {
        onSuccess(result);
      }
    }).catch((result) => {
      console.log('error', result);
      handleError(result);
    });
};


export const handleSuccess = (result) => {
  console.log('success', result);
};

export const handleError = (result) => {
  result.error.message && window.App.notice(result.error.message, 'error');
};
