



class Particle {
  PVector loc;
  float   lifespan = 255;
  
  Particle(float x_, float y_) {
    loc = new PVector(x_, y_);
  }

  void display() { 
    fill(255, lifespan);
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