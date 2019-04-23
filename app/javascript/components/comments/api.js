import { graph } from 'bluedoc/graphql';

const userBodyQuery = "id, slug, name, avatarUrl, url"
const commentBodyQuery = `id, bodyHtml, user { ${userBodyQuery} }, parentId, replyTo { id, bodyHtml, user { ${userBodyQuery} } }, createdAt, updatedAt`

export const createComment = graph(`
  mutation(@autodeclare) {
    createComment(commentableType: $commentableType, commentableId: $commentableId, body: $body, bodySml: $bodySml) {
      ${commentBodyQuery}
    }
  }
`);

export const createCommentWithParent = graph(`
  mutation(@autodeclare) {
    createComment(commentableType: $commentableType, commentableId: $commentableId, body: $body, bodySml: $bodySml, parentId: $parentId) {
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
  query (@autodeclare) {
    comments(commentableType: $commentableType, commentableId: $commentableId, per: 50, page: $page) {
      records {
        ${commentBodyQuery}
      },
      pageInfo { per, page, totalCount, totalPages, firstPage, lastPage, nextPage, prevPage }
    }
  }
`);
