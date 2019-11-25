//------------------------------------------------------------------------------
// PREAMBLE
// -----------------------------------------------------------------------------
let canvas;
var screensize = 400;
//------------------------------------------------------------------------------
if (typeof fullscreenMode != "undefined")
{
    screensize = ($(window).width() < $(window).height()) ? $(window).width() : $(window).height();
    screensize *= 4.0/5.0;
}
else
{
    screensize = (4 * $("#sketch-holder").width()) / 5;
}

//------------------------------------------------------------------------------
function windowResized()
{
    if (typeof fullscreenMode != "undefined")
    {
        screensize = ($(window).width() < $(window).height()) ? $(window).width() : $(window).height();
        screensize *= 4.0/5.0;
        var x = (windowWidth - width) / 2;
        var y = (windowHeight - height) / 2;
        canvas.position(x, y);
    }
    else
    {
        screensize = (4 * $("#sketch-holder").width()) / 5;
    }
    resizeCanvas(screensize, screensize);
}
//------------------------------------------------------------------------------
// END PREAMBLE
//------------------------------------------------------------------------------
let playing = false;
let fft;
let pitchDetect;
let mic;
let backgroundColor;
//------------------------------------------------------------------------------

function setup()
{
    backgroundColor = color(50, 50, 50);
    canvas = createCanvas(screensize, screensize, P2D);
    canvas.parent('sketch-holder');
    if (typeof fullscreenMode != "undefined")
    {
        var x = (windowWidth - width) / 2;
        var y = (windowHeight - height) / 2;
        canvas.position(x, y);
    }

    textAlign(CENTER);
    fft = new p5.FFT();
    mic = new p5.AudioIn();
    mic.start();
    fft.setInput(mic);
    pitchDetect = new PitchDetect(sampleRate(), fft.waveform().length);
    textSize(18);
}

//------------------------------------------------------------------------------

function draw()
{
    (!playing)? drawSplash() : drawTuner();


}


function drawSplash()
{
    background(backgroundColor);
    noStroke();
    fill(255);
    text("click to play", width/2, height/2);
}

function drawTuner()
{
    background(backgroundColor);
    noStroke();
    fill(255);
    let pitchData = pitchDetect.getPitch(fft.waveform());


    text(pitchData.note, width/2, height/2);

    rectMode(CORNERS); // Set rectMode to CORNERS
    if (Math.abs(pitchData.cents) > 0.10)
    {
        fill(200, 10, 10);
    } else
    {
        fill(20, 200, 10);
    }
    if (frameCount % 30 === 0 && playing)
    {
        console.log(mic.getLevel());
        console.log(pitchData);
        pitchDetect.getRms(fft.waveform());
    }
    rect(width/2, height/2 + 20, width/2 + pitchData.cents * 200, height/2 + 40);
}


function touchStarted()
{
    if (getAudioContext().state !== 'running')
    {
        getAudioContext().resume();
    }
    if (mouseX > 0 && mouseX < width && mouseY < height && mouseY > 0)
    {
        if (!playing)
        {
            playing = true;

        } else
        {
            playing = false;
        }
    }
}
function mouseClicked()
{

    if (mouseX > 0 && mouseX < width && mouseY < height && mouseY > 0) {
        if (!playing)
        {
            playing = true;
            // backgroundColor = color(0, 0, 0);
        } else
        {
            if (getAudioContext().state !== 'running')
            {
                getAudioContext().resume();
            }
            playing = false;
            // backgroundColor = color(50);
        }
    }
}