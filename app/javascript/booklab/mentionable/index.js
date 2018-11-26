import "jquery.caret";
import "vendor/at.js";
const _ = require("lodash");

const MentionLineTpl = "<li data-value='${slug}'><img src='${avatar_url}' class='avatar avatar-tiny' height='20' width='20'/> ${slug} <small>${name}</small></li>";


export class Mentionable {
  constructor(selector) {
    this.selector = selector;
  }

  init() {
    const slugs = this.scanMentionableSlugs();
    const currentUserSlug = $("meta[name=current-user]").attr("value");
    console.log(currentUserSlug)
    $(this.selector).atwho({
      at: "@",
      limit: 8,
      searchKey: "slug",
      callbacks: {
        filter: (query, data, searchKey) => {
          return data;
        },
        sorter: (query, items, searchKey) => {
          return items;
        },
        remoteFilter: (query, callback) => {
          const r = new RegExp(`^${query}`);
          // fliter local slugs
          const localMatches = _.filter(slugs, (u) => {
            return r.test(u.slug) || r.test(u.name);
          });

          // Remote search
          $.getJSON('/autocomplete/users.json', { q: query }, (data) => {
            let users = data.users;
            localMatches.forEach((slug) => {
              users.unshift(slug);
            });

            // remove duplicate
            users = _.reject(users, (user) => {
              return user.slug == currentUserSlug;
            })
            users = _.uniqBy(users, 'slug');
            users = _.take(users, 8);
            return callback(users);
          });
        }
      },
      displayTpl: MentionLineTpl,
      insertTpl: "@${slug}"
    });
  }

  scanMentionableSlugs() {
    const result = [];
    const slugs = [];

    const $els = $(".user-avatar");
    for (let i = 0; i < $els.length; i++) {
      const el = $($els[i]);

      console.log(el)

      const item = {
        slug: el.attr("data-slug"),
        name: el.attr('data-name'),
        avatar_url: el.find(".avatar img").first().attr("src")
      }

      if (!item.slug) {
        continue;
      }
      if (!item.name) {
        continue;
      }
      if (slugs.indexOf(item.slug) !== -1) {
        continue;
      }
      slugs.push(item.slug);
      result.push(item);
    }

    return _.uniq(result);

  }
}

document.addEventListener("turbolinks:load", () => {
  const mentionable = new Mentionable("textarea.mentionable");
  mentionable.init();
});