/**
* Very simple sketch that sends x,y values to Wekinator  
* Run Wekinator with 2 inputs (mouse x & y)
* Unlike the DTW Mouse Explorer, this does NOT also act as an output!
* You should use one of your own outputs.
**/

import controlP5.*;
import processing.video.*;
import oscP5.*;
import netP5.*;

int numPixelsOrig;
int numPixels;
boolean first = true;

int boxWidth = 20;
int boxHeight = 15;

int numHoriz = 640/boxWidth;
int numVert = 480/boxHeight;

color[] downPix = new color[numHoriz * numVert];

Capture video;
OscP5 oscP5;
NetAddress dest;
ControlP5 cp5;
PFont f, f2;
boolean isRecording = true; //mode
boolean isRecordingNow = true;

int areaTopX = 140;
int areaTopY = 70;
int areaWidth = 450;
int areaHeight = 390;

int currentClass = 1;

void setup() {
 // colorMode(HSB);
  size(640, 480, P2D);
  noStroke();

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,6449);
  dest = new NetAddress("127.0.0.1",6448);
  
  //Create the font
  f = createFont("Courier", 14);
  textFont(f);
  f2 = createFont("Courier", 40);
  textAlign(LEFT, TOP);
  
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 640, 480);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
   /* println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    } */

   video = new Capture(this, 640, 480);
    
    // Start capturing the images from the camera
    video.start();
    
    numPixelsOrig = video.width * video.height;
    loadPixels();
    noStroke();
  }
  
  createControls();
}

void createControls() {
  cp5 = new ControlP5(this);
  cp5.addToggle("isRecording")
     .setPosition(10,20)
     .setSize(75,20)
     .setValue(true)
     .setCaptionLabel("record/run")
     .setMode(ControlP5.SWITCH)
     ;
}

void drawText() {
  fill(255);
  textFont(f);
  if (isRecording) {
    text("Run Wekinator with 2 inputs (mouse x,y), 1 DTW output", 100, 20);
    text("Click and drag to record gesture #" + currentClass + " (press number to change)", 100, 35);
  } else {
    text("Click and drag to test", 100, 20);    
  }
  text ("This program does NOT act as an output; run with your own output!", 100, 50);  
}

void draw() {
  background(0);
   smooth();
   drawVideoFeed();
   drawText();
 
  if(mousePressed && frameCount % 2 == 0) {
    println("send downPix");
    sendOsc(downPix);
  }
}

/*
void drawClassifierArea() {
  stroke(255);
  noFill();
  rect(areaTopX, areaTopY, areaWidth, areaHeight, 7);
}
*/

void drawVideoFeed() {
  if (video.available() == true) {
    video.read();
    
    video.loadPixels(); // Make the pixels of video available
    /*for (int i = 0; i < numPixels; i++) {
      int x = i % video.width;
      int y = i / video.width;
      float xscl = (float) width / (float) video.width;
      float yscl = (float) height / (float) video.height;
      
      float gradient = diff(i, -1) + diff(i, +1) + diff(i, -video.width) + diff(i, video.width);
      fill(color(gradient, gradient, gradient));
      rect(x * xscl, y * yscl, xscl, yscl);
    } */
  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < 640; x += boxWidth) {
     for (int y = 0; y < 480; y += boxHeight) {
        float red = 0, green = 0, blue = 0;
        
        for (int i = 0; i < boxWidth; i++) {
           for (int j = 0; j < boxHeight; j++) {
              int index = (x + i) + (y + j) * 640;
              red += red(video.pixels[index]);
              green += green(video.pixels[index]);
              blue += blue(video.pixels[index]);
           } 
        }
       downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
      // downPix[boxNum] = color((float)red/tot, (float)green/tot, (float)blue/tot);
       fill(downPix[boxNum]);
       
       int index = x + 640*y;
       red += red(video.pixels[index]);
       green += green(video.pixels[index]);
       blue += blue(video.pixels[index]);
      // fill (color(red, green, blue));
       rect(x, y, boxWidth, boxHeight);
       boxNum++;
      /* if (first) {
         println(boxNum);
       } */
      } 
    }
  }
}

boolean inBounds(int x, int y) {
 if (x < areaTopX || y < areaTopY) {
    return false;
 }
 if (x > areaTopX + areaWidth || y > areaTopY + areaHeight) {
    return false;
 } 
 return true;
}


void mousePressed() {
  if (! inBounds(mouseX, mouseY)) {
    return;
  }
  if (isRecording) {
         println("recording");
     isRecordingNow = true;
     OscMessage msg = new OscMessage("/wekinator/control/startDtwRecording");
     msg.add(currentClass);
     oscP5.send(msg, dest);
  } else {
    println("running");
    OscMessage msg = new OscMessage("/wekinator/control/startRunning");
    oscP5.send(msg, dest);
    //sendOsc(downPix);
  }
}

void mouseReleased() {
  if (isRecordingNow) {
     isRecordingNow = false;
     OscMessage msg = new OscMessage("/wekinator/control/stopDtwRecording");
      oscP5.send(msg, dest);
  }
}

void keyPressed() {
  int keyIndex = -1;
  if (key >= '1' && key <= '9') {
    currentClass = key - '1' + 1;
  }
}

float diff(int p, int off) {
  if(p + off < 0 || p + off >= numPixels)
    return 0;
  return red(video.pixels[p+off]) - red(video.pixels[p]) +
         green(video.pixels[p+off]) - green(video.pixels[p]) +
         blue(video.pixels[p+off]) - blue(video.pixels[p]);
}

void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
 // msg.add(px);
   for (int i = 0; i < px.length; i++) {
      msg.add(float(px[i]/1000)); 
   }
  oscP5.send(msg, dest);
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
}
