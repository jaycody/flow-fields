/**
 * NOISE INK
 * Created by Trent Brooks, http://www.trentbrooks.com
 * Applying different forces to perlin noise via optical flow 
 * generated from kinect depth image. 
 *
 * CREDIT
 * Special thanks to Daniel Shiffman for the openkinect libraries 
 * (https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing)
 * Generative Gestaltung (http://www.generative-gestaltung.de/) for 
 * perlin noise articles. Patricio Gonzalez Vivo ( http://www.patriciogonzalezvivo.com )
 * & Hidetoshi Shimodaira (shimo@is.titech.ac.jp) for Optical Flow example
 * (http://www.openprocessing.org/visuals/?visualID=10435). 
 * Memotv (http://www.memo.tv/msafluid_for_processing) for inspiration.
 * 
 * Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
 * http://creativecommons.org/licenses/by-sa/3.0/
 *
 *
 **/

class Particle {
  float angle, stepSize;
  float zNoise;

  float accFriction;  // = 0.9;//0.75; // set from manager now
  float accLimiter;   // = 0.5;

  int MIN_STEP = 4;
  int MAX_STEP = 8;

  PVector location;
  PVector prevLocation;
  PVector acceleration;
  PVector velocity;
  
  // for flowfield
  PVector steer;
  PVector desired;
  PVector flowFieldLocation;

  color clr = color(255);
  
  int life = 0;
  int lifeLimit = 400; // 400 = original

  float sat = 0.0f;

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
  }

  
  public boolean checkAlive() {
    return (life < lifeLimit);
  }

  public void update() {
    prevLocation = location.get();

    if (acceleration.mag() < accLimiter) {
      life++;
      angle = noise(location.x / particleManager.noiseScale, location.y / particleManager.noiseScale, zNoise);
      angle *= particleManager.noiseStrength;

//EXTRA CODE HERE
      
      velocity.x = cos(angle);
      velocity.y = sin(angle);
      velocity.mult(stepSize);
     
    }
    else {
      // normalise an invert particle position for lookup in flowfield
//      float x = (rearScreenProject ? width - location.x : location.x);
      float x = width-location.x;
      flowFieldLocation.x = norm(x, 0, width);
      flowFieldLocation.x *= kWidth; // - (test.x * wscreen);
      flowFieldLocation.y = norm(location.y, 0, height);
      flowFieldLocation.y *= kHeight;      
      
      desired = flowfield.lookup(flowFieldLocation);
      desired.x *= -1;// -1 = ORIGINAL

      steer = PVector.sub(desired, velocity);
      steer.limit(stepSize);  // Limit to maximum steering force      
      acceleration.add(steer);
    }

    acceleration.mult(accFriction);
    velocity.add(acceleration);   
    location.add(velocity);    

    // apply exponential (*=) friction or normal (+=) ? zNoise *= 1.02;//.95;//+= zNoiseVelocity;
    zNoise += particleManager.zNoiseVelocity;

    // slow down the Z noise??? Dissipative Force, viscosity
    //Friction Force = -c * (velocity unit vector) //stepSize = constrain(stepSize - .05, 0,10);
    //Viscous Force = -c * (velocity vector)
    stepSize *= particleManager.viscosity;
  }

  // 2-d render using processing P2D rendering context
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
  
 
// Render using openGL
// NOTE: not working in processing 2
// NOTE: NOT USED AT ALL
void renderGL(GL2 gl, float r, float g, float b, float a) {
    // scale r,g,b,a from 0..255 -> 0..1
    r = map(r, 0, 255, 0, 1);
    g = map(g, 0, 255, 0, 1);
    b = map(b, 0, 255, 0, 1);
    a = map(a, 0, 255, 0, 1);
    
    // drawing coordinates
    float startX = width-prevLocation.x-1;
    float startY = prevLocation.y;
    float endX   = width-location.x-1;
    float endY   = location.y;

    gl.glColor4f(r, g, b, a);
    gl.glVertex2f(startX, startY);
    gl.glVertex2f(endX, endY);
  }  
}

