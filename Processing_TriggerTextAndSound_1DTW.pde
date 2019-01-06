// This demo triggers a text display with each new message
// Works with DTW
// Set number of DTW gestures and their namesBelow

//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
import java.awt.Robot;
import java.awt.event.KeyEvent;

OscP5 oscP5;
NetAddress dest;

String[] messageNames = {"/output_1", "/output_2", "/output_3","/output_4","/output_5" }; //message names for each DTW gesture type

//No need to edit:
PFont myFont, myBigFont;
final int myHeight = 400;
final int myWidth = 400;
int frameNum = 0;
int[] hues;
int[] textHues;
int numClasses;
int currentHue = 100;
int currentTextHue = 255;
String currentMessage = "Waiting...";

Robot robot = null;

void setup() {
  println("setup");
  try{robot = new Robot();}catch(Exception e){println("Robot not declared");}
  
  size(400,400, P3D);

  colorMode(HSB);
  smooth();

  numClasses = messageNames.length;
  hues = new int[numClasses];
  textHues = new int[numClasses];
  for (int i = 0; i < numClasses; i++) {
     hues[i] = (int)generateColor(i); 
     textHues[i] = (int)generateColor(i+1);
  }
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  String typeTag = "f";
  for (int i = 1; i < numClasses; i++) {
    typeTag += "f";
  }
  //myFont = loadFont("SansSerif-14.vlw");
  myFont = createFont("Arial", 14);
  myBigFont = createFont("Arial", 60);
}

void draw() {
  println("draw");
  frameRate(30);
  background(currentHue, 255, 255);
  drawText();
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
  println("received message");
    if (theOscMessage.checkAddrPattern(messageNames[0]) == true){
      println("received"+1);
      showMessage(1);
      robot.keyPress(KeyEvent.VK_SPACE);
      robot.keyRelease(KeyEvent.VK_SPACE);
    }
    else if (theOscMessage.checkAddrPattern(messageNames[1]) == true){
      println("received"+2);
      showMessage(2);
      robot.keyPress(KeyEvent.VK_KP_UP);
      robot.keyRelease(KeyEvent.VK_KP_UP);
    }
    else if (theOscMessage.checkAddrPattern(messageNames[2]) == true){
      println("received"+3);
      showMessage(3);
      robot.keyPress(KeyEvent.VK_KP_DOWN);
      robot.keyRelease(KeyEvent.VK_KP_DOWN);
    }
    else if (theOscMessage.checkAddrPattern(messageNames[3]) == true){
      println("received"+4);
      showMessage(4);
      robot.keyPress(KeyEvent.VK_LEFT);
      robot.keyRelease(KeyEvent.VK_LEFT);
    }
    else if (theOscMessage.checkAddrPattern(messageNames[4]) == true){
      println("received"+5);
      showMessage(5);
      robot.keyPress(KeyEvent.VK_KP_RIGHT);
      robot.keyRelease(KeyEvent.VK_KP_RIGHT);
    }
 
}

void showMessage(int i) {
    currentHue = hues[i];
    currentTextHue = textHues[i];
    currentMessage = messageNames[i];
}

//Write instructions to screen.
void drawText() {
    stroke(0);
    textFont(myFont);
    textAlign(LEFT, TOP); 
    fill(currentTextHue, 255, 255);

    text("Receives DTW messages from wekinator", 10, 10);
    text("Listening for " + numClasses + " DTW triggers:", 10, 30);
    for (int i= 0; i < messageNames.length; i++) {
       text("     " + messageNames[i], 10, 47+17*i); 
    }
    textFont(myBigFont);
    text(currentMessage, 20, 180);
}

float generateColor(int which) {
  float f = 100; 
  int i = which;
  
  if (i <= 0) {return 100;} 
  else {return (generateColor(which-1) + 1.61*255) %255; }
}
