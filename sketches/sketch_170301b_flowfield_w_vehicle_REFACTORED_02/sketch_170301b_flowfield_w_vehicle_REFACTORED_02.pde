/* jstephens - NOC gungfu - 2017_02
 flowfields - prep for ecpc project
 
 features:
 - Cell and Vehicle class with lookup methods for vector grid and ref image brightness
 - FlowField overload constructor when using reference image
 
 todo:
 - [x] use the color variable when extracting pixel data for ref image
 - [x] Use a 3D vector to track x,y,z noise values
 - [x] flowfield: cell vector mapped to brightness of ref image
 - [] flowfield: cell vector points to brightness neighbor cell
 - [] Vehicle movement according to lookup field for ref image
 - [] Vehicle movement toward brightest of surrounding pixels
 - [] Use video/depth for reference image
 - [] update vehicle class for reynolds behaviors (applyForce method, etc)
 - [] FlowFieldSystem class that combines the field sources into lookup table of PVector array at each cell
 - a 2D array of arrays. not sure how that looks. 
 - ArrayList[][] allFields = new ArrayList[cols][rows] ?? something like that
 - [] VehicleSystem class so we can let lose the real power of this thing
 - [] Inheritance optimization (eg Cell inherits Vehicle), FlowFieldDepth inherits FlowField
 */

////////// GLOBALS ///////////////
FlowField grid;
FlowField refImageGrid;
PImage refImg;
int gridResolution = 25;
boolean showField = true;
int fieldSwitch;

ArrayList<Vehicle> vehicles;
int totalVehicles = 1000;

ArrayList<Cell> cells;
int totalCells  = 2000;
///////// END GLOBALS ////////////
//////////////////////////////////


void setup() {
  size(1024, 768); 
  initialize();
}

void draw() {
  switchFields();
}


//////// INITIAL SETUP ///////////////////
void initialize() {
  refImg = loadImage("../../images/31.jpg");

  //// Initialize Fields
  grid = new FlowField(gridResolution);
  refImageGrid = new FlowField(gridResolution, refImg);

  //// Initialize Vehicles
  vehicles = new ArrayList<Vehicle>();
  for (int i = 0; i < totalVehicles; i++) {
    vehicles.add(new Vehicle());
  }

  //// Initialize CELLS
  cells = new ArrayList<Cell>();
  for (int i = 0; i < totalCells; i++) {
    cells.add(new Cell(random(width), random(height), gridResolution));
  }

  showInstructions();
}