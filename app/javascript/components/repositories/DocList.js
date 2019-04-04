import { DocItem, DocItemLoader } from "./DocItem";
import { Pagination } from "bluebox/pagination"
import { graph } from "bluedoc/graphql";

const getDocs = graph(`
  query (@autodeclare) {
    repositoryDocs(repositoryId: $repositoryId, sort: $sort, per: 10, page: $page) {
      records {
        id, title, slug, path, createdAt, updatedAt,
        lastEditor {
          id, name, slug, avatarUrl, path
        },
      },
      pageInfo { per, page, totalCount, totalPages, firstPage, lastPage, nextPage, prevPage }
    }
  }
`);

/**
 * Document manage list
 * /:user/:repo/docs/list
 */
export default class DocList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      docs: [],
      pageInfo: { },
      sort: "created",
      loading: true,
    }
  }

  componentDidMount = () => {
    this.fetch(1);
  }

  onPage = (page) => {
    this.fetch(page);
  }

  fetch(page) {
    const { repositoryId } = this.props;
    const { sort } = this.state;

    this.setState({ loading: true });

    getDocs({ repositoryId, page, sort }).then((result) => {
      const { records, pageInfo } = result.repositoryDocs
      this.setState({
        // Only return the first 5 results
        docs: records,
        pageInfo: pageInfo,
        loading: false,
      });
    }).catch((errors) => {
      App.alert(errors);
    });
  }

  onToolbarChange = ({ sort }) => {
    this.setState({
      sort,
    })

    this.fetch(1);
  }

  onItemDeleted = (id) => {
    let { docs } = this.state;

    docs = docs.filter(doc => doc.id != id);
    this.setState({ docs });
  }

  render() {
    const { } = this.props;

    const { docs, sort, loading, pageInfo } = this.state;

    if (!loading && docs.length == 0) {
      return <EmptyDoc {...this.props} t={this.t} />
    }

    return <div className="repository-docs">
      <Toolbar onChange={this.onToolbarChange} sort={sort} t={this.t} />
      <div className="doc-list">
        {loading && (
          <div>
            <DocItemLoader />
            <DocItemLoader />
            <DocItemLoader />
          </div>
        )}
        {!loading && (
          docs.map(doc => <DocItem doc={doc} {...this.props} t={this.t} onDelete={this.onItemDeleted} /> )
        )}
      </div>
      {docs.length > 0 &&
        <Pagination onPage={this.onPage} pageInfo={pageInfo} />
      }
    </div>
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`repositories.Docs${key}`);
    }
    return i18n.t(key);
  }
}

class Toolbar extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      sort: props.sort,
    }
  }

  onSort = (e) => {
    e.preventDefault();

    const { onChange } = this.props;
    const sort = e.target.getAttribute("sort")

    onChange({ sort });

    return false
  }

  render() {
    const { t, sort } = this.props;

    return <div className="subnav">
    <div className="float-right subnav-sorting">
      <span className="text-gray mr-2">{t(".Sort by")}</span>
      <a href="#" onClick={this.onSort} sort="recent" className={`btn-link ${sort == "recent" ? " selected" : ""}`}>{t(".Sort by updated")}</a>
      <span className="divider">/</span>
      <a href="#" onClick={this.onSort} sort="created" className={`btn-link ${sort == "created" ? " selected" : ""}`}>{t(".Sort by created")}</a>
    </div>
  </div>
  }
}

class EmptyDoc extends React.Component {
  render() {
    const { t, abilities, newDocURL } = this.props;
    return <div className="repository-docs" data-turbolinks="false">
      <div className="blankslate no-data no-doc text-center">
      <h3>{t(".There is no documents")}</h3>
      {abilities.update && (
        <div>
        <p>{t(".You can create first document")}</p>
        <p>
          <a href={newDocURL} className="btn btn-sm btn-primary">{t(".Create doc")}</a>
        </p>
        </div>
      )}
      </div>
    </div>
  }
}

