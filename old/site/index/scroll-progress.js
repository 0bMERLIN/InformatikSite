let initScrollBar = (scrollElem, scrollBar) => {

  console.log(scrollElem, scrollBar)

  scrollElem.addEventListener( "wheel", e => {

    let winScroll = document.body.scrollTop || document.documentElement.scrollTop
    let height    = document.documentElement.scrollHeight - document.documentElement.clientHeight
    let scrolled  = (winScroll / height) * 100

    scrollBar.style.width = scrolled + "%"

  } )

}