//A pad synth

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

class Pad implements Instrument
{
  Oscil pwm1, pwm2, pwm3;
  Summer lineMix;
  Summer out;
  LowPassSP lpf;
  Delay delay;
  Flanger flanger;
  Oscil lfo1, lfo2, lfo3;
  Multiplier gate;
  
  Pad( Summer output ){
    out = output;
    pwm1 = new Oscil(220.0f, 1.0f, Waves.SQUARE);
    pwm2 = new Oscil(261.62f, 1.0f, Waves.SQUARE);
    pwm3 = new Oscil(329.62f, 1.0f, Waves.SQUARE);
    lpf = new LowPassSP(100.0f, 44100);
    delay = new Delay(0.227, 0.7, true, true);    
    lineMix = new Summer();
    gate = new Multiplier(1.0f);
    
    lfo1 = new Oscil(0.1f, 0.1, Waves.SINE);
    lfo1.patch(pwm1.amplitude);
    lfo2 = new Oscil(0.14f, 0.1, Waves.SINE);
    lfo2.patch(pwm2.amplitude);
    lfo3 = new Oscil(0.08f, 0.1, Waves.SINE);
    lfo3.patch(pwm3.amplitude);
    
    
    pwm1.patch(lineMix);
    pwm2.patch(lineMix);
    pwm3.patch(lineMix);
    lineMix.patch(gate);
    gate.patch(lpf);
    lpf.patch(delay);
    delay.patch(out);
    
    }
    
    void setChord(float note1, float note2, float note3){
      pwm1.setFrequency(note1);
      pwm2.setFrequency(note2);
      pwm3.setFrequency(note3);
      
    }
  
  void noteOn(float f){

  }
  
  void noteOff(){
    
  }
}
