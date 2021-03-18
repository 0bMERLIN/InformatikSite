let hideElem = (name, el) => {
  el.classList.add("hide-on-mobile")

  localStorage.setItem("mobile-hidden-elem", name)
}

let showElem = (name, el) => {
  el.classList.remove("hide-on-mobile")

  localStorage.setItem("mobile-shown-elem", name)
}

let showEditor = () => showElem("editor", document.getElementById("editor-container"))
let showTut = () => showElem("tut", document.getElementById("tut-container"))

let hideEditor = () => hideElem("editor", document.getElementById("editor-container"))
let hideTut = () => hideElem("tut", document.getElementById("tut-container"))

let initMobilePageMngr = () => {
  let shownPg  = localStorage.getItem("mobile-shown-elem")
  let hiddenPg = localStorage.getItem("mobile-hidden-elem")

  if (shownPg === "editor") {
    showEditor()
    hideTut()
  }
  else if (hiddenPg === "editor") {
    hideEditor()
    showTut()
  }
}