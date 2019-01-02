import React from "react"
import PropTypes from "prop-types"

class Search extends React.Component {
  render () {
    let { action, scope, value } = this.props;

    const placeholder = scope ? `Search in ${scope}` : "Search BookLab";
    if (!action) {
      action = "/search"
    }

    return (
    <form action={action} className="subnav-search-context" method="GET">
      <div className="subnav-search">
        <input name="q" type="text" placeholder={placeholder} autocomplete="off" className="form-control form-search-control subnav-search-input" value={value} />
        <i className="fas fa-search subnav-search-icon"></i>
      </div>
    </form>
    );
  }
}

Search.propTypes = {
  placeholder: PropTypes.string
};
export default Search
