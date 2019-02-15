// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import PropTypes from 'prop-types';

class Search extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      focused: false,
      dropdownHovered: false,
    };
  }

  onChange = (e) => {
    this.setState({ value: e.currentTarget.value });
  }

  onFocus = (e) => {
    this.setState({ focused: true });
  }

  onBlur = (e) => {
    if (!this.state.dropdownHovered) {
      this.setState({ focused: false });
    }
  }

  onHoverDropdown = (e) => {
    this.setState({ dropdownHovered: true });
  }

  onHoverOutDropdown = (e) => {
    this.setState({ dropdownHovered: false });
  }

  render() {
    const { action = '/search', scope } = this.props;
    const { value, focused } = this.state;
    const escapedValue = encodeURIComponent(value);
    const placeholder = scope ? `Search in ${scope}` : 'Search BlueDoc';
    return (
      <form action={action || '/search'} className="subnav-search-context" method="GET">
        <div className="subnav-search">
          <auto-complete>
            <input
              name="q"
              type="text"
              placeholder={placeholder}
              autocomplete="off"
              onChange={this.onChange}
              onFocus={this.onFocus}
              onBlur={this.onBlur}
              className="form-control form-search-control subnav-search-input"
              defaultValue={value}
            />
            <i className="fas fa-search subnav-search-icon"></i>

            {focused && value && (
            <ul className="autocomplete-results"
              onMouseOver={this.onHoverDropdown}
              onMouseOut={this.onHoverOutDropdown}>
              {scope && (
              <li className="autocomplete-item">
                <a href={`${action}?q=${escapedValue}`}>
                  {value}
                  <span className="scope-name float-right">In {scope}</span>
                </a>
              </li>
              )}
              <li className="autocomplete-item">
                <a href={`/search?q=${escapedValue}`}>
                  {value}
                  <span className="scope-name float-right">All on BlueDoc</span>
                </a>
              </li>
            </ul>
            )}
          </auto-complete>
        </div>
      </form>
    );
  }
}

Search.propTypes = {
  placeholder: PropTypes.string,
};
export default Search;
