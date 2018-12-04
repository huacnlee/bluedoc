import ClipboardJS from "clipboard"

document.addEventListener("turbolinks:load", () => {
  const clipboard = new ClipboardJS("clipboard-copy");
  clipboard.on("success", (e) => {
    console.log("copied", e.text);
  })
});