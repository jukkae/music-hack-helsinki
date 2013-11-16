import processing.serial.*;

Serial serialPort;
String serialDevice = "/dev/tty.usbserial-AH013H15";
int serialRate = 9600;

// So we want to read the input from the serial port
// And output this to the sound generator ..
// 
// What we are getting from the device is
// the tagcodes

void setup() {
  serialPort = new Serial(this, serialDevice, serialRate);
}

void draw() {
    readTags();
    delay(100);
}

// This reads the ID-12 data from the serial port

int asciiToHex(int val) {
  int hex = 0;

  if ((val >= '0') && (val <= '9')) {
    hex = val - '0';
  } 
  else if ((val >= 'A') && (val <= 'F')) {
    hex = 10 + val - 'A';
  }

  return hex;
}

void printCode(int[] code) {
  println("Tag Code read succesfully");
  for (int i=0; i<5; i++) {
    if (code[i] > 16) {
      print("0");
    }
    print(code[i]);
    print(" ");
  }

  println();
}

void readTags() {
  int val;
  int bytes_read = 0;
  int checksum = 0;
  int tmp = 0;
  int [] code;

  code = new int[6];

  if (serialPort.available() > 0) {
    val = serialPort.read();

    // header = 2
    if (val == 2 ) {
      println("header read");

      bytes_read = 0;
      while (bytes_read < 12) {
        if (serialPort.available() > 0) {
          val = serialPort.read();
          
          // Check if it's the header or the ending
          if (val == 0x0D || val == 0x0A || val == 0x02) {
            break;
          }

          val = asciiToHex(val);
          //println("0x" + val);

          // Every two hex-digits, add the converted value to the tag code
          if ((bytes_read & 1) == 1) {         
            code[bytes_read >> 1] = (val | (tmp << 4));
            // Are we at the checksum byte ?
            if ((bytes_read >> 1) != 5) {
              // Checksum is XOR              
              checksum ^= code[bytes_read >> 1];
            }            
          } 
          else {
            // This is the other part of the hex value
            tmp = val;
          }
          
          bytes_read += 1;
        }
      }

      println("total bytes read = " + bytes_read);
      
      // Read Succesfull
      if (bytes_read >= 12) {    
        printCode(code);
      }
      else {
        println("Not read succesfully!");
      }
    }
  }
} 

