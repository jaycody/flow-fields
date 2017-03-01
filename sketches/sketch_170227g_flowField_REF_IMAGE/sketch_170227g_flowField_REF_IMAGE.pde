/* jstephens
 NOC gungfu - prep for ecpc project
 create simplest vector field 
 */

FlowField grid;
Vehicle vehicle;
ArrayList<Vehicle> vehicles;
int totalVehicles = 1000;

FlowField refImageGrid;
PImage refImg;

int gridResolution;
boolean showField;
int fieldSwitch;

PVector loc;
PVector cellVector;
PVector mouseLoc;

void setup() {
  size(1024, 768);
  //rectMode(CENTER);

  showField = true;
  gridResolution = 25;
  refImg = loadImage("../../images/31.jpg");

  grid = new FlowField(gridResolution);
  refImageGrid = new FlowField(gridResolution, refImg);

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

  switch(fieldSwitch) {
    case 1:
      grid.displayField();
      break;
    case 2:
      grid.displayField();
      grid.updateField();
      break;
    case 3:
      grid.updateField();
      grid.squareRotate();
      break;
    case 4:
      grid.updateField();
      fill(0, 15);
      rect(0, 0, width, height);
      for (Vehicle v : vehicles) {
        v.follow(grid);
        v.display();
      }
      break;
    case 5:
      refImageGrid.displayField();
      break;
    case 6:
      refImageGrid.squareRotate();
      break;
    case 7:
      fill(0, 15);
      rect(0, 0, width, height);
      for (Vehicle v : vehicles) {
        v.follow(refImageGrid);
        v.getBrightnessFrom(refImageGrid);
        v.display();
      }
      break;
    default:
      image(refImg, 0, 0, width, height);
  }

  /*
  if (showField) grid.displayField();
   grid.updateField();
   */


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

  /*
  fill(0, 15);
   //rect(0,0,width,height);
   // rect(width/2, height/2, width, height);
   // grid.squareRotate();
   
   for (Vehicle v : vehicles) {
   v.follow(grid);
   v.display();
   }
   */
}