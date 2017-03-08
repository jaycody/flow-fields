



class Particle {
  PVector loc;
  float   lifespan;
  
  Particle(float x_, float y_) {
    loc = new PVector(x_, y_);
  }

  void display() { 
    ellipse(loc.x, loc.y, 20, 20);
    lifespan -= 1;
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }
}