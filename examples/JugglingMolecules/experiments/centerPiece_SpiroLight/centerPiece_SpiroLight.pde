/**
 * CenterPiece_SpiroLight
 * jason stephens
 *
 *
 * from Acceleration with Vectors 
 * by Daniel Shiffman.  
 * 
 */

// A Mover object
Mover mover;
Mover mover1;

// follow path for spiro
//Walker w;


void setup() {
  size(displayWidth, displayHeight, P2D);
  background(0);
  smooth();
  mover = new Mover(4, .3, .07, 0, 255, 255);  // top speed, accelerationScalar, rotationRate, point color
  mover1 = new Mover(5, .3, .04, 255, 0, 130);

  // adding path for spiroLigt
  //w = new Walker();
}

void draw() {
  // background(0);
  // lights();

  blendMode(ADD);

  pushStyle();
  blendMode(BLEND);
  fill(0, 3);
  rect(0, 0, width, height);

  popStyle();


  pushStyle();
  blendMode(ADD);
  blendMode(REPLACE);
  // Update the location
  // mover.update();
  mover1.update();
//mover1.updateAngularVelocity();

  // Display the Mover Without Background and only the points showing
  //mover.displayWithoutBackground(); 
  mover1.displayWithoutBackground(); 
  popStyle();
}

