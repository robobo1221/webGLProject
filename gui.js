var hasEnteredSimulation = false;
var hasEnteredSettings = false;

enterSimulation();
enterSettings();

function enterSimulation(){
    var canvasElement = document.getElementById("glCanvas");
    var reslistElement = document.getElementById("reslist");
    var menuWrapperElement = document.getElementById("menuWrapper");
    var mainMenuULElement = document.getElementById("mainMenuUL");
    var logoImageElement = document.getElementById("logoImageID");
    
    var enterSimulationElement = document.getElementById("entSimID");
    enterSimulationElement.addEventListener("click", doEnterSimulation);
    
    function doEnterSimulation() {
        canvasElement.style.filter = "blur(0px)";
        reslistElement.style.display = "block";
        menuWrapperElement.style.display = "none";

        hasEnteredSimulation = true;
    }

    if (keyboardInput.keyEsc && hasEnteredSimulation) {
        canvasElement.style.filter = "blur(10px)";
        reslistElement.style.display = "none";
        menuWrapperElement.style.display = "block";
        mainMenuULElement.style.animationDuration = "0.1s";
        logoImageElement.style.animationDuration = "0.1s";

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
    }

    requestAnimationFrame(enterSettings);
}