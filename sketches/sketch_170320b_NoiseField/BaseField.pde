
class BaseField {
  int res;
  int cols;
  int rows;
  PVector[][] field;

  BaseField(int res_) {
    res   = res_;
    cols  = width/res;
    rows  = height/res;
    field = new PVector[cols][rows];
    init();
  }

  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        field[i][j] = new PVector(1, 0);
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
        
        // draw vector arrow
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
}