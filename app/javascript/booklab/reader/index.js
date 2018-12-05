import BodyToc from "./body_toc";

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
    // GoInFullscreen($(".reader-body")[0]);
    $(".reader-body").addClass("reader-wide-mode");
  });


  // wide mode
  $(".reader-body").on("click", ".btn-wide-mode-exit", (e) => {
    e.preventDefault();
    $(".reader-body").removeClass("reader-wide-mode");
    // GoOutFullscreen();
  });

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