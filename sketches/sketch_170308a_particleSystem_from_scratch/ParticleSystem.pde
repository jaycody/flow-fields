/* ParticleSystem class 
 for methods of the system as a whole
 */




class ParticleSystem {

  PVector             origin;
  ArrayList<Particle> particles;

  ParticleSystem(int initParticles) {
    particles = new ArrayList<Particle>();

    init(initParticles);
  }

  void init(int initAmount) {
    for (int i = 0; i < initAmount; i ++) {
      particles.add(new Particle(random(width), random(height)));
    }
  }

  void run() {
    for (Particle p : particles) {
      p.update();  
      p.display();
    }
  }
}