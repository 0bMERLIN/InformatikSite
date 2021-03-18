let initPreserveScroll = contID => {
  let el = document.getElementById(contID)

  let oldOnscroll = el.onscroll
  
  el.onscroll = e => {
    oldOnscroll()
    localStorage.setItem('scrollpos', el.scrollTop)
  }
  
  document.addEventListener("DOMContentLoaded", e => {
    let scrollpos = localStorage.getItem('scrollpos')
    if (scrollpos) el.scrollTo(0, scrollpos)
  } )
}