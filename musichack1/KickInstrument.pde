// this KickInstrument will make a sound that is like an analog kick drum
class KickInstrument implements Instrument
{
  
  Oscil sineOsc;
  Line  freqLine;
  Summer out;
  Multiplier gate;
  ADSR adsr;
  
  KickInstrument( Summer output )
  {
    out = output;
    sineOsc = new Oscil(100.f, 0.4f, Waves.SINE);
    freqLine = new Line( 0.08f, 200.f, 5.0f );
    gate = new Multiplier(0);
    adsr = new ADSR(1.0f, 0.01f, 0.25f);
    
    
    freqLine.patch( sineOsc.frequency );
    sineOsc.patch(gate);
    gate.patch(adsr);
    adsr.patch(out);
  }
  
  
  void noteOn(float dur)
  {
    freqLine.activate();
    gate.setValue(1.0f);
    adsr.noteOn();
  }
  
  
  void noteOff()
  {
    gate.setValue(0.0f);
    adsr.noteOff();
  }
}
