
class Particle {
  
  PVector loc;
  PVector vel;
  PVector acc;
  
  float   lifespan;
  color   fillColor;
  
  Particle(float x_, float y_) {
    loc   = new PVector(x_, y_);
    vel   = new PVector(random(-1,1), -1);
    acc   = new PVector(0, .2);
    
    lifespan  = random(150,255);
    fillColor = color (random(0,255));
  }

  void update() {
    loc.add(vel);
    vel.add(acc);
    
    lifespan -= 2;
  }
  
  void display() { 
    fill(fillColor, lifespan);
    stroke(fillColor, lifespan);
    ellipse(loc.x, loc.y, 20, 20);
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }
}