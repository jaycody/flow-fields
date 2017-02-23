class Vehicle {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan, lifespeed;
  float r;            // vehicle's polyhedra edge
  float maxspeed;     // magnitude of desired velocity (stops from teleporting
  float maxability;   // limits the force vehicle can exert toward goal
  float scaleVectorArrow;
  boolean showVectorArrow;


  Vehicle(PVector birthCordinate, boolean showVector) {
    position     = birthCordinate.get();
    //velocity     = new PVector(random (-1, 1), -1);
    velocity     = new PVector(0, 0);
    acceleration = new PVector (0, 0);
    lifespan     = 255.0;
    lifespeed    = 1.0;
    r            = 6.0;
    maxspeed     = 6;      // defines magnitude of the desired vector
    maxability   = .09;    // constrains force vehicle can exert toward desire
    scaleVectorArrow = 25;
    showVectorArrow  = showVector;
  }

  void run() {
    update();
    display();
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);   // stops vehicle from teleporting to target
    position.add(velocity);
    acceleration.mult(0);       // zero out acceleration, prep to recalculate
    //lifespan -= lifespeed;
  }

  ///////////////////////////////////////////////
  // APPLY FORCE
  void applyForce(PVector force) {
    // add mass here too for F = MA
    acceleration.add(force);
  }
  ///////////////////////////////////////////////


  ///////////////////////////////////////////////
  //// STEERING FORCES --> steer = desired - velocity
  // SEEK
  void seek(PVector target) {
    // desired trajectory = target - current position
    PVector desired = PVector.sub(target, position);

    // stop teleportation! scale mag of desired vector to maxspeed
    desired.setMag(maxspeed);

    // steering force = desired trajectory - current velocity
    PVector steer = PVector.sub(desired, velocity);

    // force applied toward goal limited by max ability
    steer.limit(maxability);

    // apply this steering force to vehicle
    applyForce(steer);
  }
  //// END STEERING FORCES
  ///////////////////////////////////////////////


  void display() {
    ellipse(position.x, position.y, 10, 10);
    if (showVectorArrow) {
      drawVector(velocity, position, scaleVectorArrow);
    }
  }
  
  void drawVector(PVector vel, PVector loc, float scaleArrow) {
    float arrowsize = 4;
    stroke(0, 100);
    pushMatrix();
    translate(loc.x, loc.y);
    // vector heading function orients translate in direction of velocity
    rotate(vel.heading2D());
    // use velocity to scale the size of the velocity vector arrow length
    float len = vel.mag()*scaleArrow;
    // draw line with one end anchored to the center of translate screen
    line(0, 0, len, 0);
    line(len, 0, len-arrowsize, +arrowsize/2);
    line(len, 0, len-arrowsize, -arrowsize/2);
    popMatrix();
  }

  boolean isDead() {
    if (lifespan < 0.0 ) {
      return true;
    } else {
      return false;
    }
  }
}