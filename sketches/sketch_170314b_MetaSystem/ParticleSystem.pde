
class ParticleSystem {

  ArrayList<Particle> particles;
  PVector             origin;
  boolean             willReplaceExpired = true;

  ParticleSystem(int numOfParticles_, PVector origin_) {
    particles = new ArrayList<Particle>();    // initialize ArrayList of particles
    origin    = origin_.get();                // get() makes a copy, pass by reference?

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
      p.update();
      p.display();

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
    particles.add(new Particle(origin.x + random(-25, 25), origin.y + random(-25, 25)));
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