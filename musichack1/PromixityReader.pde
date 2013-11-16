import processing.serial.*;

class PromixityReader {
  Serial serialPort;
  final int SERIAL_BAUD_RATE = 9600;
  int lastValue;

  void init(musichack1 parent, String deviceStr) {
    lastValue = 0;
    
    try {
      serialPort = new Serial(parent, deviceStr, SERIAL_BAUD_RATE);
    } catch (RuntimeException e) {
      println("Serial device " + deviceStr + " not found!");
      serialPort = null;
    }
  }
  
  void pollValue() {
    int val;
    
    if (serialPort.available() > 0) {
      val = serialPort.read();
      lastValue = val;
    }
  }
  
  int getLastValue() {
    return lastValue;
  }
}
