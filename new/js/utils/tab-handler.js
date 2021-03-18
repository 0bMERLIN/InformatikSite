function handleTabs(id) {
  document.getElementById(id).addEventListener('keydown', function(e) {
    if (e.key == 'Tab') {
      e.preventDefault();
      let start = this.selectionStart;
      let end = this.selectionEnd;

      let indent = "  "

      this.value = this.value.substring(0, start) + indent + this.value.substring(end);

      // put caret at right position again
      this.selectionStart = this.selectionEnd = start + indent.length;
    }
  });
}