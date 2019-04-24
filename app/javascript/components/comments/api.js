import { graph } from 'bluedoc/graphql';

const userBodyQuery = 'id, slug, name, avatarUrl, url';
const commentBodyQuery = `id, bodyHtml, user { ${userBodyQuery} }, parentId, reactions { name, url, groupUserSlugs, groupCount }, replyTo { id, bodyHtml, user { ${userBodyQuery} } }, createdAt, updatedAt`;

export const createComment = graph(`
  mutation($commentableType: String!, $commentableId: ID!, $body: String!, $bodySml: String!, $nid: String!) {
    createComment(commentableType: $commentableType, commentableId: $commentableId, body: $body, bodySml: $bodySml, nid: $nid) {
      ${commentBodyQuery}
    }
  }
`);

export const createCommentWithParent = graph(`
  mutation($commentableType: String!, $commentableId: ID!, $body: String!, $bodySml: String!, $nid: String!, $parentId: ID!) {
    createComment(commentableType: $commentableType, commentableId: $commentableId, body: $body, bodySml: $bodySml, nid: $nid, parentId: $parentId) {
      ${commentBodyQuery}
    }
  }
`);

export const deleteComment = graph(`
  mutation(@autodeclare) {
    deleteComment(id: $id)
  }
`);

export const watchComments = graph(`
  mutation(@autodeclare) {
    watchComments(commentableType: $commentableType, commentableId: $commentableId, option: $option)
  }
`);


export const getComments = graph(`
  query ($commentableType: String!, $commentableId: ID!, $page: Int!, $nid: String!) {
    comments(commentableType: $commentableType, commentableId: $commentableId, nid: $nid, per: 50, page: $page) {
      records {
        ${commentBodyQuery}
      },
      pageInfo { per, page, totalCount, totalPages, firstPage, lastPage, nextPage, prevPage }
    }
  }
`);
