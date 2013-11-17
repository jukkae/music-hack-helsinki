import processing.serial.*;

class ProximityReader {
  Serial serialPort;
  final int SERIAL_BAUD_RATE = 9600;
  String lastValue;

  void init(musichack1 parent, String deviceStr) {
    lastValue = "";
    
    try {
      serialPort = new Serial(parent, deviceStr, SERIAL_BAUD_RATE);
    } catch (RuntimeException e) {
      println("Serial device " + deviceStr + " not found!");
      serialPort = null;
    }
  }
  
  void pollValue() {
    String val = "";
    char c = 'a';
    while (c != '\r') {
      if (serialPort.available() > 0)
      {
        c = char(serialPort.read());
        val += c;
        
      }
    }
    synchronized (lastValue) {
      lastValue = val;
    }
  }
  
  String getLastValue() {
    return lastValue;
  }
}