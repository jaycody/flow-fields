
class Particle {

  PVector loc;
  PVector vel;
  PVector acc;

  PImage  pTex;

  float   lifespan;
  color   fillColor;

  Particle(PVector birthPlace_, PImage pTex_) {

    loc   = birthPlace_.get();
    vel   = new PVector(random(-1, 1), -3);
    acc   = new PVector(0, .1);

    pTex  = pTex_;         // texture passed to particle constructor from PS object

    lifespan  = random(150, 255);
    fillColor = color (random(0, 255));
  }

  void run() {
    update();
    if (isMacMini) {
      display();
    } else {
      render(pTex);     // texture passed to particle constructor from PS object
    }
  }

  void update() {
    vel.add(acc);
    loc.add(vel);

    lifespan -= 1;
    acc.mult(0);
  }

  void applyForce(PVector f) {
    acc.add(f);
  }

  // send it off to the vehicle
  void seek(PVector target) {      // vehicle inherits and updates
  }

  void render(PImage t) {    
    imageMode(CENTER);
    //tint(lifespan);
    image(t, loc.x, loc.y);
    //image(t, loc.x, loc.y, 20, 20);  // <-- OPTIMIZE HERE by updating the actual dimensions of the png
  }

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