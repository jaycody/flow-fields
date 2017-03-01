/* jstephens
 NOC gungfu - prep for ecpc project
 create simplest vector field 
 */

FlowField grid;
Vehicle vehicle;
ArrayList<Vehicle> vehicles;
int totalVehicles = 1000;

int gridResolution;
boolean showField;

PVector loc;
PVector cellVector;
PVector mouseLoc;

void setup() {
  size(1024, 768);
  rectMode(CENTER);

  showField = false;
  gridResolution = 50;

  grid = new FlowField(gridResolution);
  vehicle = new Vehicle();

  //totalVehicles = 10;
  vehicles = new ArrayList<Vehicle>();
  for (int i = 0; i < totalVehicles; i++) {
    vehicles.add(new Vehicle());
  }


  showInstructions();

  loc = new PVector(random(width), random(height));
  cellVector = new PVector(0, 0);
}



void draw() {
  //background(255);
  //fill(255);
  if (showField) grid.displayField();

  grid.updateField();
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


  fill(0, 15);
  //rect(0,0,width,height);
  rect(width/2, height/2, width, height);
  //grid.squareRotate();



  /////////////////////////////////
  //// VEHICLES
  vehicle.follow(grid);
  vehicle.display();

  for (Vehicle v : vehicles) {
    v.follow(grid);
    v.display();
  }
}












// toggle showField
void keyPressed() {
  if (key == ' ') {
    showField = !showField;
  }
}

void mousePressed() {
  grid.noiseInit();
  //grid.squareRotate();
  println(loc.x, loc.y);
  println(cellVector.x);

  loc = new PVector(random(width), random(height));
}

void showInstructions() {
  println("--keyboard controls--");
  println("toggle showField: space bar");
}