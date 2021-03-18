let manageFade = fadeClass => {

  let elements = document.getElementsByClassName(fadeClass)

  let elementsArr = [...elements]

  elementsArr.map( elem => {

    elem.addEventListener( 'animationiteration', e => {
      elem.classList.remove('animated')
      console.log("anim")
    } )

    elem.addEventListener( 'click', e => {
      elem.classList.add('animated')
      console.log("click")
    } )
  } )
}