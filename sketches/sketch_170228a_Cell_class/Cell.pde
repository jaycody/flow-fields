// Cell class for the shape at each cell

class Cell {
  PVector loc;
  PVector size;
  PVector fillVector;
  PVector gridVector;
  float theta             = 0;
  float thetaScale        = 0;
  float rotVelocity       = 0;
  float rotAcceleration   = 0;

  float sizeScale         = .1;
  float resolution;
  
  int cols, rows;

  Cell(float x_, float y_, int resolution_) {
    resolution = resolution_*sizeScale;
    loc = new PVector(x_, y_); 
    size= new PVector(resolution, resolution);
    fillVector = new PVector(0,255);
    gridVector = new PVector();

    cols = width/resolution_;
    rows = height/resolution_;
  }

  void display() {
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    rect(0, 0, size.x, size.y);
    popMatrix();
  }
   
  void align(FlowField flow){   
   gridVector = flow.lookup(loc);
   theta = gridVector.heading2D();
   thetaScale = map(theta, -PI, PI, 1, 1.5);
   //println(theta, sizeScale);
  
   size.mult(thetaScale);
   //size.x *= sizeScale;
   
   //size.add(gridVector);
  
    
  }

  void getBrightnessFrom(FlowField flow) {
    fillVector.x = flow.lookupBrightness(loc);
    //size.x = fillVector.x*.12;
    size.x = resolution*(map(fillVector.x, 0, 255, 2,8));
    size.y = size.x;
    //fillVector.x = map(fillVector.x, -PI, PI, 10, 255);
    fill(fillVector.x, 0, 0, fillVector.x);
    //size.mult(fillVector.x*.001);
  }
}
 