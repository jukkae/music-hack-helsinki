// 808 hihat, woop woop

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;

class Hihat implements Instrument
{
  

  Noise noise;
  Summer out;
  Multiplier gate;

  ADSR adsr;
  
  Hihat( Summer output )
  {
    out = output;
    noise = new Noise(0.1);
    gate = new Multiplier(0);
    adsr = new ADSR(1.0f, 0.01f, 0.05f);
    
    noise.patch(gate);
    gate.patch(adsr);
    adsr.patch(out);
  }
  
  
  void noteOn(float dur)
  {
    gate.setValue(1.0f);
    adsr.noteOn();
  }
  
  
  void noteOff()
  {
    gate.setValue(0.0f);
    adsr.noteOff();
  }
}
