let uNameClass = "userName--6aS3s"
let statSetClass = "item--yl1AH"

let thumbsUp = (d, cb) => setStatsUp(d, "Daumen hoch", cb)
let clap = (d, cb) => setStatsUp(d, "Applaus", cb)

let nullFmap = (potDOM_Elem, f) => {
  if (potDOM_Elem !== undefined && potDOM_Elem !== null)
    return f(potDOM_Elem)
  else
    return potDOM_Elem
}

let safeClick = e => nullFmap(e, x => x.click())

let getElemByClassAndLabel = (cl, lab) => Array
    .from(document.getElementsByClassName(cl))
    .filter(el => el.innerHTML.indexOf(lab) != -1)[0]

let setStatsUp = (d, statName, cb) => {
  // click the profile, user is always on top
  safeClick(document.getElementsByClassName(uNameClass)[0])

  setTimeout(_ => {
    // click the status setter button
    safeClick(getElemByClassAndLabel(statSetClass, "Status setzen"))
    
    setTimeout(_ => {
      safeClick(getElemByClassAndLabel(statSetClass, statName))
      cb()
    }, d)
  }, d)
}

let removeState = (d, cb) => {
  removePopups()

  safeClick(document.getElementsByClassName(uNameClass)[0])
  
  setTimeout(_ => {
    safeClick(getElemByClassAndLabel(statSetClass, "Status zurücksetzen"))
    cb()
  }, d)
}

let removePopups = () => {

  let boxes =
    Array.from(document.querySelectorAll('[role="alert"]')).map(el => el.parentElement)  
  boxes.map(el => Array.from(el.children).filter(e => e.tagName === "I"))
  .map(x => x[0].click())

  console.clear()
}

let annoy = (statSetter, d, n, cb) => {
  if (n <= 0) {
    setTimeout(() => removeState(300, cb), 100)
  }
  else
    statSetter
      ( d
      , () => removeState(d, () => annoy(statSetter, d, n - 1, cb))
      )
}

let annoyNoPopup = (statSetter, d, n) =>
  annoy(statSetter, d, n, removePopups)

annoyNoPopup(clap, 10, 10)