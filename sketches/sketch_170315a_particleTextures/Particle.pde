
class Particle {
  // shared by all Particle ancestors
  PVector   loc;
  PImage    pTex;
  
  // unique to particle class
  PVector   vel;
  PVector   acc;
  
  float     lifespan;
  color     fillColor;


  Particle(PVector birthPlace_, PImage pTex_) {
    // super() from Vehicle will call these first two
    loc   = birthPlace_.get();
    pTex  = pTex_;
    
    vel   = new PVector(random(-1, 1), -5);
    acc   = new PVector(0, .1);

    
    lifespan  = random(150, 255);
    fillColor = color (random(0, 255));
  }

  void run() {
    update();
    render(pTex);
    //display();
  }

  void update() {
    vel.add(acc);
    loc.add(vel);
    
    lifespan -= 2;
  }

  void render(PImage t) {
    imageMode(CENTER);
    //tint(lifespan);
    image(t, loc.x, loc.y);
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