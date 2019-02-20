
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
};

function onKeyDown(event) {
    var keyCode = event.keyCode;
    switch (keyCode) {
        case 68: //d
            keyboardInput.keyD = true;
            break;
        case 83: //s
            keyboardInput.keyS = true;
            break;
        case 65: //a
            keyboardInput.keyA = true;
            break;
        case 87: //w
            keyboardInput.keyW = true;
            break;
        case 32: //Space
            keyboardInput.keySpace = true;
            break;
        case 16: //Shift
            keyboardInput.keyShift = true;
            break;
        case 67: //C
            keyboardInput.keyC = true;
            break;
    }
}
  
function onKeyUp(event) {
var keyCode = event.keyCode;

switch (keyCode) {
    case 68: //d
        keyboardInput.keyD = false;
        break;
    case 83: //s
        keyboardInput.keyS = false;
        break;
    case 65: //a
        keyboardInput.keyA = false;
        break;
    case 87: //w
        keyboardInput.keyW = false;
        break;
    case 32: //Space
        keyboardInput.keySpace = false;
        break;
    case 16: //Shift
        keyboardInput.keyShift = false;
        break;
    case 67: //C
        keyboardInput.keyC = false;
        break;
    }
}