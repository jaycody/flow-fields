/* jstephens
 NOC gungfu - prep for ecpc project
 implement single particle from scratch
 */


Vehicle v;

PVector wind;


void setup() {
  size(640, 480);
  v     = new Vehicle(new PVector(width/2, height/2));
  wind  = new PVector(0, 0);
}




void draw() {
  v.applyForce(wind);
  v.run();
  
  wind.x = random(-1,1);
  wind.y = random(-1,1);

  
  if (v.isDead()) {
    v = new Vehicle(new PVector(random(width), random(height/2)));
  }
}