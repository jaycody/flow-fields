/* jstephens 
 ParticleSystem gongfu 
 
 NEXT:
 [ ] add vehicle behavior SEEK (steering force = desired - current
 [ ] reduce the size of the new particle images and remove size contraints from  image(t, loc.x, loc.y, 30, 30);
 [x] add isEmpty() to check particle system similar to isDead() checks a particle
 [x] add vel & acc to particle class
 [x] jump to the ParticleSystem class
 [x] ArrayList of systems of systems
 [x] MultiVerse class
 [x] inheritance --> 
 [x] class Vehichle extends Particle
 [x] polymorphism
 
 NOTES:
 
 Inheritance:
 1. inherit everything
 2. add data or functionality
 3. override functions
 4. super
 */



MetaSystem meta;

void setup() {
  size(1024, 768, P2D);
  meta = new MetaSystem();
}

void draw() {
  fill(0,10);
  rect(0,0,width,height);
  meta.runAllSystems();
 
}