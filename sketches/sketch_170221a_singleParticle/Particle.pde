class Particle {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan, lifespeed;

  Particle(PVector birthCordinate) {
    position     = birthCordinate.get();
    velocity     = new PVector(random (-1, 1), -1);
    acceleration = new PVector (0, .01);
    lifespan     = 255.0;
    lifespeed    = 1.0;
  }

  void run() {
    update();
    display();
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= lifespeed;
  }

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