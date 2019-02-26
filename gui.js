var hasEnteredSimulation = false;
var hasEnteredSettings = false;

const animationDurationSpeed = 0.1;

enterSimulation();
enterSettings();

var mainMenuULElement = document.getElementById("mainMenuUL");
var logoImageElement = document.getElementById("logoImageID");

function enterSimulation(){
    var canvasElement = document.getElementById("glCanvas");
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

function enterSettings(){
    var enterSettingsElement = document.getElementById("entSetID");
    var mainMenuPageElement = document.getElementById("mainMenuPage");
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