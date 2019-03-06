var hasEnteredSimulation = false;
var hasEnteredSettings = false;
var hasEnteredCode = false;
var showFPS = true;

const animationDurationSpeed = 0.1;

enterSimulation();
enterSettings();
enterSourceCode();

var mainMenuULElement = document.getElementById("mainMenuUL");
var mainMenuPageElement = document.getElementById("mainMenuPage");
var logoImageElement = document.getElementById("logoImageID");
var canvasElement = document.getElementById("glCanvas");

function enterSimulation(){
    var menuWrapperElement = document.getElementById("menuWrapper");
    
    var enterSimulationElement = document.getElementById("entSimID");
    enterSimulationElement.addEventListener("click", doEnterSimulation);
    
    function doEnterSimulation() {
        canvasElement.style.filter = "blur(0px)";
        menuWrapperElement.style.display = "none";

        hasEnteredSimulation = true;
    }

    if (keyboardInput.keyEsc && hasEnteredSimulation) {
        canvasElement.style.filter = "blur(10px)";
        menuWrapperElement.style.display = "block";
        mainMenuULElement.style.animationDuration = animationDurationSpeed+"s";
        logoImageElement.style.animationDuration = animationDurationSpeed+"s";

        hasEnteredSimulation = false;
    }

    requestAnimationFrame(enterSimulation);
}

var resmult;

function enterSettings(){
    const renderQualityValue = document.getElementById("renderQualitySliderVal");
    
    resmult = renderQualitySlider.value;

    renderQualityValue.innerHTML = resmult;

    var enterSettingsElement = document.getElementById("entSetID");
    var settingsPageElement = document.getElementById("settingsPage");

    enterSettingsElement.addEventListener("click", doEnterSettings);

    function doEnterSettings() {
        settingsPageElement.style.display = "block";
        mainMenuPageElement.style.display = "none";
        settingsPageElement.style.animationDuration = animationDurationSpeed+"s";

        hasEnteredSettings = true;
    }

    if (keyboardInput.keyEsc && hasEnteredSettings){
        settingsPageElement.style.display = "none";
        mainMenuPageElement.style.display = "block";
        mainMenuULElement.style.animationDuration = animationDurationSpeed+"s";
        logoImageElement.style.animationDuration = animationDurationSpeed+"s";

        hasEnteredSettings = false;
    }

    requestAnimationFrame(enterSettings);
}

function enterSourceCode(){
    var enterSourceCodeElement = document.getElementById("entSourceID");
    var codeContainerElement = document.getElementById("codeContainer");

    enterSourceCodeElement.addEventListener("click", doEnterSourceCode);

    function doEnterSourceCode() {
        codeContainerElement.style.display = "block";
        mainMenuPageElement.style.display = "none";
        codeContainerElement.style.animationDuration = animationDurationSpeed+"s";

        hasEnteredCode = true;
    }

    if (keyboardInput.keyEsc && hasEnteredCode){
        codeContainerElement.style.display = "none";
        mainMenuPageElement.style.display = "block";
        mainMenuULElement.style.animationDuration = animationDurationSpeed+"s";
        logoImageElement.style.animationDuration = animationDurationSpeed+"s";

        hasEnteredCode = false;
        //rewritefsSource();
    }

    requestAnimationFrame(enterSourceCode);
}

function toggleFPSMeter(){
    var fpsCounterElement = document.getElementById("fpsCounter");
    var valueElement = document.getElementById("optShowFPSVal");

    if (showFPS == false) {
        showFPS = true;
        valueElement.innerHTML = "ON";
        fpsCounterElement.style.display = "block";
    } else {
        showFPS = false;
        valueElement.innerHTML = "OFF";
        fpsCounterElement.style.display = "none";
    }
}