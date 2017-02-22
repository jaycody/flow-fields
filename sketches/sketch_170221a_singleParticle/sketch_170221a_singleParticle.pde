/* jstephens
 NOC gungfu - prep for ecpc project
 implement single particle from scratch
 */


Particle p;



void setup() {
  size(640, 480);
  p = new Particle(new PVector(width/2, height/2));
}




void draw() {
  p.run();

  if (p.isDead()) {
    p = new Particle(new PVector(random(width), random(height/2)));
  }
}