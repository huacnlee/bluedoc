// eslint-disable-next-line import/no-extraneous-dependencies
import React, { PureComponent } from 'react';

export default class QuickScroll extends PureComponent {
  // quick scroll to page top
  handleScrollTop = () => {
    window.scrollTo(0, 0);
  }

  // quick scroll to comment position
  handleScrollComment = () => {
    document.querySelector('#comment').scrollIntoView(false);
  }

  render() {
    return (
      <div className="quick-wrap">
        <div className="fas fa-down quick-btn quick-top" onClick={this.handleScrollTop}></div>
        <div className="fas fa-down quick-btn" onClick={this.handleScrollComment}></div>
      </div>
    );
  }
}
