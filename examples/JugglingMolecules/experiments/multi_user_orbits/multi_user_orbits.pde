/**
 * OmiCron-SpiroLight
 * Hypocycloids + Kinect + OmiCron
 *
 *********************
 * with help from
 * Gravitational Attraction (3D)
 * by Daniel Shiffman.  
 *********************
 */

// size of our window
int windowWidth = 1024;
int windowHeight = 768;

// Do we want to show or hide trails on each round?
// values: "show", "hide", "transparent"
// NOTE: transparent not working, due to opacity troubles
String trails = "hide";  

// Create many "suns"
SpiroCenter[] spiroCenters = new SpiroCenter[3];

// Constant for the zero-vector.  Don't change this!!!
PVector ZERO_VECTOR;

void setup() {
  ZERO_VECTOR = new PVector(0,0,0);
  
  size(windowWidth, windowHeight, P3D);
  // black background
  background(0);
  smooth();

  // Center of mass for 2 dancers
  spiroCenters[0] = new SpiroCenter(color(255,0,0));  // red
  spiroCenters[1] = new SpiroCenter(color(0,255,0));  // green
  spiroCenters[2] = new SpiroCenter(color(0,0,255));  // blue
}

void draw() {
  handleTrails();
  
  // Setup the scene
  sphereDetail(8);
  lights();

  float leftDelta = (width/3) - (width/12);
  float xDelta = mouseX/6;
  float topDelta = (height/3) - (height/6);
  float yDelta = mouseY/6;
  
  // red guy is tall
  float left = leftDelta;
  float top  = topDelta + yDelta;
  spiroCenters[0].display(left, top);
  
  // green guy is medium
  left = (leftDelta * 2);
  top  = (topDelta * 2) + xDelta; 
  spiroCenters[1].display(left, top);
  
  // blue guy is short
  left = (leftDelta * 3);
  top  = (topDelta * 3) - yDelta; 
  spiroCenters[2].display(left, top);
}

void handleTrails() {
  if (trails == "show") {
    // nothing to do -- we'll get trails by default    
  } else if (trails == "hide") {
    background(0);
  } else if (trails == "transparent") {
    //NOTE: NOT WORKING -- ALWAYS OBSCURES EVERYTHING
//      hint(DISABLE_DEPTH_TEST);
      pushStyle();
      fill(0,0,255,10);
      rect(0,0,width,height);
      popStyle();    
  }
}


