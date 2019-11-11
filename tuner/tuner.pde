/*
 *    tuner based on zero crossing counting
 */
import processing.sound.*;
//------------------------------------------------------------------------------
Sound audioConfig;
AudioIn in;
LowPass lowPass;
BandPass bandPass;
SinOsc wave;
Waveform waveform;
float sampleRate;
float lowPassFreq = 800;
boolean pitchDetectMode = false;
//------------------------------------------------------------------------------
int samples = 4410;
float framerate = 5;
float bufferRatio; // 2 * sampleRate / samples
int avgWindowSize = 5;
float[] freqWindow = new float[avgWindowSize];
float[] corrolatedSignal = new float [samples];
int[] localMaxima = new int[10];
float maximaMean = 0;
int windowIndex = 0;
float averageFrequency = 0;
float currentFrequency = 0;
float cents = 0;
float midi_note = 0;
//------------------------------------------------------------------------------
PFont f;
//------------------------------------------------------------------------------
float freq = 440;
public void setup()
{
  size(640, 360);
  background(255);

  audioConfig  = new Sound(this);
  sampleRate = float(audioConfig.sampleRate());
  bufferRatio = 0.5f * sampleRate / (float)samples;

  in = new AudioIn(this, 0);
  //in.play();

  lowPass = new LowPass(this);
  lowPass.process(in, lowPassFreq);
  bandPass = new BandPass(this);
  waveform = new Waveform(this, samples);
  waveform.input(in);

  frameRate(framerate);
  f = createFont(PFont.list()[19], 24);
  textAlign(CENTER);
  textFont(f);
}
//------------------------------------------------------------------------------
public void draw()
{
  background(0);
  stroke(255);  
  noFill();

  if (getRms() > 0.03)
  {
    float freqDetected = (pitchDetectMode) ? (getZeroCrossings() * bufferRatio) : autocorrolatePitch();
      currentFrequency = freqDetected;
    //currentFrequency = getAltAvgFrequency(freqDetected);
    midi_note = hz2midi(currentFrequency);   
    println(currentFrequency);
    cents = midi_note - floor(midi_note + 0.5); 
  } 
  textAlign(CENTER);
  text(midi2note(midi_note), width/2, height/2);
  rectMode(CENTER);
  noFill();
  rect(width/2, height/2 + 20, 2, 20);
  
  if (abs(cents) > 0.05)
    fill(255, 0, 0);
  else
    fill(0, 255, 0);

  rectMode(CORNERS);
  if (cents < 0.0)
    rect(width/2, height/2 +10, width/2 - (260*abs(cents)), height/2 + 30);
  else
    rect(width/2, height/2 +10, width/2 + (260*cents), height/2 + 30);
}
//------------------------------------------------------------------------------
void keyPressed()
{
  if (key == 'a')
  {
    lowPassFreq += 100.0;
  } else if (key == 'z')
  {
    if (lowPassFreq>200)
      lowPassFreq -= 100.0;
  }
  println(lowPassFreq);
  lowPass.freq(lowPassFreq);
}
//------------------------------------------------------------------------------
