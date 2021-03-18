let initScrollIndicator = () => {
  
  document.getElementById("cards-container").onscroll = e => {

    let el = document.getElementById("cards-container")
    let scroll = el.scrollTop
    let height = el.scrollHeight - el.clientHeight
    let scrolled = (scroll / height) * 100
    document
    .getElementById("progress-container")
    .setAttribute("style", `width: ${scrolled}%`)
  }

  initPreserveScroll("cards-container")
}