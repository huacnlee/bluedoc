import React from 'react';
import PropTypes from 'prop-types';

class Search extends React.Component {
  render() {
    const { action = '/search', scope, value } = this.props;
    const placeholder = scope ? `Search in ${scope}` : 'Search BookLab';

    return (
    <form action={action || '/search'} className="subnav-search-context" method="GET">
      <div className="subnav-search">
        <input name="q" type="text" placeholder={placeholder} autocomplete="off" className="form-control form-search-control subnav-search-input" defaultValue={value} />
        <i className="fas fa-search subnav-search-icon"></i>
      </div>
    </form>
    );
  }
}

Search.propTypes = {
  placeholder: PropTypes.string,
};
export default Search;
