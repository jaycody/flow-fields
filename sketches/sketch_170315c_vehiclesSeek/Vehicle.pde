

class Vehicle extends Particle {

  // Vehicle specific attributes go here
  float ms;
  float mf;

  Vehicle(PVector startingPoint_, PImage pTex_, float ms_, float mf_) {
    super(startingPoint_, pTex_);
    vel   = new PVector(random(-1, 1), random(-3));
    acc   = new PVector();

    ms = ms_;
    mf = mf_;
  }

  // inherit run

  // modify update
  void update() {
    vel.add(acc);
    vel.limit(ms);      // limit velocity by max speed
    loc.add(vel);
    acc.mult(0);
    lifespan -= .5;
  }
  
  void seek(PVector target) {
    PVector desired = PVector.sub(target, loc);
    
    desired.setMag(ms);    // scaled to maxspeed
    
    // caculate steering w/o creating another temp PVector
    //       steering = desired - current
    desired.sub(vel);
    
    // limit to maxforce
    desired.limit(mf);
    
    applyForce(desired);
    
  }

  // override display
  void display() {
    fill(255, 0, 0);
    stroke(0);
    rect(loc.x, loc.y, 25, 25);
    println(mf);
  }
}