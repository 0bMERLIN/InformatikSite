let darkStyle = `
  --text-color: #9fa1b3;
  
  --color-secondary: #0e1525;
  --color-secondary-darker: #171d2d;
  --color-secondary-hover: #131c2f;
  --color-secondary-hover-light: #131928;
  
  --color-primary: #171d2d;
  --color-background: #0e1525;

  --code-editor-color: #131928;
  --editor-elem-border-color: #1d2333;
  
  --widget-red: #e44634;
  --widget-dark-red: #cb312a;
  --widget-green: #21b064;
  --widget-blue: #3485e4;

  --selection-color: #3485e4;
  --selection-text-color: #171d2d;
`

let lightStyle = `
  --text-color: #9fa1b3;
  
  --color-secondary: #F5F5F5;
  --color-secondary-darker: #F5F5F5;
  --color-secondary-hover: #e0e0e0;
  --color-secondary-hover-light: #ffffff;
  
  --color-primary: #ececec;
  --color-background: #f9fcfb;

	--code-editor-color: #f9fcfb;
  --editor-elem-border-color: #ffffff;
  --widget-red: #e44c41;

  --widget-dark-red: #db5349;
  --widget-green: #59f1a8;
  --widget-blue: #6a53fd;

  --selection-color: #fdde53b6;
  --selection-text-color: none;
`

let blueStyle = `
  --text-color: #9fa1b3;

  --color-secondary: #32465a;
  --color-secondary-darker: #344b618a;
  --color-secondary-hover: #2c3e50;
  --color-secondary-hover-light: #304457;
  
  --color-primary: #2c3e50;
  --color-background: #304357;
  
	--code-editor-color: #314558;
  --editor-elem-border-color: #4e6377;

  --widget-red: #e74c3c;
  --widget-dark-red: #a8382b;
  --widget-green: #3ce77b;
  --widget-blue: #a29ae0;

  --selection-color: #fdde534b;
  --selection-text-color: none;
`

let formatStyle = s =>
  s.replace(/\n/g, "")
  .split(";")
  .map( vdefS => vdefS.split(":") )
  .map( vdef => vdef.map(d => d.replace(/[ \t]*/g, "")) )

let brightessModes =
  [ {key: "brightness-dark", val: darkStyle}
  , {key: "brightness-light", val: lightStyle}
  , {key: "brightness-blue", val: blueStyle} ]

let setStyleVar = (name, val) =>
  document
  .documentElement
  .style
  .setProperty(name, val);

let brightessModeLookup = k =>
  brightessModes.filter( b => b.key === k )[0]

let getBrightnessMode = () =>
  brightessModes
  .map( b => document.getElementsByClassName(b.key)[0] )
  .filter( b => b != undefined )[0].classList.item(2)

let getBrightnessVars = () =>
  formatStyle(brightessModeLookup(getBrightnessMode()).val)

let forceRedraw = element => {
  if (!element)
    return;

  var n = document.createTextNode(' ')
  var disp = element.style.display

  element.appendChild(n)
  element.style.display = 'none'

  setTimeout(function(){
      element.style.display = disp
      n.parentNode.removeChild(n)
  }, 20)
}

let updateStyleVars = () => {
  console.log("btn", Date.now().toString())
  setTimeout( () => {
    forceRedraw()
    getBrightnessVars().map(vdef => {
      
      setStyleVar(vdef[0], vdef[1])
    })
  }, 10)
}