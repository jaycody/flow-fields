





class ParticleSystem {
  ArrayList<Particle> particles;
  PVector              origin;




  ParticleSystem(PVector position) {
    particles = new ArrayList<Particle>();
    origin    = position.get();
  }

  void display() {
    fill(0, 0, 255);
    rect(40, 40, 40, 40);
  }
}