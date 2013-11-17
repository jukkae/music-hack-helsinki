//This shall be a 303 clone!

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

class BassLine implements Instrument
{
  
  Oscil wave1, wave2, sub, subsub;
  Oscil fm;
  Summer linemix, submix;
  Multiplier gate;
  ADSR adsr;
  LowPassSP lpf;
  WaveShaper shaper;
  Delay delay;
  Flanger flanger;
  Summer out;
  
  
  BassLine(Summer out){
    wave1 = new Oscil(110.0f, 0.8f, Waves.SINE);
    wave2 = new Oscil(220.5f, 0.3f, Waves.SINE);
    sub = new Oscil(55.0f, 0.7f, Waves.TRIANGLE);
    subsub = new Oscil(22.5f, 0.7f, Waves.SINE);
    fm = new Oscil( 110, 0.5f, Waves.SINE );
    fm.offset.setLastValue(110);
    fm.patch(wave1.frequency);
    

    linemix = new Summer();
    submix = new Summer();    
    gate = new Multiplier(0);
    adsr = new ADSR(0.5f, 0.01f, 0.25f);
    shaper = new WaveShaper(0.8f, 1.0f, Waves.SAW, true);
    lpf = new LowPassSP(100, 44100);
    delay = new Delay(0.374, -0.7, true, true);
    flanger = new Flanger(2, 0.05, 5, 0.3, 0.5, 0.5);
    
    wave1.patch(linemix);
    wave2.patch(linemix);
    sub.patch(submix);
    subsub.patch(submix);
    linemix.patch(shaper);
    shaper.patch(submix);
    submix.patch(gate);
    gate.patch(adsr);
    adsr.patch(lpf);
    lpf.patch(delay);
    
    delay.patch(out);
//    delay.patch(flanger);
//    flanger.patch(out);
  }
  
  void setFreq(float freq){
    wave1.setFrequency(freq);
    wave2.setFrequency(2*freq+1);
    sub.setFrequency(freq/2);
    subsub.setFrequency(freq/4);
    fm.offset.setLastValue(freq);
  }
  
  
  void noteOn(float f){
    gate.setValue(1.0f);
    adsr.noteOn();
  }
  
  void noteOff(){
    gate.setValue(0.0f);
    adsr.noteOff();
  }

}
