import processing.serial.*;

Serial myPort;

int numValues = 3; // number of input values or sensors
// * change this to match how many values your Arduino is sending *

float[] values = new float[numValues];

import netP5.*;
import oscP5.*;

int valor;

OscP5 osc;
NetAddress supercollider;


void setup () {
  size(500, 500);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem


  osc = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);


  // List all the available serial ports:
  printArray(Serial.list());
  // First port [0] in serial list is usually Arduino, but *check every time*:
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() until you get a newline character:
  myPort.bufferUntil('\n');

  background(0);
  values[0] = 0;
  values[1] = 0;
}


void draw () {
  // draw the line:

  if (mouseY < 125 && mouseX < 250) {
    valor = 0;
  } 

  if (mouseY > 125 && mouseY < 250 && mouseX < 250) {
    valor = 1;
  }

  if (mouseY > 250 && mouseY < 375 && mouseX > 250) {
    valor = 2;
  }

  if (mouseY > 375 && mouseX > 250) {
    valor = 3;
  }


  OscMessage msg = new OscMessage("/playindex");
  msg.add(valor);
  msg.add(map(values[1], 0, 22, 1, 2));
  msg.add(map(values[1], 0, 22, 1, 0.5));
  osc.send(msg, supercollider);
  //println(inByte);
  //println(valor);

  background(0);
  
  print (values[0]); print ("  "); println (values[1]);
}



void serialEvent(Serial myPort) { 
  try {
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');
    //println("raw: \t" + inString); // <- uncomment this to debug serial input from Arduino

    if (inString != null) {
      // trim off any whitespace:
      inString = trim(inString);

      // split the string on the delimiters and convert the resulting substrings into an float array:
      values = float(splitTokens(inString, ", \t")); // delimiter can be comma space or tab

      // if the array has at least the # of elements as your # of sensors, you know
      //   you got the whole data packet.
      if (values.length >= numValues) {
        /* you can increment xPos here instead of in draw():
         xPos++;
         if (xPos > width) {
         xPos = 0;
         clearScreen = true;
         }
         */
      }
    }
  }
  catch(RuntimeException e) {
    // only if there is an error:
    e.printStackTrace();
  }
}
