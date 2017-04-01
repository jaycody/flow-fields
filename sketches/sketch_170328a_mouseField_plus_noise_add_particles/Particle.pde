
class Particle {

  PVector loc;
  PVector vel;
  PVector acc;

  float   lifespan;
  color   fillColor;
 

  Particle(PVector birthPlace_) {

    loc   = birthPlace_.get();
    vel   = new PVector(random(-1, 1), -3);
    acc   = new PVector(0, .1);

    lifespan  = random(150, 255);
    fillColor = color (random(255),random(150,255),255);
  }

  void run() {
    update();
    display();
  }

  void update() {
    vel.add(acc);
    loc.add(vel);
    //lifespan -= 1;
    acc.mult(0);
  }

  void applyForce(PVector f) {
    acc.add(f);
  }

  // send it off to the vehicle
  void seek(PVector target) {      // vehicle inherits and updates
  }
  
  /*
  void follow(BaseField field) {
    PVector desired = field.lookup(loc);
    // Scale it up by maxspeed
    desired.mult(maxspeed);
    // Steering is desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }
  */
  

  void display() { 
    fill(fillColor, lifespan);
    stroke(fillColor, lifespan);
    point(loc.x, loc.y);
    //ellipse(loc.x, loc.y, 20, 20);
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }
}