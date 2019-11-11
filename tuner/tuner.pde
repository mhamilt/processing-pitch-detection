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
  //float currentFrequency = getAvgFrequency(freqDetected);
  float currentFrequency = getAltAvgFrequency(freqDetected);
  text(midi2note(hz2midi(currentFrequency)), width/2, height/2);
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
