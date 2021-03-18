let removePopus = () => {

  let boxes =
    Array.from(document.querySelectorAll('[role="alert"]')).map(el => el.parentElement)  
  boxes.map(el => Array.from(el.children).filter(e => e.tagName === "I"))[0][0].click()
}