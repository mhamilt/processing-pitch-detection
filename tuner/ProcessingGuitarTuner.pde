import processing.sound.*;

SinOsc wave;
Waveform waveform;

int samples = 4410;
float framerate = 2;

float freq = 440;
public void setup() 
{
  size(640, 360);
  background(255);

  wave = new SinOsc(this);
  wave.freq(freq);
  //wave.play();
  waveform = new Waveform(this, samples);
  waveform.input(wave);
  frameRate(framerate);
}

public void draw() 
{

  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();


  waveform.analyze();

  beginShape();
  int zeroCrossCounter = 0;
  for (int i = 0; i < samples; i++)
  {   
    vertex(
      map(i, 0, samples, 0, width), 
      map(waveform.data[i], -1, 1, 0, height)
      );
    if (i != 0)
    {      
      if (waveform.data[i] < 0 && waveform.data[i-1] > 0
        || waveform.data[i] > 0 && waveform.data[i-1] < 0)
      {
        zeroCrossCounter++;
      }
    }
  }
  endShape();
  println((float(zeroCrossCounter) * 0.5f) * float(44100) / float(samples));

  if ((frameCount % 20) == 0)
  {
    freq += 10;
    wave.freq(freq);
  }
}

void keyPressed()
{

  if (key == 'a') 
  {
    framerate+= 0.25;
  } else if (key == 'z')
  {
    framerate-= 0.25;
  }
  frameRate(framerate);
  println(framerate);
}
