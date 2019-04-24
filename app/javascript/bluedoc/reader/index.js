import InlineComments from 'components/inline_comments/index';
import { graph } from 'bluedoc/graphql';
import BodyToc from './body_toc';
import mediumZoom from './medium-zoom';


document.addEventListener('turbolinks:load', () => {
  if ($('.doc-page').length === 0) {
    return;
  }

  // print
  $('.reader-body').on('click', '.btn-print-doc', (e) => {
    e.preventDefault();
    window.print();
  });

  // wide mode
  $('.reader-body').on('click', '.btn-wide-mode', (e) => {
    e.preventDefault();
    GoInFullscreen($('.reader-body')[0]);
  });

  // wide mode
  $('.reader-body').on('click', '.btn-wide-mode-exit', (e) => {
    e.preventDefault();
    GoOutFullscreen();
  });

  // zoom markdown-body img
  mediumZoom($('.markdown-body img:not(.plantuml-image,.tex-image)'));


  initInlineComments();

  BodyToc.init();
});

export const getInlineComments = graph(`
  query (@autodeclare) {
    inlineComments(subjectType: $subjectType, subjectId: $subjectId) {
      id, nid, commentsCount
    }
  }
`);


const initInlineComments = () => {
  // inline comments
  const blocks = document.querySelectorAll('.reader-body .markdown-body > [nid]');
  const docId = document.querySelector('.reader-body .markdown-body').getAttribute('data-id');

  const existInlineComments = {};
  getInlineComments({ subjectType: 'Doc', subjectId: docId }).then((result) => {
    result.inlineComments.forEach((item) => {
      existInlineComments[item.nid] = item.commentsCount;
    });

    blocks.forEach((block) => {
      const nid = block.getAttribute('nid');
      const inlineCommentIcon = document.createElement('div');
      inlineCommentIcon.className = 'inline-comment-button';
      const link = document.createElement('a');
      let inlineCommentsCount = 0;
      if (existInlineComments[nid]) {
        inlineCommentsCount = existInlineComments[nid];
      }
      link.href = '#';
      link.setAttribute('nid', nid);
      link.setAttribute('class', 'inline-comment-button-icon');
      link.onclick = handleInlineCommentClick;

      let icon = '<div><i class="fas fa-comments"></i></div>';
      if (inlineCommentsCount > 0) {
        inlineCommentIcon.className += ' has-comments';
        icon += `<div class="mt-1">${inlineCommentsCount}</div>`;
      }

      link.innerHTML = icon;
      inlineCommentIcon.append(link);
      block.append(inlineCommentIcon);
    });
  }).catch((errors) => {
    App.alert(errors);
  });

  const popoverContainer = document.createElement('div');
  document.body.append(popoverContainer);

  const inlineCommentPanelRef = React.createRef();

  ReactDOM.render(<InlineComments commentableType="Doc" commentableId={docId} ref={inlineCommentPanelRef} />, popoverContainer);

  const handleInlineCommentClick = (e) => {
    e.preventDefault();

    const nid = e.currentTarget.getAttribute('nid');
    inlineCommentPanelRef.current.open({
      nid,
    });

    return false;
  };
};


function GoInFullscreen(element) {
  if (element.requestFullscreen) {
    element.requestFullscreen();
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen();
  } else if (element.webkitRequestFullscreen) {
    element.webkitRequestFullscreen();
  } else if (element.msRequestFullscreen) {
    element.msRequestFullscreen();
  }
}

function GoOutFullscreen() {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  } else if (document.webkitExitFullscreen) {
    document.webkitExitFullscreen();
  } else if (document.msExitFullscreen) {
    document.msExitFullscreen();
  }
}
