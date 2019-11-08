/*
 *    tuner based on zero crossing counting
 */
import processing.sound.*;
//------------------------------------------------------------------------------
Sound audioConfig;
SinOsc wave;
Waveform waveform;
float audioConfig;
//------------------------------------------------------------------------------
int samples = 4410;
float framerate = 2;
float bufferRatio; // 2 * sampleRate / samples
int avgWindowSize = 5;
float[] freqWindow = new float[avgWindowSize];
int windowindex = 0;
float averageFrequency = 0;
//------------------------------------------------------------------------------
PFont f;
//------------------------------------------------------------------------------
float freq = 440;
public void setup()
{
    size(640, 360);
    background(255);

    wave = new SinOsc(this);
    wave.freq(freq);
    audioConfig  = new Sound(this);
    sampleRate = float(audioConfig.sampleRate());
    bufferRatio = 2.0f * sampleRate / (float)samples;
    waveform = new Waveform(this, samples);
    waveform.input(wave);
    frameRate(framerate);

    f = createFont("SourceCodePro-Regular.ttf", 24);
    textAlign(CENTER);
    textFont(f);
}
//------------------------------------------------------------------------------
public void draw()
{
    background(0);
    stroke(255);
    strokeWeight(2);
    noFill();

    waveform.analyze();

    float freqDetected = getZeroCrossings() * bufferRatio;
    float currentFrequency = getAveragedFrequency(freqDetected);
    text(String(currentFrequency), width/2, height/2);
}
//------------------------------------------------------------------------------
void keyPressed()
{

    if (key == 'a')
    {
        framerate+= 0.25;
    }
    else if (key == 'z')
    {
        framerate-= 0.25;
    }
    frameRate(framerate);
    println(framerate);
}

float getZeroCrossings()
{
    int zeroCrossCounter = 0;
    for (int i = 1; i < samples; i++)
    {
        if (waveform.data[i] < 0 && waveform.data[i - 1] > 0
            || waveform.data[i] > 0 && waveform.data[i - 1] < 0)
        {
            zeroCrossCounter++;
        }
    }
    return (float)zeroCrossCounter;
}

float getAveragedFrequency(float frequency)
{
    freqWindow[windowIndex] = frequency;
    windowIndex++;
    windowIndex%=avgWindowSize;
    float average = 0;
    for (int i = 0; i < avgWindowSize; i++)
    {
        average += freqWindow[i];
    }
    return average / (float)avgWindowSize;
}

void altAvg(float frequency)
{
  float oldFreq = freqWindow[windowIndex] / (float)avgWindowSize;
  float newFreq = frequency / (float)avgWindowSize;
  freqWindow[windowIndex] = frequency;
  windowIndex++;
  windowIndex%=avgWindowSize;

  averageFrequency += newFreq - oldFreq;
}
