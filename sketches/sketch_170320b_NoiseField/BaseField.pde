
class BaseField {
  int res;
  int cols;
  int rows;
  PVector[][] field;
  PVector noiseVel;
  float noiseVelFloat;

  BaseField(int res_, float noiseVel_, float noiseTime_) {
    res   = res_;
    cols  = width/res;
    rows  = height/res;
    field = new PVector[cols][rows];
    noiseVel = new PVector(noiseVel_, noiseVel_, noiseTime_);
    noiseVelFloat = noiseVel_;
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