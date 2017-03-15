
class Particle {

  PVector   loc;
  PVector   vel;
  PVector   acc;

  float     lifespan;
  color     fillColor;


  Particle(PVector birthPlace) {
    loc   = birthPlace.get();
    vel   = new PVector(random(-1, 1), -1);
    acc   = new PVector(0, .2);

    lifespan  = random(150, 255);
    fillColor = color (random(0, 255));
  }

  void run(PImage t) {
    update();
    //render(t);
    display();
  }

  void update() {
    vel.add(acc);
    loc.add(vel);
    
    lifespan -= 2;
  }

  void render(PImage t) {
    imageMode(CENTER);
    tint(lifespan);
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