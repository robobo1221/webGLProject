
document.addEventListener('keydown', onKeyDown, false);
document.addEventListener('keyup', onKeyUp, false);

var keyboardInput = {
    keyQ: false,
    keyW: false,
    keyE: false, 
    keyR: false,
    keyT: false,
    keyY: false,
    keyU: false,
    keyI: false,
    keyO: false,
    keyP: false,
    keyA: false,
    keyS: false,
    keyD: false,
    keyF: false,
    keyG: false,
    keyH: false,
    keyJ: false,
    keyK: false,
    keyL: false,
    keyZ: false,
    keyX: false,
    keyC: false,
    keyV: false,
    keyB: false,
    keyN: false,
    keyM: false,
    keySpace: false, 
    keyCtrl: false,
    keyShift: false,
    keyEsc: false,
};

function doKeyStuff(keyCode, press){

    switch (keyCode) {
        case 68: //D
            keyboardInput.keyD = press;
            break;
        case 83: //S
            keyboardInput.keyS = press;
            break;
        case 65: //A
            keyboardInput.keyA = press;
            break;
        case 87: //W
            keyboardInput.keyW = press;
            break;
        case 67: //C
            keyboardInput.keyC = press;
            break;
        case 88: //X
            keyboardInput.keyX = press;
            break;
        case 73: //I
            keyboardInput.keyI = press;
            break;
        case 74: //J
            keyboardInput.keyI = press;
            break;
        case 75: //K
            keyboardInput.keyI = press;
            break;
        case 76: //L
            keyboardInput.keyI = press;
            break;

        case 32: //Space
            keyboardInput.keySpace = press;
            break;
        case 16: //Shift
            keyboardInput.keyShift = press;
            break;
        case 27: //Escape
            keyboardInput.keyEsc = press;
            break;
    }
}

function onKeyDown(event) {
    var keyCode = event.keyCode;

    doKeyStuff(keyCode, true);
}
  
function onKeyUp(event) {
    var keyCode = event.keyCode;

    doKeyStuff(keyCode, false);
}