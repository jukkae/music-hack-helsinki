/*
Built for Music Hack Day Helsinki 2013
*/


import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim               minim;
AudioOutput         out;
public Oscil        wave1, wave2, wave3;
Oscil               fm;
KickInstrument      kick;
LowPassSP           lpf;
Summer              lineMixer, mixer;
BassLine            bassline;

TagReader           tagReader;
StringList          activeTags;
int                 elapsedFrames;

Visualizer          vis;

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
  size(GeoKoneGlobals.DEF_CANVAS_WIDTH, GeoKoneGlobals.DEF_CANVAS_HEIGHT, P3D);
  frameRate(60);
  
  
  // MINIM INFRASTRUCTURE
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // create 3 saw wave Oscils, set to 440 Hz, at 0.3 amplitude
  wave1 = new Oscil( 440, 0.2f, Waves.SAW );
  wave2 = new Oscil( 440, 0.2f, Waves.SAW );
  wave3 = new Oscil( 440, 0.2f, Waves.SAW );
  
  // FM oscillator
  fm = new Oscil( 440, 0.5f, Waves.SINE );
  
  // create a line mixer for oscillators
  lineMixer = new Summer();
  
  // create a mixer for everything
  mixer = new Summer();
  
  // create a new LPF
  lpf = new LowPassSP(100, 44100);
  
  // create a kick drum
  kick = new KickInstrument( mixer );
    
  //bassline
  bassline = new BassLine();
  
  // patch everything together
  wave1.patch( lineMixer );
  // waves 2 & 3 disabled for the time being!
//  wave2.patch( lineMixer );
//  wave3.patch( lineMixer );

  //lineMixer.patch( lpf );

  
  lpf.patch( mixer );
  
  mixer.patch( out );
  
  
  // patch FM
  fm.offset.setLastValue(440);
  fm.patch(wave1.frequency);
  
  
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
  
  // Visualizer
  vis = new Visualizer();
  vis.init(this, GeoKoneGlobals.DEF_CANVAS_WIDTH, GeoKoneGlobals.DEF_CANVAS_HEIGHT);
}

void mouseMoved()
{
  float cutoff = map(mouseX, 0, width, 20, 1000);
  int note = (int) map(mouseY, 0, height, 0, 7);
  float freq1 = convertNoteToFreq(note);
  float freq2 = convertNoteToFreq((note+3)%7);
  float freq3 = convertNoteToFreq((note+5)%7);
  
  //lpf.setFreq(cutoff);
  wave1.setFrequency(freq1);
  wave2.setFrequency(freq2);
  wave3.setFrequency(freq3);
  
  float modAmt = map( mouseY, 0, height, 220, 1 );
  float modFreq = map( mouseX, 0, width, 200, 1000 );
  
  bassline.fm.setAmplitude(modAmt);
  bassline.fm.setFrequency(modFreq);
  bassline.fm.offset.setLastValue(freq1);
  wave1.setFrequency(freq1);
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
  
  // MOVE SEQUENCER
    if ( millis() - clock >= quarterNoteLength )
  {
    clock = millis();
    beat = (beat+1) % 16;
    beatTriggered = false;
    
    if(beat%2==0){
      kick.noteOn(0.1);
      
    }
    else{
      kick.noteOff();
      
    }
    
    // Change frequency of main oscillator & FM oscillator
    if((beat+1)%4 == 0){
      wave1.setFrequency(110.0f);
      fm.offset.setLastValue(110.0f);
    }
    else{
      wave1.setFrequency(220.0f);
     fm.offset.setLastValue(220.0f);
    }
    
    
    //BASSLINE
    //ugly implementation just to test, sorry
    switch(beat){
      case 0:
        bassline.setFreq(convertNoteToFreq(0));
        bassline.noteOn(1.0f);
        break;
      case 1:
        bassline.noteOff();
        break;
      case 2:
        bassline.setFreq(convertNoteToFreq(4));
        bassline.noteOn(1.0f);
        break;
      case 3:
        bassline.setFreq(convertNoteToFreq(5));
        bassline.noteOn(1.0f);
        break;
      case 4:
        bassline.noteOff();
        break;
      case 5:
        bassline.setFreq(convertNoteToFreq(3));
        bassline.noteOn(1.0f);
        break;
      case 6:
        bassline.setFreq(convertNoteToFreq(4));
        bassline.noteOn(1.0f);
        break;
      case 7:
        bassline.noteOff();
        break;
      case 8:
        bassline.setFreq(convertNoteToFreq(0));
        bassline.noteOn(1.0f);
        break;
      case 9:
        bassline.noteOff();
        break;
      case 10:
        break;
      case 11:
        break;
      case 12:
      
        break;
      case 13:
      
        break;
      case 14:
      
        break;
      case 15:
      
        break;
    }
    
  }

  vis.doDraw(beat, elapsedFrames, out);
  
  elapsedFrames += 1;
  
  // texts for testing
  text(beat, width-400, height-120);
  text(clock, width-300, height-120);
  text(frameRate, width-120, height-120);
}
