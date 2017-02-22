class Vehicle {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan, lifespeed;
  float r;            // vehicle's polyhedra edge
  float maxspeed;     // magnitude of desired velocity (stops from teleporting
  float maxforce;


  Vehicle(PVector birthCordinate) {
    position     = birthCordinate.get();
    //velocity     = new PVector(random (-1, 1), -1);
    velocity     = new PVector(0, 0);
    acceleration = new PVector (0, 0);
    lifespan     = 255.0;
    lifespeed    = 1.0;
    r            = 6.0;
    maxspeed     = 4;      // vehicle's ability to steer (
    maxforce     = 0.1;
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
    lifespan -= lifespeed;
  }

  ///////////////////////////////////////////////
  // APPLY FORCE
  void applyForce(PVector force) {
    // add mass here too for F = MA
    acceleration.add(force);
  }
  ///////////////////////////////////////////////
  
  
  ///////////////////////////////////////////////
  // STEERING FORCES
  
  
  

  void display() {
    ellipse(position.x, position.y, 10, 10);
  }

  boolean isDead() {
    if (lifespan < 0.0 ) {
      return true;
    } else {
      return false;
    }
  }
}