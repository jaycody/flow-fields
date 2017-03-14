
class MultiVerse {

  ArrayList<ParticleSystem> systems;
  PVector                   origin;

  MultiVerse() {
    systems = new ArrayList<ParticleSystem>();
    origin  = new PVector(mouseX, mouseY);
  }

  void runSystems() {
    for (int i = systems.size()-1; i > 0; i--) {
      ParticleSystem s = systems.get(i);
      s.run();
    }
  }

  void addSystem(int totalParticles) {
    origin.x = mouseX;
    origin.y = mouseY;
    systems.add(new ParticleSystem(totalParticles, origin));
  }
}