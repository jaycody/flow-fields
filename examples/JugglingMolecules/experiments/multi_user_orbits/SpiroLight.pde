// A class for an orbiting SpiroLight

class SpiroLight {
  
  // Basic physics model (location, velocity, acceleration, mass)
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  
  SpiroLight(float m, float x, float y, float z) {
    mass = m;
    location = new PVector(x,y,z);
    velocity = new PVector(1,0);   // Arbitrary starting velocity
    acceleration = new PVector(0,0);
  }
  
  // Newton's 2nd Law (F = M*A) applied
  void applyForce(PVector force) {
    acceleration.mult(0);       // Zero-out acceleration for next round
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }

  // Our motion algorithm (aka Euler Integration)
  void update() {
    velocity.add(acceleration); // Velocity changes according to acceleration
    location.add(velocity);     // Location changes according to velocity
  }

  // Draw the Planet
  void display() {
//    pushStyle();
//    noStroke();
//    fill(255);
    pushMatrix();
    translate(location.x,location.y,location.z);
    sphere(mass*8);
    popMatrix();
//    popStyle();
  }
}


