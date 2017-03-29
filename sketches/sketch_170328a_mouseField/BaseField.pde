
class BaseField {
  int res;
  int cols;
  int rows;
  PVector[][] field;
  // ADD 2D array to track Cell location in the field
  //    to use when calculating a cells distance (and subsequent force vector from Mouse Location
  PVector[][] cellLoc; // ADD THIS to track each cells location in the field
  PVector noiseVel;
  float noiseVelFloat;
  float zoff;

  BaseField(int res_, float noiseVel_, float noiseTime_) {
    res      = res_;
    cols     = width/res;
    rows     = height/res;
    field    = new PVector[cols][rows];
    cellLoc  = new PVector[cols][rows];
    noiseVel = new PVector(noiseVel_, noiseVel_, noiseTime_);
    noiseVelFloat = noiseVel_;
    zoff  = 0.0;
    initVars();
    initField();
  }

  void initVars() {
    // child fields will need their variables initialized prior to initField()
  }

  void initField() {
    println("Initializing baseField:");
    println("\tresolution=" + res + "\n\tcols=" + cols + "\n\trows=" + rows);
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        field[i][j] = new PVector(-1, 0);
        cellLoc[i][j] = new PVector(i*res, j*res);
      }
    }
  }

  void display() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) { 

        float cellVectorScal    = res*.37;
        float arrowSize         = res*.12;
        float cellVectorHeading = field[i][j].heading2D();
        float cellVectorLength  = field[i][j].mag() * cellVectorScal;

        pushMatrix();

        // draw cell
        translate(res*i, res*j);
        stroke(255/(i+1),0, 150);
        fill(255,100);
        rect(0, 0, res, res);

        // draw vector arrow at center of cell 
        translate(res*.5, res*.5);
        rotate(cellVectorHeading);
        line(0, 0, cellVectorLength, 0);

        // draw arrow tip
        line(cellVectorLength, 0, cellVectorLength - arrowSize, -arrowSize);
        line(cellVectorLength, 0, cellVectorLength - arrowSize, arrowSize);

        popMatrix();
      }
    }
  }

  PVector lookup(PVector lookup) {
    int col = int(constrain(lookup.x/res, 0, cols-1));
    int row = int(constrain(lookup.y/res, 0, rows-1));
    return field[col][row].get();
  }
}