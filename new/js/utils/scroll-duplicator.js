// this makes it so two elements have the same scroll position
// (copies scroll positions from id2 to id1)
function dupScrollFromTo(id2, id1) {
  var el1 = document.getElementById(id1);

  var el2 = document.getElementById(id2)
  
  el2.addEventListener('scroll', function (e) {
    el1.scrollTop = el2.scrollTop;
    el1.scrollLeft = el2.scrollLeft;
  });
}