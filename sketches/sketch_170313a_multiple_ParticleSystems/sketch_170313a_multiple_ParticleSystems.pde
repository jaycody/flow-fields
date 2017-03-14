/* jstephens 
 ParticleSystem gongfu 
 
 NEXT:
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

MultiVerse multiVerse;

void setup() {
  size(1024, 768);
  multiVerse = new MultiVerse();
}


void draw() {
  multiVerse.runSystems();
}

void mousePressed() {
  multiVerse.addSystem(int(random(100)));
}