

class Vehicle extends Particle {

  // Vehicle specific attributes go here
  float ms;
  float mf;

  Vehicle(PVector startingPoint, float ms_, float mf_) {
    super(startingPoint);
    //vel   = new PVector();
   // acc   = new PVector();
    
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