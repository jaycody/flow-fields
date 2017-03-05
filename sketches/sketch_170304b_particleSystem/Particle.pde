class Particle {

  PVector location;
  PVector velocity;
  PVector acceleration;


  float   lifespan;



  Particle(PVector l) {
    location     = l.get(); 
    velocity     = new PVector(random(-1, 1), -1);
    acceleration = new PVector(0, random(.01, .1));

    lifespan     = random(50,355);
  }

  void run() {
    update();
    display();
  }


  void update() {
    location.add(velocity);
    velocity.add(acceleration);

    lifespan -= 2.0;
  }

  void display() {
    stroke(0, lifespan);
    fill(150,0,150, lifespan);
    ellipse(location.x, location.y, 40, 40);
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }
}