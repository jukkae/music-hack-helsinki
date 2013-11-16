//This shall be a 303 clone!

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

class BassLine implements Instrument
{
  
  Oscil wave1;
  Oscil fm;
  Multiplier gate;
  ADSR adsr;
  LowPassSP lpf;
  WaveShaper shaper;
  Delay delay;
  Flanger flanger;
  
  
  BassLine(){
    wave1 = new Oscil(110.0f, 1.0f, Waves.SINE);
    fm = new Oscil( 110, 0.5f, Waves.SINE );
    fm.offset.setLastValue(110);
    fm.patch(wave1.frequency);
    
    
    gate = new Multiplier(0);
    adsr = new ADSR(0.5f, 0.01f, 0.25f);
    shaper = new WaveShaper(0.8f, 1.0f, Waves.SAW, true);
    lpf = new LowPassSP(100, 44100);
    delay = new Delay(0.374, -0.7, true, true);
    flanger = new Flanger(1, 0.1, 5, 0.3, 0.5, 0.5);
    
    wave1.patch(gate);
    gate.patch(shaper);
    shaper.patch(adsr);
    adsr.patch(lpf);
    lpf.patch(delay);
    delay.patch(flanger);
    flanger.patch(out);
  }
  
  void setFreq(float freq){
    wave1.setFrequency(freq);
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
