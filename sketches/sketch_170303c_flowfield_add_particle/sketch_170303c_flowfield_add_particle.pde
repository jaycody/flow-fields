/* jstephens - NOC gungfu - 2017_02
 flowfields - prep for ecpc project
 
 features:
 - Cell and Vehicle class with lookup methods for vector grid and ref image brightness
 - FlowField overload constructor when using reference image
 
 todo:
 - [x] add particle
 - [ ] particle system
 - [ ] vehicles and cells extend particle
 - [ ] add kinect
 - [ ] array of forces at lookup
 - [ ] Particle system for vehicles
 - [ ] Cell extends Vehicle?
 - [x] use the color variable when extracting pixel data for ref image
 - [x] Use a 3D vector to track x,y,z noise values
 - [x] flowfield: cell vector mapped to brightness of ref image
 - [] flowfield: cell vector points to brightness neighbor cell
 - [x] Vehicle movement according to lookup field for ref image
 - [] Vehicle movement toward brightest of surrounding pixels
 - [] Use video/depth for reference image
 - [x] update vehicle class for reynolds behaviors (applyForce method, etc)
 - [] FlowFieldSystem class that combines the field sources into lookup table of PVector array at each cell
 - a 2D array of arrays. not sure how that looks. 
 - ArrayList[][] allFields = new ArrayList[cols][rows] ?? something like that
 - [] VehicleSystem class so we can let lose the real power of this thing
 - [] Inheritance optimization (eg Cell inherits Vehicle), FlowFieldDepth inherits FlowField
 */

import java.util.*;
////////// GLOBALS ///////////////
FlowField            grid;
FlowField            refImageGrid;
PImage refImg;
int gridResolution   = 25;
boolean showField    = true;
boolean switchField  = false;
int fieldSwitch;

Particle             particle;
ArrayList<Particle>  particles;
int totalParticles   = 100;

ArrayList<Vehicle>   vehicles;
int totalVehicles    = 50;
boolean alignToField = true;

ArrayList<Cell>      cells;
int totalCells       = 2000;
///////// END GLOBALS ////////////
//////////////////////////////////


void setup() {
  size(1024, 768); 
  //rectMode(CENTER);
  initialize();
}

void draw() {
  if(switchField) switchFields();

  
  for (int i = particles.size()-1; i > 0; i--){
    Particle p = particles.get(i);
    p.run();
    if (p.isDead()){
      //particles.remove(i);
      p = new Particle(new PVector(random(width), random(height*.3)));
      particles.remove(i);
      particles.add(p);
    }
  }
  
  particle.run();
  if (particle.isDead()) {
    particle = new Particle(new PVector(random(width), random(height*.3)));
  }
  if (mousePressed){
    particle = new Particle(new PVector(random(width), random(height*.3)));
  }
  
  
}


//////// INITIAL SETUP ///////////////////
void initialize() {
  smooth();
  refImg = loadImage("../../images/31.jpg");

  particle = new Particle(new PVector(random(width), random(height*.3)));
  particles = new ArrayList<Particle>();
  for (int i = 0; i < totalParticles; i++) {
   particles.add(new Particle(new PVector(random(width), random(height*.5)))); 
  }

  //// Initialize Fields
  grid = new FlowField(gridResolution);
  refImageGrid = new FlowField(gridResolution, refImg);

  //// Initialize Vehicles
  vehicles = new ArrayList<Vehicle>();
  for (int i = 0; i < totalVehicles; i++) {
    vehicles.add(new Vehicle(alignToField));
  }

  //// Initialize CELLS
  cells = new ArrayList<Cell>();
  for (int i = 0; i < totalCells; i++) {
    cells.add(new Cell(random(width), random(height), gridResolution));
  }

  showInstructions();
}