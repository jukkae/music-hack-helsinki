/*
Built for Music Hack Day Helsinki 2013
*/


import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim               minim;
AudioOutput         out;
KickInstrument      kick;
Summer              lineMixer, mixer;
BassLine            bassline;
Hihat               hihat;
Pad                 pad;

TagReader           tagReader;
ProximityReader     proximityReader;
StringList          activeTags;
int                 elapsedFrames;

float               cameraX;
float               cameraY;
float               cameraZ;
float               note1;
float               note2;
float               note3;

Visualizer          vis;

// The unique id's for our tags
// We can check with activeTags.hasValue(blueTagId) for example
final String        blueTagId = "3D0061B5A8";
final String        yellowTagId = "3D0061DA1B";
final String        redTagId = "3C00CE2C49";

// global sequencer variables
int bpm;
float quarterNoteLength; // Length of a quarter note in ms
int clock; // timer for moving from note to note
int beat; // current beat
int sixteenth; // current sixteenth
boolean beatTriggered; // trigger each beat once
int numberOfSteps; // length of the sequence in quarter notes
int[] basslineNotes; // notes for bassline
boolean[] basslineGates; // booleans for whether or not note is played on bass
boolean[] hihatPattern; // booleans for hihat pattern
color backgroundColor;

//PenroseLSystem ds;

void setup()
{
  backgroundColor = color(0,0,0);
  // GENERAL PROCESSING VARIABLES
  size(GeoKoneGlobals.DEF_CANVAS_WIDTH, GeoKoneGlobals.DEF_CANVAS_HEIGHT, P3D);
  frameRate(60);
  
  
  // MINIM INFRASTRUCTURE
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();

  
  // create a line mixer for oscillators
  lineMixer = new Summer();
  
  // create a mixer for everything
  mixer = new Summer();
  
  // create a kick drum
  kick = new KickInstrument( mixer );
    
  //bassline
  bassline = new BassLine( mixer );
  
  //hihat
  hihat = new Hihat( mixer );
  
  pad = new Pad( mixer );
  
  mixer.patch( out );
  
  // SEQUENCER VARIABLES
  numberOfSteps = 16;
  // initialize bpm at 120
  bpm = 120;
  //calculate length of a quarter note. 60000 ms in a minute.
  quarterNoteLength = 60000 / bpm;
  // get clock from millis()
  clock = millis();
  beat = 0;
  sixteenth = 0;
  beatTriggered = false;
  basslineNotes = new int[numberOfSteps];
  basslineGates = new boolean[numberOfSteps];
  
  makeBassline();
  
  //for testing
  hihatPattern = new boolean[numberOfSteps*4];
  for(int i = 0; i < (4*numberOfSteps); i++){
    if((i+2)%4==0)hihatPattern[i]=true;
    else hihatPattern[i]=false;
  }
  
  // Initialize the tagReader
  tagReader = new TagReader();
  tagReader.init(this, "/dev/tty.usbserial-AH013H15");
  
  proximityReader = new ProximityReader();
  proximityReader.init(this, "/dev/tty.usbmodemfa141");
  
  thread("fetchSerial");
  
  // Visualizer
  vis = new Visualizer();
  vis.init(this, out, GeoKoneGlobals.DEF_CANVAS_WIDTH, GeoKoneGlobals.DEF_CANVAS_HEIGHT);

  cameraX = 0;
  cameraY = 0;
  cameraZ = 400;
  note1 = 0;
  note2 = 0;
  note3 = 0;
}
 
//fills the bassline notes with random values
void makeBassline(){
  for (int i = 0; i < numberOfSteps; i++){
    basslineNotes[i] = int(random(7));
    basslineGates[i] = false;
    if(random(1)<0.8)basslineGates[i] = true;
  }
  //notes MUST be switched off every now and then, otherwise there'll be feedback and general mayhem
  boolean test = false;
  for (int i = 0; i < numberOfSteps; i++){
    if(!basslineGates[i])test=true;
  }
  if(!test)makeBassline();
}

//MARKOV CHAIN BITCHES
void makeNewHihats(){
  for(int i = 0; i < numberOfSteps*4; i++){
    if(random(1)<0.05){
      hihatPattern[i] = !hihatPattern[i];
      if(i!=0){
        if(!hihatPattern[i-1]){
          if(random(1)<0.2)hihatPattern[i]=true;
        }
        else{
          if(random(1)<0.01)hihatPattern[i]=false;
        }
      }
    }
  }
}



void mouseMoved()
{
  /*float cutoff = map(mouseX, 0, width, 20, 1000);
  int note = (int) map(mouseY, 0, height, 0, 7);
  float freq1 = convertNoteToFreq(note);

  float modAmt = map( mouseY, 0, height, 220, 1 );
  float modFreq = map( mouseX, 0, width, 200, 1000 );
  
  
  bassline.fm.setAmplitude(modAmt);
  bassline.fm.setFrequency(modFreq);
  bassline.fm.offset.setLastValue(freq1);
  
  
  vis.setModAmt(modAmt);
  vis.setModFreq(modFreq);
  */
}

// Convert from note index (0-7) to Hz. Scale is currently A minor.
float convertNoteToFreq(int note){
  float freq = 110.0f;
  
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

// Get note frequency in Hertz corresponding to int note distance in half steps away from A (110 Hz).
float getNoteFreq(int distance){
  //reference note A440
  float f0 = 440.0f;
  //half step
  float a = pow(2, -12);
  
  return f0*pow(a, distance);
}

void setPolyColor() {
  color polyColor;
  int [] randomColors = { GeoKoneColors.COLOR_WIPHALA_BLUE, GeoKoneColors.COLOR_WIPHALA_RED, GeoKoneColors.COLOR_WIPHALA_YELLOW };
  int r, g, b;
 
  r = 0;
  g = 0;
  b = 0;
  
  // Do some simple color combining
  if (activeTags.hasValue(blueTagId)) {
    b = 255;
  }
  if (activeTags.hasValue(yellowTagId)) {
    g = 255;
    r = 255; 
  }
  if (activeTags.hasValue(redTagId)) {
    r = 255;
  }
  
  /*
  if (r == 0 && g == 0 && b == 0) {
    polyColor = color(randomColors[int(random(3))]);
  } else {
  */
    polyColor = color(r, g, b);
  //}
  println("color = ", r, g, b);
  backgroundColor = color(r, g, b);
}

void draw()
{
  
  background(backgroundColor);
  stroke(255);
  
  // Poll the tags, only every 16 frames so that the reader doesn't get stuck
  if ((elapsedFrames % 16) == 0) {
    tagReader.pollTags();
    activeTags = tagReader.getActiveTags();
    if (tagReader.hasChanged()) {
      setPolyColor();
    }
  }

  // MOVE SEQUENCER
  if ( millis() - clock >= (quarterNoteLength/4) )
  {
    clock = millis();
    
    if(hihatPattern[sixteenth]) {
      hihat.noteOn(0.1);
      vis.cyclePolyColors();
    }
    else hihat.noteOff();
    
    if(sixteenth%4==0) { 
      kick.noteOn(0.1);
      vis.triggerKick();
    }
    else kick.noteOff();
    
    //beats
    if ( sixteenth%4 == 0 ){
        clock = millis();
        beat = (beat+1) % numberOfSteps;
        beatTriggered = false;
    
      if(basslineGates[beat]) {
	      bassline.setFreq(convertNoteToFreq(basslineNotes[beat]));
	      bassline.noteOn(1.0f);

	      //trigger pad chord changes only when we have bass!
	      //Am
	      if (random(1)<0.3) {
		      note1 = 2*convertNoteToFreq(0);
		      note2 = 2*convertNoteToFreq(2);
		      note3 = 2*convertNoteToFreq(4);
		      pad.setChord(note1, note2, note3);
	      }
	      if(random(1)<0.3){
		      pad.setChord(2*convertNoteToFreq(0), 2*convertNoteToFreq(2), 2*convertNoteToFreq(4));
	      }
	      //Dm
	      if (random(1)<0.1) {
		      note1 = 2*convertNoteToFreq(3);
		      note2 = 2*convertNoteToFreq(5);
		      note3 = 2*convertNoteToFreq(7);

		      pad.setChord(note1, note2, note3);
	      }
	      //Em
	      if (random(1)<0.01) {
		      note1 = 2*convertNoteToFreq(1);
		      note2 = 2*convertNoteToFreq(4);
		      note3 = 2*convertNoteToFreq(6);
		      pad.setChord(note1, note2, note3);
	      }
      } else {
	      bassline.noteOff();
      }        
    }

    if ( sixteenth % (numberOfSteps*4)==(numberOfSteps*4-1) ) {
      makeNewHihats();
    }
  }
  sixteenth = (sixteenth+1) % (4*numberOfSteps);

  String lastDistance = proximityReader.getLastValue();
  //text(lastDistance, width-200, height-400);
  float distance = float(lastDistance);

  cameraX = mouseX;
  cameraY = mouseY;
  cameraZ = 666 + (distance*4);
  
  println("distance = " + distance + " cameraZ = " + cameraZ);

  camera(cameraX, cameraY, cameraZ, // eyeX, eyeY, eyeZ
  width/2.0, height/2.0, 0.0, // centerX, centerY, centerZ
  0.0, 1.0, 0.0); // upX, upY, upZ

  vis.doDraw(beat, elapsedFrames);


  
  float freq2 = distance * 2;
  bassline.fm.setFrequency(freq2);
  bassline.fm.setAmplitude(map(distance, 20, 100, 220, 1));
  bassline.fm.offset.setLastValue(freq2);
  
  //lastDistance = lastDistance.replaceAll("\\\\r","");
  //lastDistance = lastDistance.replaceAll("\\\\n","");
  int note = (int(lastDistance)-20) > 50 ? 7 : int((int(lastDistance)-20)/6.25);
  pad.setChord(convertNoteToFreq(note%7)*2, convertNoteToFreq((note+2)%7)*2, convertNoteToFreq((note+4)%7)*2);
  //println("last distance = ", int(lastDistance), " note = ", note);
  
  //println(freq2);
  //text(freq2, width-200, height-400);
  
  elapsedFrames += 1;
  
  // texts for testing
  //text(beat, width-400, height-120);
  //text(clock, width-300, height-120);
  //text(frameRate, width-120, height-120);
}

void fetchSerial() {
  while (true) {
    proximityReader.pollValue();
    //println("lastValue = " + proximityReader.getLastValue());
    try {
      Thread.sleep(50);
    } 
    catch (InterruptedException e) {
      println(e);
    }
  }
}
