/*jason stephens::ITP
Movement Ink::
2011April::Intelligent Healing Spaces::Moving Image Project Development
2012May::evTherapy::Thesis

 * CREDIT::
 *  NOISE INK::Created by Trent Brooks, http://www.trentbrooks.com
 * Special thanks to Daniel Shiffman for the openkinect libraries 
 * Generative Gestaltung (http://www.generative-gestaltung.de/) for 
 * perlin noise articles. Patricio Gonzalez Vivo ( http://www.patriciogonzalezvivo.com )
 * & Hidetoshi Shimodaira (shimo@is.titech.ac.jp) for Optical Flow example
 * (http://www.openprocessing.org/visuals/?visualID=10435). 
 * Memotv (http://www.memo.tv/msafluid_for_processing) for inspiration. 
 * Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
 * http://creativecommons.org/licenses/by-sa/3.0/
 **/

/**
 * CONTROLS
 * space = toggle menu options for kinect
 * a,z = adjust minimum kinect depth
 * s,x = adjust maximum kinect depth
 * d,c = adjust minimum kinect depth (+/- 1);
 * f,v = adjust maximum kinect depth (+/- 1);
 **/
 /*::TODO::
*/


import oscP5.*;  // TouchOSC
import netP5.*;

OscP5 oscP5;

import processing.video.*;
import processing.opengl.*;
import javax.media.opengl.*;


ParticleManager particleManager;
Kinecter kinecter;
OpticalFlow flowfield;


// background color (black)
color bgColor = color(0);

// Amount to "dim" the background each round by applying partially opaque background
// TODO: make touchOSC setting for this
int overlayAlpha = 20;  // original = 10 fades background colour, 
                        // low numbers <10 aren't great for on screen because 
                        // it leaves color residue (it's ok when projected though).

//////////////////////////////
///// Screen setup
//////////////////////////////

// projector size
int windowWidth = 1280;
int windowHeight = 800;


//////////////////////////////
///// Master controls for what we're showing on the screen
//////////////////////////////

// set to true to show setup screen OVER the rest of the screen
// TODO: from OSC
boolean showSettings=false;

// set to true to show force lines
// TODO: from OSC
boolean showOpticalFlow=false;

// color for optical flow lines
// TODO: from OSC
color opticalFlowLineColor = color(255, 0, 0, 30);

// set to true to show particles
// TODO: from OSC
boolean showParticles=true;


// set to true to show the depth image
// TODO: from OSC
boolean showDepthImage = true;

// `tint` color for the depth image
color depthImageColor = color(128, 12);

// blend mode for the depth image
// TODO: from OSC
//int depthImageBlendMode = LIGHTEST;      // tracks white to body, but image too white
//int depthImageBlendMode = DARKEST;       // ghostly trail on body, dissolving into snakes
int depthImageBlendMode = DIFFERENCE;      // tracks black to body, 
//int depthImageBlendMode = DARKEST;
//int depthImageBlendMode = DARKEST;


//////////////////////////////
///// Kinect size
//////////////////////////////
// size of the kinect
int kWidth=640, kHeight = 480;     // use by optical flow and particles
float invKWidth = 1.0f/kWidth;     // inverse of screen dimensions
float invKHeight = 1.0f/kHeight;   // inverse of screen dimensions
float kToWindowWidth  = ((float) windowWidth)  * invKWidth;    // multiplier for kinect size to window size
float kToWindowHeight = ((float) windowHeight) * invKHeight;   // multiplier for kinect size to window size


//////////////////////////////
///// R,B,B,alpha for ALL particles, coming from TouchOSC
//////////////////////////////
float faderRed = 255;  //0-255
float faderGreen=255;  //0-255
float faderBlue=255;   //0-255
float faderAlpha=50;  //0-255

//////////////////////////////
///// Perlin noise generation, coming from TouchOSC
//////////////////////////////
// cloud variation, low values have long stretching clouds that move long distances,
//high values have detailed clouds that don't move outside smaller radius.
float noiseStrengthOSC= 100; //1-300;

// cloud strength multiplier,
//eg. multiplying low strength values makes clouds more detailed but move the same long distances.
float noiseScaleOSC = 100; //1-400

// turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time. 
float zNoiseVelocityOSC = .008; // .005 - .3


//////////////////////////////
///// How much particles pay attention to the noise, coming from TouchOSC
//////////////////////////////
//how much particle slows down in fluid environment
float viscosityOSC = .995;  //0-1  ???

// force to apply to input - mouse, touch etc.
float forceMultiOSC = 50;   //1-300

// how fast to return to the noise after force velocities
float accFrictionOSC = .075;  //.001-.999

// how fast to return to the noise after force velocities
float accLimiterOSC = .35;  // - .999


//////////////////////////////
///// creating particles
//////////////////////////////

// Maximum number of particles that can be active at once.
// More particles = more detail because less "recycling"
// Fewer particles = faster.
// TODO: OSC
int maxParticleCount = 20000;

// how many particles to emit when mouse/tuio blob move
int generateRateOSC = 10; //2-200

// random offset for particles emitted, so they don't all appear in the same place
float generateSpreadOSC = 20; //1-50

// Should all particles be the same color?
// (more efficient if so)
boolean individuallyColoredParticles = true;


//////////////////////////////
///// flowfield
//////////////////////////////

// resolution of the flow field.
// Smaller means more coarse flowfield = faster but less precise
// Larger means finer flowfield = slower but better tracking of edges
int flowfieldResolution = 15;  // 1..50 ?

// Amount of time in seconds between "averages" to compute the flow
float vectorPredictionTime = .5;

// velocity must exceed this to add/draw particles in the flow field
float minRegisterFlowVelocity = 20; //  2-10 ???




void setup() {
  // set up with OPENGL rendering context == faster
  size(windowWidth, windowHeight, OPENGL);

  // finding the right noise seed makes a difference!
  noiseSeed(26103); 
  
  // TouchOSC control bridge
  //start oscP5 listening for incoming messages at port 8000
  oscP5 = new OscP5(this, 8000);

  background(bgColor);
  frameRate(30);

  particleManager = new ParticleManager(maxParticleCount);

  // helper class for kinect
  kinecter = new Kinecter(this);

  // create the flowfield
  flowfield = new OpticalFlow(flowfieldResolution);
}



void draw() {
  pushStyle();
  pushMatrix();

  // partially fade the screen by drawing a semi-opaque rectangle over everything
  easyFade();

  // updates the kinect raw depth + kinecter.depthImg
  kinecter.updateKinectDepth(true);

  // update the optical flow vectors from the kinecter depth image 
  // NOTE: also draws the force vectors if `showOpticalFlow` is true
  flowfield.update();

  // show the flowfield particles
  if (showParticles) particleManager.updateAndRender();
    
  // draw the depth image over the particles
  if (showDepthImage) drawDepthImage();

  // display instructions for adjusting kinect depth image on top of everything else
  if (showSettings) drawInstructionScreen();


  popStyle();
  popMatrix();
}

void drawDepthImage() {
    pushStyle();
    pushMatrix();
//    tint(depthImageColor);
//    tint(256,128);
    scale(-1,1);  // reverse image to mirrored direction
    blendMode(depthImageBlendMode);
    image(kinecter.depthImg, 0, 0, -width, height);
    blendMode(BLEND);  // NOTE: things don't look good if you don't restore this!
    popMatrix();
    popStyle(); 
} 


// Partially fade the screen by drawing a translucent black rectangle over everything.
void easyFade() {
  fill(bgColor, overlayAlpha);
  noStroke();
  rect(0, 0, width, height);//fade background
}


