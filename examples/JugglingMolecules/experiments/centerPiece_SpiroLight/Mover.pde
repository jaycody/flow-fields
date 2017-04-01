class Mover {

  // The Mover tracks location, velocity, and acceleration 
  PVector location;
  PVector velocity;
  PVector acceleration;
  // The Mover's maximum speed
  float topspeed;
  float accelerationScalar; // scale the magnitude of acceleration
  float rotationRate;
  float rotationAmount;
  int r;
  int g;
  int b;
  float rotateScalar;

  // angularMotion
  float angle = 0;
  float aVelocity = 0;
  float aAcceleration = 0;

  //noise for wondering
  PVector noff;

  Mover(float _topspeed, float _accelerationScalar, float _rotationRate, int _r, int _g, int _b) {
    // Start in the center
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);

    acceleration = new PVector();
    noff = new PVector(random(1000), random(1000));
    
    
    rotationAmount = 0;
    //topspeed = 5; original

    //randomized
    topspeed = random (7, 22);
    accelerationScalar = random(.2, .5);
    rotationRate = random (.03, .08);
    r = int(random(125, 255));
    g = int(random(125, 255));
    b = int(random(0, 255));
    rotateScalar = 0;

    //topspeed = _topspeed;
    //accelerationScalar = _accelerationScalar;
    // rotationRate = _rotationRate;
    //r = _r;
    //    g = _g;
    // b = _b;
  }

  void update() {
/*
    //**********Perlin Noise Following
    PVector mouse = new PVector(mouseX, mouseY);
    acceleration.x = map(noise(noff.x), 0, 1, -1, 1);
    acceleration.y = map(noise(noff.y), 0, 1, -1, 1);
    acceleration.mult(0.1);

    noff.add(0.01, 0.01, 0);

    acceleration.setMag(accelerationScalar);//original = .2

    // Velocity changes according to acceleration
    velocity.add(acceleration);
    // Limit the velocity by topspeed
    velocity.limit(topspeed);
    // Location changes by velocity
    location.add(velocity);
    // Stay on the screen
    location.x = constrain(location.x, 0, width-1);
    location.y = constrain(location.y, 0, height-1);
    //************************************
*/

    
    //*********FOLLOW MOUSE
     // Compute a vector that points from location to mouse
     PVector mouse = new PVector(mouseX, mouseY);
     PVector acceleration = PVector.sub(mouse, location);
     // Set magnitude of acceleration
     acceleration.setMag(accelerationScalar);//original = .2
     // Velocity changes according to acceleration
     velocity.add(acceleration);
     // Limit the velocity by topspeed
     velocity.limit(topspeed);
     // Location changes by velocity
     location.add(velocity);
     //********************************
     



    //angularMotion
    aAcceleration = acceleration.x / 10.0;
    aVelocity += aAcceleration;
    aVelocity = constrain(aVelocity, -0.1, 0.1);
    angle += abs(aVelocity);  //so circle continues to rotate
    rotationAmount = rotationAmount + rotationRate;

    acceleration.mult(0);
  }

  /*
  void updateAngularVelocity() {
   //angularMotion
   aAcceleration = acceleration.x / 10.0;
   aVelocity += aAcceleration;
   aVelocity = constrain(aVelocity, -0.1, 0.1);
   angle += abs(aVelocity);  //so circle continues to rotate
   rotationAmount = rotationAmount + rotationRate;
   
   acceleration.mult(0);
   }
   */


  void displayWithoutBackground() {
    r =  int(255*(abs(velocity.x)/topspeed));
    g = 255-int(255*(abs(velocity.y)/topspeed));
    b = int(255*(abs(location.y))/(height));

    println ("red = " + (r));
    println ("green = " + (g));
    println ("blue = " + (b));
    println ("rotationAmount = " + (rotationAmount));
    println ("rotateScalar = " + (rotateScalar));
    println ("rotationRate = " + (rotationRate));
    println ("angle = " + (angle));

    //*****1st Tier*******************
    strokeWeight(1);
    stroke(255, 0, 0);
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse(location.x, location.y, 10*abs(velocity.x), 5*topspeed);

    pushMatrix();

    //****2nd Tier********************
    //*******GREEN LINE
    pushMatrix(); // to isolate the rotation of the line
    translate(location.x, location.y);
    rotate(rotationAmount);
    stroke(0, 255, 0);
    strokeWeight(2);
    line(0, 0, 10*topspeed, 10*topspeed);

    //*******GREEN CIRCLE on GREEN LINE
    translate(10*topspeed, 10*topspeed); //translates are additive within a popMatrix();
    fill(0, 255, 100);
    ellipse(0, 0, 20, 20);

    //******Yellow Line from Green Circle on Gree Line
    pushMatrix();
    rotate(-rotationAmount*(1.6));
    rotate(-PI); // to place the line out of phase
    stroke(255, 255, 0);
    line (0, 0, 11*topspeed, 0);
    popMatrix();

    popMatrix();

    pushMatrix();
    translate(location.x, location.y);
    rotate(-rotationAmount*.75);
    stroke(0, 0, 255);
    line(0, 0, 5*topspeed+abs(velocity.y), 5*topspeed+abs(velocity.x));
    popMatrix();

    stroke(r, g, b);
    strokeWeight(abs(3*velocity.x)+abs(velocity.y)+3);
    //point(5*topspeed+abs(velocity.y), 5*topspeed+abs(velocity.x));

    //build another cycle********************
    pushMatrix();
    translate(5*topspeed+abs(velocity.y), 5*topspeed+abs(velocity.x));
    rotate(rotationAmount*.2);

    strokeWeight(2);
    stroke(0, 255, 00);
    // line(0, 0, velocity.y*topspeed, velocity.x*topspeed);

    pushStyle();
    blendMode(ADD);
    //blendMode(SCREEN);
    strokeWeight(abs(4*velocity.y)+5);
    stroke(b, r, g);
    // point(6*topspeed+abs(velocity.y), 6*topspeed+abs(velocity.x));
    popStyle();
    //****************************************


    // another branch
    pushMatrix();
    strokeWeight(3*velocity.x+7);
    stroke(g, b, r);
    translate(6*topspeed+velocity.y, 6*topspeed+velocity.x);
    rotateScalar = map(abs(velocity.y), 0, topspeed, 0, 1);
    //rotationAmount = rotateScalar+rotationAmount;

    // rotate(-(rotationAmount*rotateScalar));
    //line(0, 0, 20, 20);
    //point(topspeed+6*abs(velocity.x), topspeed+6*abs(velocity.y));

    /*
    // ***Adding a sphere
     pushMatrix();
     translate(width/2,height/2,100);
     pushStyle();
     fill(0, 0, 255);
     blendMode(ADD);
     lights();
     sphere(50);
     popStyle();
     popMatrix();
     //************************
     */

    popMatrix();
    popMatrix();
    popMatrix();
  }
}

