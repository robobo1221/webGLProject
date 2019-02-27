var vsSource = readFile('shaders/shader.vsh');
var fsSource = readFile('shaders/shader.fsh');

drawSourcecode(fsSource);

main();

function main() {
    const canvas = document.querySelector('#glcanvas');
    const gl = canvas.getContext('webgl2');


    if (!gl) {
        alert('Unable to initialize WebGL. Your browser or machine may not support it.');
        return;
    }

    var then = 0;
    var now = new Date();
    var delta = 0.1;

    var cameraPosition = new THREE.Vector3(0.0, 100000.0, 0.0);
    var mousePosition = new THREE.Vector2();

    const buffers = initBuffers(gl);

    function render(now){

        var shaderProgram = initShaderProgram(gl, vsSource, fsSource);

        var programInfo = {
            program: shaderProgram,
            attribLocations: {
                vertexPosition: gl.getAttribLocation(shaderProgram, 'vertPos'),
            },
    
            uniformLocations: {
                //projectionMatrix: gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'),
                //modelViewMatrix: gl.getUniformLocation(shaderProgram, 'uModelViewMatrix'),
                resLocation: gl.getUniformLocation(shaderProgram, 'viewResolution'),
                frameTimeCountLocation: gl.getUniformLocation(shaderProgram, 'time'),
                sunVecLocation: gl.getUniformLocation(shaderProgram, 'sunVector'),
                camPosLocation: gl.getUniformLocation(shaderProgram, 'cameraPosition'),
                mousePosLocation: gl.getUniformLocation(shaderProgram, 'mousePosition'),
            },
        };

        now *= 0.001;
        var sTime = now;
        var fTime = (sTime - Math.floor(sTime));
        
        if (fTime > 0.0 && fTime < 0.0 + delta)
        delta = now - then;

        then = now;

        var fps = 1.0 / delta;
        document.getElementById("fpsCounter").innerHTML = Math.floor(fps);

        moveCamera(cameraPosition);

        runProgram(gl, programInfo, buffers, now, cameraPosition, mousePosition);

        requestAnimationFrame(render);
    }
    requestAnimationFrame(render);
}

function initBuffers(gl) {
    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    const positions = [
        1.0, 1.0,
        -1.0, 1.0,
        1.0, -1.0,
        -1.0, -1.0,
    ];

    gl.bufferData(gl.ARRAY_BUFFER,
        new Float32Array(positions),
        gl.STATIC_DRAW);

    return {
        position: positionBuffer,
    };
}

function runProgram(gl, programInfo, buffers, deltaTime, cameraPosition, mousePosition) {

    resize(gl.canvas);
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
    
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clearDepth(1.0);
    gl.enable(gl.DEPTH_TEST);
    gl.depthFunc(gl.LEQUAL);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    {
        const numComponents = 2;
        const type = gl.FLOAT;
        const normalize = false;
        const stride = 0;
        const offset = 0;

        gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);
        gl.vertexAttribPointer(
            programInfo.attribLocations.vertexPosition,
            numComponents,
            type,
            normalize,
            stride,
            offset);
        gl.enableVertexAttribArray(
            programInfo.attribLocations.vertexPosition);
    }

    gl.useProgram(programInfo.program);

    /*
    gl.uniformMatrix4fv(
        programInfo.uniformLocations.projectionMatrix,
        false,
        projectionMatrix);
    gl.uniformMatrix4fv(
        programInfo.uniformLocations.modelViewMatrix,
        false,
    modelViewMatrix);
    */

    calculateMousePosition(gl, mousePosition);
    
    var worldMousePos = new THREE.Vector2(mousePosition.x, mousePosition.y);
        worldMousePos.multiplyScalar(2.0);
        worldMousePos.subScalar(1.0);
        worldMousePos.y *= gl.canvas.height / gl.canvas.width;

    var sunVector = new THREE.Vector3(worldMousePos.x, worldMousePos.y, 1.0);
        sunVector.normalize();

    gl.uniform3f(programInfo.uniformLocations.camPosLocation, cameraPosition.x, cameraPosition.y, cameraPosition.z);
    gl.uniform3f(programInfo.uniformLocations.sunVecLocation, sunVector.x, sunVector.y, sunVector.z);
    gl.uniform2f(programInfo.uniformLocations.resLocation, gl.canvas.width, gl.canvas.height);
    gl.uniform2f(programInfo.uniformLocations.mousePosLocation, mousePosition.x, mousePosition.y);
    gl.uniform1f(programInfo.uniformLocations.frameTimeCountLocation, deltaTime);

    {
        const offset = 0;
        const vertexCount = 4;
        gl.drawArrays(gl.TRIANGLE_STRIP, offset, vertexCount);
    }
}

function initShaderProgram(gl, vsSource, fsSource) {
    const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource);
    const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

    const shaderProgram = gl.createProgram();

    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        alert('Unable to initialize the shader program: ' + gl.getProgramInfoLog(shaderProgram));

        return null;
    }

    return shaderProgram;
}

function loadShader(gl, type, source) {
    const shader = gl.createShader(type);

    gl.shaderSource(shader, source);
    gl.compileShader(shader);

    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        alert('An error occurred compiling the shaders: ' + gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);

        return null;
    }

    return shader;
}

function readFile(file)
{
    var res = "";
    var f = new XMLHttpRequest();
    f.open("GET", file, false);
    f.onreadystatechange = function ()
    {
        if(f.readyState === 4)
        {
            if(f.status === 200 || f.status == 0)
            {
                res = f.responseText;
            }
        }
    }
    f.send(null);
    return res;
}

function resize(canvas) {
    var renderQualitySlider = document.getElementById("renderQualitySlider");
    var renderQualityValue = document.getElementById("renderQualitySliderVal");
    
    var resmult = renderQualitySlider.value;

    renderQualityValue.innerHTML = resmult;

    // Lookup the size the browser is displaying the canvas.
    var displayWidth  = canvas.clientWidth * resmult;
    var displayHeight = canvas.clientHeight * resmult;

    // Check if the canvas is not the same size.
    if (canvas.width  != displayWidth ||
        canvas.height != displayHeight) {
   
      // Make the canvas the same size
        canvas.width  = displayWidth;
        canvas.height = displayHeight;
    }

}

function drawSourcecode(code){
    var sc = document.getElementById('sourceCode');
    sc.innerHTML = code;
}

function rewritefsSource(){
    document.getElementById('sourceCode').innerHTML = $('#sourceCode').html();
}

function moveCamera(cameraPosition){

    var speed = 10000.0;

    if (hasEnteredSimulation) {
        if (keyboardInput.keyShift) speed = 50000.0;
        if (keyboardInput.keyX)     speed = 1000.0;
        if (keyboardInput.keyD)     cameraPosition.x += speed;
        if (keyboardInput.keyS)     cameraPosition.z -= speed;
        if (keyboardInput.keyA)     cameraPosition.x -= speed;
        if (keyboardInput.keyW)     cameraPosition.z += speed;
        if (keyboardInput.keySpace) cameraPosition.y += speed * 0.25;
        if (keyboardInput.keyC)     cameraPosition.y -= speed * 0.25;
    }

    //cameraPosition.y = Math.max(cameraPosition.y, -Math.sqrt(cameraPosition.x * cameraPosition.z) + 1.0);
}

function calculateMousePosition(gl, mousePosition){
    document.addEventListener("mousemove", mouseMoveHandler, false);
    
    function mouseMoveHandler(e) {
        mousePosition.x = (e.clientX / gl.canvas.width) * 0.5;
        mousePosition.y = 1.0 - (e.clientY / gl.canvas.height) * 0.5;
    }
}