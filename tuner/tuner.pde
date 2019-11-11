/*
 *    tuner based on zero crossing counting
 */
import processing.sound.*;
//------------------------------------------------------------------------------
Sound audioConfig;
AudioIn in;
LowPass lowPass;
SinOsc wave;
Waveform waveform;
float sampleRate;
float lowPassFreq = 800;
//------------------------------------------------------------------------------
int samples = 4410;
float framerate = 4;
float bufferRatio; // 2 * sampleRate / samples
int avgWindowSize = 5;
float[] freqWindow = new float[avgWindowSize];
int windowIndex = 0;
float averageFrequency = 0;
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
  strokeWeight(2);
  noFill();

  float freqDetected = getZeroCrossings() * bufferRatio;  
  float currentFrequency = getAltAvgFrequency(freqDetected);
  float midi_note = hz2midi(currentFrequency);
  float cents = floor(midi_note + 0.5) - midi_note;
  textAlign(CENTER);
  text(midi2note(midi_note), width/2, height/2);
  rectMode(CENTER);
  noFill();
  rect(width/2, height/2 + 20, 2, 20);

  if (abs(cents) > 0.1)
    fill(255,0,0);
  else
    fill(0,255,0);
    
  rectMode(CORNERS);
  if (cents < 0.0)
    rect(width/2, height/2 +10, width/2 - (160*abs(cents)), height/2 + 30);
  else
    rect(width/2, height/2 +10, width/2 + (160*cents), height/2 + 30);
}
//------------------------------------------------------------------------------
void keyPressed()
{
  if (key == 'a')
  {
    lowPassFreq += 100.0;
  } else if (key == 'z')
  {
    lowPassFreq -= 100.0;
  }
  println(lowPassFreq);
  lowPass.freq(lowPassFreq);
}
//------------------------------------------------------------------------------
