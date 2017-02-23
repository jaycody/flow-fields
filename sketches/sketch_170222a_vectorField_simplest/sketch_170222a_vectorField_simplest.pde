/* jstephens
 NOC gungfu - prep for ecpc project
 implement single particle from scratch
 */


Vehicle v;

PVector wind;
boolean showVector;


void setup() {
  size(640, 480);
  showVector = true;
  v     = new Vehicle(new PVector(width/2, height/2), showVector);
  wind  = new PVector(0, 0);
}




void draw() {

  // regenerate target for seeker vehicle
  PVector mouse = new PVector(mouseX, mouseY);

  // update the wind  
  wind.x = random(-.01, .01);
  wind.y = random(-.01, .01);


  // display the target at mouse's loc
  ellipse(mouse.x, mouse.y, 40, 40);

  // apply the forces
  v.seek(mouse);
  v.applyForce(wind);
  v.run();


  if (v.isDead()) {
    v = new Vehicle(new PVector(random(width), random(height/2)), showVector);
  }
}

// toggle velocity vectors
void mouseClicked() {
  v.showVectorArrow = !v.showVectorArrow;
}