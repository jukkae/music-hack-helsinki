/*
Built for Music Hack Day Helsinki 2013
*/


import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim               minim;
AudioOutput         out;
Oscil               wave1, wave2, wave3;
KickInstrument      kick;
LowPassSP           lpf;
Summer              lineMixer, mixer;

TagReader           tagReader;
StringList          activeTags;
int                 elapsedFrames;

// The unique id's for our tags
// We can check with activeTags.hasValue(blueTagId) for example
final String        blueTagId = "3D0061B5A8";
final String        yellowTagId = "3D0061DA1B";
final String        redTagId = "3C00CE2C49";

// global sequencer variables
int bpm;
float quarterNoteLength; // Length of a quarter note in ms
int tempo; // how long a sixteenth note is in ms
int clock; // timer for moving from note to note
int beat; // current beat
boolean beatTriggered; // trigger each beat once



void setup()
{
  // GENERAL PROCESSING VARIABLES
  size(512, 512, P3D);
  frameRate(120);
  
  
  // MINIM INFRASTRUCTURE
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // create 3 saw wave Oscils, set to 440 Hz, at 0.3 amplitude
  wave1 = new Oscil( 440, 0.2f, Waves.SAW );
  wave2 = new Oscil( 440, 0.2f, Waves.SAW );
  wave3 = new Oscil( 440, 0.2f, Waves.SAW );
  
  // create a line mixer for oscillators
  lineMixer = new Summer();
  
  // create a mixer for everything
  mixer = new Summer();
  
  // create a new LPF
  lpf = new LowPassSP(100, 44100);
  
  // create a kick drum
  kick = new KickInstrument( mixer );
  
  
  // patch everything together
  wave1.patch( lineMixer );
  wave2.patch( lineMixer );
  wave3.patch( lineMixer );
  
  lineMixer.patch( lpf );
  
  lpf.patch( mixer );
  
  mixer.patch( out );
  
  
  // SEQUENCER VARIABLES
  // initialize bpm at 120
  bpm = 120;
  //calculate length of a quarter note. 60000 ms in a minute.
  quarterNoteLength = 60000 / bpm;
  // calculate length of a 16th note (REMOVE THIS)
  tempo = (15 / bpm) / 1000;
  // get clock from millis()
  clock = millis();
  beat = 0;
  beatTriggered = false;
  
  // Initialize the tagReader
  
  tagReader = new TagReader();
  tagReader.init(this, "/dev/tty.usbserial-AH013H15");
}

void mouseMoved()
{
  float cutoff = map(mouseX, 0, width, 20, 1000);
  int note = (int) map(mouseY, 0, height, 0, 7);
  float freq1 = convertNoteToFreq(note);
  float freq2 = convertNoteToFreq((note+3)%7);
  float freq3 = convertNoteToFreq((note+5)%7);
  
  lpf.setFreq(cutoff);
  wave1.setFrequency(freq1);
  wave2.setFrequency(freq2);
  wave3.setFrequency(freq3);
}


// Convert from note index (0-7) to Hz. Scale is currently A minor.
float convertNoteToFreq(int note){
  float freq = 440.0f;
  
  switch(note){
    case 0:
      freq=110.0f;
      break;
    case 1:
      freq=123.47f;
      break;
    case 2:
      freq=130.81f;
      break;
    case 3:
      freq=146.83f;
      break;
    case 4:
      freq=164.81f;
      break;
    case 5:
      freq=174.61f;
      break;
    case 6:
      freq=196.00f;
      break;
    case 7:
      freq=220.00f;
      break;
  }
  return freq;
}

// Get note frequency in Hertz corresponding to int note distance in half steps away from A4 (440 Hz).
float getNoteFreq(int distance){
  //reference note A440
  float f0 = 440.0f;
  //half step
  float a = pow(2, -12);
  
  return f0*pow(a, distance);
}

void draw()
{
  background(0);
  stroke(255);
  
  // Poll the tags, only every 16 frames so that the reader doesn't get stuck
  if ((elapsedFrames % 16) == 0) {
    tagReader.pollTags();
    activeTags = tagReader.getActiveTags();
  }
  
  // draw the waveforms
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    line( i, 50 + out.left.get(i)*50, i+1, 50 + out.left.get(i+1)*50 );
    line( i, 150 + out.right.get(i)*50, i+1, 150 + out.right.get(i+1)*50 );
  }
  
  
  // MOVE SEQUENCER
    if ( millis() - clock >= quarterNoteLength )
  {
    clock = millis();
    beat = (beat+1) % 16;
    beatTriggered = false;
    
    if(beat%2==0)kick.noteOn(0.1);
    else kick.noteOff();
  }


  
  
  // texts for testing
  text(beat, width-400, height-120);
  text(clock, width-300, height-120);
  text(frameRate, width-120, height-120);
  
  elapsedFrames += 1;
}
