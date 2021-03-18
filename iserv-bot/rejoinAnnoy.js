let getElemByClassAndLabel = (cl, lab) => Array
  .from(document.getElementsByClassName(cl))
  .filter(el => el.innerHTML.indexOf(lab) != -1)[0]

let btnsClass = "lg--Q7ufB"
let chooseAudioOptBtnClass = "jumbo--Z12Rgj4"
let btnLeaveLab = "Audio beenden"
let btnJoinLab = "Audio starten"
let chooseAudioOptBtnLab = "zuhören"

let nullFmap = (potDOM_Elem, f) => {
  if (potDOM_Elem !== undefined && potDOM_Elem !== null)
    return f(potDOM_Elem)
  else
    return potDOM_Elem
}

let safeClick = e => nullFmap(e, x => x.click())

let leave = () =>
  safeClick(getElemByClassAndLabel(btnsClass, btnLeaveLab))

let join = cb => {
  safeClick(getElemByClassAndLabel(btnsClass, btnJoinLab))

  setTimeout(() => {
    
      safeClick(getElemByClassAndLabel(chooseAudioOptBtnClass
        , chooseAudioOptBtnLab))
      return cb()

    }, 100)
}

let annoy = (n, cb) => {
  if (n <= 0)
    return cb()
  else {
    leave()
    setTimeout(
        () => join(
          () => setTimeout(
            () => annoy(n - 1, cb)
          , 10)
        )
      , 500
    )
  }
}

annoy(10, () => console.log("done"))