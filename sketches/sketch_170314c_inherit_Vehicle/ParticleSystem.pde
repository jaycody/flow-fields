
class ParticleSystem {

  ArrayList<Particle> particles;
  PVector             origin;
  PVector             deviate;
  
  PImage              pTexture;
  int                 pType;
  
  boolean             willReplaceExpired = true;

  ParticleSystem(int numOfParticles_, PVector origin_, PImage pTex_, int pType_) {
    
    particles = new ArrayList<Particle>();    // initialize ArrayList of particles
    origin    = origin_.get();                // get() makes a copy, pass by reference?
    deviate   = new PVector();
    
    pTexture  = pTex_;
    pType     = pType_;
    
    init(numOfParticles_);                    // initialize the System
    
  }

  void init(int numOfParticles) {
    for (int i = 0; i < numOfParticles; i ++) {
      addNewParticleToSystem();
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {  
      Particle p = particles.get(i);
      p.run(pTexture);

      removeReplaceParticleIfExpired(p, i);
    }
  }

  void removeReplaceParticleIfExpired(Particle p, int index) {
    if (p.isDead()) {
      particles.remove(index);                 // remove i, not p? p is a copy of i

      if (willReplaceExpired) addNewParticleToSystem();
    }
  }

  void addNewParticleToSystem() {
    deviate.x = origin.x + random(-25, 25);
    deviate.y = origin.y + random(-25, 25);
    if (pType == 0) particles.add(new Particle(deviate));
    if (pType == 1) particles.add(new Vehicle(deviate, random(2,5), random(1,2)));
  }

  // test whether the system is empty
  boolean isEmpty() {
    if (particles.size() <= 0) {
      return true;
    } else {
      return false;
    }
  }
}