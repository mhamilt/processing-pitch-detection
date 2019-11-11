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

float getAltAvgFrequency(float frequency)
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
  int wholeNote = floor(midi + 0.5); // Offset so that 50 cents is the switching point
  int index = (wholeNote) % 12;

  return notes[index];
}
