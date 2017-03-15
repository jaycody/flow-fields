

class Vehicle extends Particle {

  // Vehicle specific attributes go here
  float ms;
  float mf;

  Vehicle(PVector startingPoint_, PImage pTex_, float ms_, float mf_) {
    super(startingPoint_, pTex_);
    vel   = new PVector(random(-1, 1), random(3));
    acc   = new PVector(0, -.01);
  
    ms = ms_;
    mf = mf_;
  }

  // inherit run

  // inherit update


  // override display
  void display() {
    fill(255, 0, 0);
    stroke(0);
    rect(loc.x, loc.y, 20, 20);
    println(mf);
  }
}