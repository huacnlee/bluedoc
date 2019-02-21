import graphql from 'graphql.js'

export const graph = graphql("/graphql", {
  method: "POST",
  alwaysAutodeclare: true,
  headers: {
    // Add CSRF Header, get it from <meta name="csrf-token" />
    "X-CSRF-Token": document.getElementsByName('csrf-token')[0].content
  }
})

export const searchUsers = graph(`
  query(@autodeclare) {
    search(type: "user", query: $query) {
      total,
      records {
        ... on User {
          id, name, slug, avatarUrl
        }
      }
    }
  }
`);
