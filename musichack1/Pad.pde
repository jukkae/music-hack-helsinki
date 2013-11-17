//A pad synth

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

class Pad implements Instrument
{
  Oscil pwm1;
  Summer out;
  
  Pad(Summer output){
    out = output;
    pwm1 = new Oscil(440.0f, 0.0, Waves.PHASOR);
    
    pwm1.patch(out);
    
    }
  
  void noteOn(float f){
    
  }
  
  void noteOff(){
    
  }
}
