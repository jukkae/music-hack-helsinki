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
  
  
  BassLine(){
    wave1 = new Oscil(110.0f, 0.3f, Waves.SAW);
    gate = new Multiplier(0);
    adsr = new ADSR(0.3f, 0.01f, 0.25f);
    
    wave1.patch(gate);
    gate.patch(adsr);
    adsr.patch(out);
    
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
