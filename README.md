# Processing Pitch Detection

Applying some basic pitch detection algorithms using the [Processing Sound Library]()


## Installing sound library

[Installation instructions for the processing sound library are here](https://processing.org/reference/libraries/)

>The Video and Sound libraries need to be downloaded through the Library Manager. Select "Add Library..." from the "Import Library..." submenu within the Sketch menu.


## Key functions

There are a couple of key functions that make it easier to move from frequency to a human readable pitch and back again. They are listed below for ease


**Hz to Midi Note Number**

```java
float hz2midi(float hz)
{
  return 12.0f * log2(hz / 440.0f) + 69;
}
```

**Midi Note Number to Pitch**
```java
String midi2note(float midi)
{
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  int wholeNote = floor(midi);
  int index = (wholeNote) % 12;

  return notes[index];
}
```

**Midi Note to Hz**
```java
float midi2hz(float midi)
{
  return pow(2, (midi - 69.0f)/12.0f) * 440.0f;
}
```
## Sketches

### tuner

The `tuner.pde` sketch shows an example of pitch detection for tuning. Two methods are presented:

- Autocorrelation
- Zero Crossing

For more info both, see the references below.

## References

- [Comparison of Pitch Trackers for Real-Time Guitar Effects](http://dafx10.iem.at/papers/VonDemKnesebeckZoelzer_DAFx10_P102.pdf)
- [CCMRA: pitch detection methods review](https://ccrma.stanford.edu/~pdelac/154/m154paper.htm)
- [CCMRA: Pitch detection of musical signals](https://ccrma.stanford.edu/~eberdahl/Projects/Grundfrequenzanalyse/index.html)
