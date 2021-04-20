function sendToTabPress(s) {
  if (window.elmApp !== null && window.elmApp !== undefined)
    window.elmApp.ports.onTabPress.send(s)
}

function handleTabs(id) {
  
  document.getElementById(id).addEventListener('keydown', function(e) {
    if (e.key == 'Tab') {
      
      e.preventDefault()

      let indent = "  "
      let start = this.selectionStart
      let end = this.selectionEnd
      let cursorAtEndOfLine = this.value.substring(start, end + 1) === '\n'
      let newValue = this.value.substring(0, start) + indent + this.value.substring(end)
      
      if (cursorAtEndOfLine)
        {this.value = newValue
        this.selectionStart = this.selectionEnd = start + indent.length}
      else
       {sendToTabPress(newValue)
        setTimeout(_ => {
          this.selectionStart = this.selectionEnd = start + indent.length
        }, 10)}
    }
  })
}