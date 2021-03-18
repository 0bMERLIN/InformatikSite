let delay = 100

let mute = itemID => document.getElementById(itemID).click()

let muteN = (itemID, i, m) => {
  console.log(i)
  
  if (i < m) {
    mute(itemID)
    setTimeout(() => muteN(itemID, i + 1, m), delay)
  }
  
  else
    console.log('done')
}

let annoyMute = (itemID, n) => muteN(itemID, 0, n * 2)

annoyMute("tippy-112", 1)