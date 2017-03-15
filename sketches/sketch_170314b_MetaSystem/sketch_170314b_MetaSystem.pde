/* jstephens 
 ParticleSystem gongfu 
 
 NEXT:
 [ ] add isEmpty() to check particle system similar to isDead() checks a particle
 [x] add vel & acc to particle class
 [x] jump to the ParticleSystem class
 [x] ArrayList of systems of systems
 [x] MultiVerse class
 [ ] inheritance --> 
 class Vehichle extends Particle
 class FeedbackMixer extends Mixer
 [ ] polymorphism
 
 NOTES:
 
 Inheritance:
 1. inherit everything
 2. add data or functionality
 3. override functions
 4. super
 */





MetaSystem meta;

void setup() {
  size(1024, 768);
  meta = new MetaSystem();
}

void draw() {
  meta.runAllSystems();
}