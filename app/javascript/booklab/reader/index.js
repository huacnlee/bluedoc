import BodyToc from "./body_toc";
import mediumZoom from "medium-zoom";

document.addEventListener("turbolinks:load", () => {
  if ($(".doc-page").length == 0) {
    return;
  }

  // print
  $(".reader-body").on("click", ".btn-print-doc", (e) => {
    e.preventDefault();
    window.print();
  });
  // wide mode
  $(".reader-body").on("click", ".btn-wide-mode", (e) => {
    e.preventDefault();
    GoInFullscreen($(".reader-body")[0]);
  });

  // wide mode
  $(".reader-body").on("click", ".btn-wide-mode-exit", (e) => {
    e.preventDefault();
    GoOutFullscreen();
  });

  // zoom markdown-body img
  mediumZoom('.markdown-body img');

  BodyToc.init();
});


function GoInFullscreen(element) {
	if(element.requestFullscreen)
		element.requestFullscreen();
	else if(element.mozRequestFullScreen)
		element.mozRequestFullScreen();
	else if(element.webkitRequestFullscreen)
		element.webkitRequestFullscreen();
	else if(element.msRequestFullscreen)
		element.msRequestFullscreen();
}

function GoOutFullscreen() {
	if(document.exitFullscreen)
		document.exitFullscreen();
	else if(document.mozCancelFullScreen)
		document.mozCancelFullScreen();
	else if(document.webkitExitFullscreen)
		document.webkitExitFullscreen();
	else if(document.msExitFullscreen)
		document.msExitFullscreen();
}