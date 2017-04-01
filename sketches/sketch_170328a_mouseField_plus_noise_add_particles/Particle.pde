
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


/*
///////// FROM InkTouchOSC //////////

  public Particle(float x,float y, float noiseZ) {
    stepSize = random(MIN_STEP, MAX_STEP);

    location = new PVector(x,y);
    prevLocation = location.get();
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    flowFieldLocation = new PVector(0, 0);
    
    // adds zNoise incrementally so doesn't start in same position
    zNoise = noiseZ;
  }


  // resets particle with new origin and velocitys
  public void reset(float x,float y,float noiseZ, float dx, float dy) {
    stepSize = random(MIN_STEP, MAX_STEP);

    location.x = prevLocation.x = x;
    location.y = prevLocation.y = y;
    acceleration.x = dx;//-2;
    acceleration.y = dy;
    life = 0;
    
    zNoise = noiseZ;
    
    int r = (int) map(x, 0, width, 0, 255);
    int g = (int) map(y, 0, width, 0, 255);
    int b = (int) map(x+y, 0, width+height, 0, 255);
    clr = color(r,g,b);
  } // 2-d render using processing P2D rendering context
  // r,g,b,a are floats from 0..255
  void render(float r, float g, float b, float a) {
      // drawing coordinates
//      float startX = (rearScreenProject ? width - (prevLocation.x-1) : (prevLocation.x-1)); 
//      float endX   = (rearScreenProject ? width - (location.x-1)     : (location.x-1));
      float startX = prevLocation.x;
      float endX   = location.x;
      float startY = prevLocation.y;
      float endY   = location.y;
      stroke(r, g, b, a);
      line(startX, startY, endX, endY);
  }
  
  */