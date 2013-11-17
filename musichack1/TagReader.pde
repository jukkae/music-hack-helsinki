import processing.serial.*;

class TagReader {
  Serial serialPort;

  final int SERIAL_BAUD_RATE = 9600;
  // Message length of the ID-12 message
  final int RFID_MSG_LEN = 12;
  // Tag code length in hexadecimal numbers
  final int TAG_LEN = 5;

  StringList activeTags;
  
  boolean valuesChanged = true;

  void init(musichack1 parent, String deviceStr) {
    activeTags = new StringList();
    try {
      serialPort = new Serial(parent, deviceStr, SERIAL_BAUD_RATE);
    } catch (RuntimeException e) {
      println("Serial device " + deviceStr + " not found!");
      serialPort = null;
    }
  }

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

    for (int i=0; i<TAG_LEN; i++) {
      print(hex(code[i], 2));
    }

    println();
  }

  // Add tag from number array to our string representation
  // array
  void toggleActiveTag(int[] tag) {
    String tag_hex = "";
    String str;
    int index = 0;

    // Convert the array of integers to hex string
    for (int i=0; i<TAG_LEN; i++) {
      tag_hex += hex(tag[i], 2);
    }

    //println("tag_hex = " + tag_hex);

    // If we have it in our array, remove it
    if (activeTags.hasValue(tag_hex) == true) {
      // Umm not the best way, but works
      for (int i=0; i<activeTags.size(); i++) {
        str = activeTags.get(i);
        if (tag_hex.equals(str) == true) {
          activeTags.remove(i);
          println("removed index = " + i + " tag_hex = " + tag_hex);
        }
      }
    } 
    else {
      // add to our list
      activeTags.append(tag_hex);
      println("added tag_hex = " + tag_hex);
    }

    println(activeTags);
    valuesChanged = true;
  }
  
  StringList getActiveTags() {
    return activeTags;
  }
  
  boolean hasChanged() {
    boolean b = valuesChanged;
    valuesChanged = false;
    return b;
  }

  // So we want this to return an array structured like this:
  //
  // tags[] = ['30303', '390033'];

  // This reads the ID-12 data from the serial port
  void pollTags() {
    int val;
    int bytes_read = 0;
    int checksum = 0;
    int low_byte = 0;
    int [] tag_code;
    
    if (serialPort == null) {
      return;
    }

    // Tag code is a 5 number array
    // We add these codes to our activeTags array
    // as hexadecimal strings representing the id's
    tag_code = new int[TAG_LEN + 1];

    if (serialPort.available() > 0) {
      val = serialPort.read();

      // header begin = 2
      if (val == 2 ) {
        println("header read");

        bytes_read = 0;
        while (bytes_read < RFID_MSG_LEN) {
          if (serialPort.available() > 0) {
            val = serialPort.read();

            // Check if it's the header or the ending
            if (val == 0x0D || val == 0x0A || val == 0x02) {
              println("breaking, val = " + val);
              break;
            }

            val = asciiToHex(val);
            //println("0x" + val);

            // Every two hex-digits, add the converted value to the tag code
            if ((bytes_read & 1) == 1) {         
              tag_code[bytes_read >> 1] = (val | (low_byte << 4));
              // Are we at the checksum byte ?
              if ((bytes_read >> 1) != TAG_LEN) {
                // Checksum is XOR              
                checksum ^= tag_code[bytes_read >> 1];
              }
            } 
            else {
              // This is the other part of the hex value
              low_byte = val;
            }

            bytes_read += 1;
          }
        }

        //println("total bytes read = " + bytes_read);

        // Read Succesfull
        if (bytes_read >= RFID_MSG_LEN) {
          toggleActiveTag(tag_code);
        } 
        else {
          println("Unsuccesful read, bytes read = " + bytes_read);
        }
      }
    }
  }
}

