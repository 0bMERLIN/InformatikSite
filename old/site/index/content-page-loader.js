loadContentPage = (contentID, path, iframeID) => {

  let page = document.getElementById(contentID)

  if (page !== null || page !== undefined)
    page.innerHTML = `<iframe src="${path}" class="content-page-iframe" id="${iframeID}"></iframe>`
  else
    console.log('could not find the content page "' + contentID + '"')
}