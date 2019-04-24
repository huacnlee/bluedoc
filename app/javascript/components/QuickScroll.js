// eslint-disable-next-line import/no-extraneous-dependencies
import React, { PureComponent } from 'react';
import animateScrollTo from 'animated-scroll-to';

export default class QuickScroll extends PureComponent {
  // quick scroll to page top
  handleScrollTop = () => {
    if (document.fullscreenElement) {
      animateScrollTo(0, {
        element: document.body,
      });
    } else {
      animateScrollTo(0);
    }
  }

  // quick scroll to comment position
  handleScrollComment = () => {
    const commentEle = document.querySelector('div[data-react-class="comments/Index"]');
    if (!commentEle) return;
    if (document.fullscreenElement) {
      animateScrollTo(commentEle, {
        element: document.body,
      });
    } else {
      animateScrollTo(commentEle);
    }
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
