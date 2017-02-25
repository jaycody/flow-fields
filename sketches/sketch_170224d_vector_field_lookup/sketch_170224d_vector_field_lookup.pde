/* jstephens
 NOC gungfu - prep for ecpc project
 create simplest vector field 
 */

FlowField grid;
boolean showField;

PVector loc;
PVector cellVector;
PVector mouseLoc;

void setup() {
  size(1024, 768);
  showField = true;
  rectMode(CENTER);
  //size(640, 480);
  //background(0);
  grid = new FlowField(45);

  showInstructions();

  loc = new PVector(random(width), random(height));
  cellVector = new PVector(0, 0);
}



void draw() {
  //background(255);
  //fill(255);
  if (showField) grid.displayField();

  /*
  //////////////////////////////////
  // test lookup
  cellVector = grid.lookup(loc);
  triangle(0, 0, 30, 10, 0, 20);
  pushMatrix();
  translate(loc.x, loc.y);
  rotate(cellVector.heading2D());
  fill(255, 0, 0);
  triangle(0, 0, 30, 10, 0, 20);
  popMatrix();
  //////////////////////////////////
  */
  grid.squareRotate();
  fill(255,20);
  rect(width/2,height/2,width,height);
}












// toggle showField
void keyPressed() {
  if (key == ' ') {
    showField = !showField;
  }
}

void mousePressed() {
  grid.noiseInit();
  grid.squareRotate();
  println(loc.x, loc.y);
  println(cellVector.x);

  loc = new PVector(random(width), random(height));
}

void showInstructions() {
  println("--keyboard controls--");
  println("toggle showField: space bar");
}