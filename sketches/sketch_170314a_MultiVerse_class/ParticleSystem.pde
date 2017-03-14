
class ParticleSystem {

  PVector             origin;
  ArrayList<Particle> particles;

  ParticleSystem(int initParticles, PVector origin_) {
    origin    = origin_.get();
    particles = new ArrayList<Particle>();

    init(initParticles);
  }

  void init(int initAmount) {
    for (int i = 0; i < initAmount; i ++) {
      addNewParticleToSystem();
    }
  }

  void run() {
    for (int i = particles.size()-1; i > 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) {
        particles.remove(p);
        addNewParticleToSystem();
      }
    }
  }

  void addNewParticleToSystem() {
    particles.add(new Particle(origin.x + random(-25, 25), origin.y + random(-25, 25)));
  }
}