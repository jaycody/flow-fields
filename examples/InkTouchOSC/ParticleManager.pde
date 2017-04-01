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

class ParticleManager {
  Particle particles[];
  int particleCount; 
  int particleId = 0;

  // cloud variation, low values have long stretching clouds that move long distances,
  //high values have detailed clouds that don't move outside smaller radius.
  float noiseStrength;
  
  // cloud strength multiplier,
  //eg. multiplying low strength values makes clouds more detailed but move the same long distances.
  float noiseScale;   
  
  // turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time. 
  float zNoiseVelocity; 
  
  //how much particle slows down in fluid environment
  float viscosity;
  
  // force to apply to input - mouse, touch etc.
  float forceMultiplier;
  
  // how fast to return to the noise after force velocities
  float accFriction; 
  
  // how fast to return to the noise after force velocities
  float accLimiter; 
  
  // how many particles to emit when mouse/tuio blob move
  int generateRate; 
  
  // offset for particles emitted
  float generateSpread; 
  
  public ParticleManager(int numParticles) {
    particleCount = numParticles;
    particles =new Particle[particleCount];
    for (int i=0; i < particleCount; i++) {
      // initialise maximum particles
      particles[i] = new Particle(0, 0, i/float(particleCount)); // x, y, noiseZ
    }
  }

  public void updateAndRender() {
    // update PM drawing values w/their TouchOSC settings 
    noiseStrength   = noiseStrengthOSC;
    noiseScale      = noiseScaleOSC;
    zNoiseVelocity  = zNoiseVelocityOSC;
    viscosity       = viscosityOSC;
    forceMultiplier = forceMultiOSC;
    accFriction     = accFrictionOSC;
    accLimiter      = accLimiterOSC;    
    generateRate    = generateRateOSC;
    generateSpread  = generateSpreadOSC;
    
    // NOTE: doing pushStyle()/popStyle() on the outside of the loop makes this much much faster
    pushStyle();
    float red, green, blue, alpha;
    for (int i = 0; i < particleCount; i++) {
      Particle particle = particles[i]; 
      if (particle.checkAlive()) {
        particle.update();
        
        // adjust particlar color by R/G/B fader amount
        //   NOTE:  ">> 16 & 0xFF" bidness is fast color decomposition, see: http://processing.org/reference/red_.html
        if (individuallyColoredParticles) {
          color clr   = particle.clr;
          red   = (faderRed/255)   * (clr >> 16 & 0xFF);
          green = (faderGreen/255) * (clr >> 8 & 0xFF); 
          blue  = (faderBlue/255)  * (clr & 0xFF);
        } 
        // all particles same color -- faster
        else {
          red   = faderRed;
          green = faderGreen;
          blue  = faderBlue;
        }
        alpha = faderAlpha;
        particle.render(red, green, blue, alpha);
      }
    }
    popStyle();
  }

  // Add a bunch of particles to represent a new vector in the flow field
  public void addForce(float x, float y, float dx, float dy) {
    regenerateParticles(x * width, y * height, dx * forceMultiplier, dy * forceMultiplier);
  }

  // Update a set of particles based on
  public void regenerateParticles(float startX, float startY, float forceX, float forceY) {
    for (int i = 0; i < generateRate; i++) { 
      float originX = startX + random(-generateSpread, generateSpread);
      float originY = startY + random(-generateSpread, generateSpread);
      float noiseZ = particleId/float(particleCount);
      particles[particleId].reset(originX, originY, noiseZ, forceX, forceY);
      particles[particleId].accFriction = accFriction;
      particles[particleId].accLimiter = accLimiter;
      
      // increment counter -- go back to 0 if we're past the end
      particleId++;
      if (particleId >= particleCount) particleId = 0;
    }
  }

}

