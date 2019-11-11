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
  //float currentFrequency = getAveragedFrequency(freqDetected);
  float currentFrequency = altAvg(freqDetected);
  text(str(hz2midi(440)), width/2, height/2);
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
float getZeroCrossings()
{
  waveform.analyze();
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

float altAvg(float frequency)
{
  float oldFreq = freqWindow[windowIndex] / (float)avgWindowSize;
  float newFreq = frequency / (float)avgWindowSize;
  freqWindow[windowIndex] = frequency;
  windowIndex++;
  windowIndex%=avgWindowSize;

  averageFrequency += newFreq - oldFreq;
  return averageFrequency;
}
//------------------------------------------------------------------------------

float log2 (float x) 
{
  return (log(x) / log(2));
}

float hz2midi(float hz)
{
  return 12.0f * log2(hz / 440.0f) + 69;
}

float midi2hz(float midi)
{
  return pow(2, (midi - 69.0f)/12.0f) * 440.0f;
}


String midi2note(float midi)
{
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  int wholeNote = floor(midi);
  int index = (wholeNote) % 12;

  return notes[index];
}
