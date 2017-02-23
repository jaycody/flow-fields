class FlowField {

  PVector[][] field;
  int cols;
  int rows;
  int resolution;


  FlowField(int r) {
    resolution =  r;

    cols = width/resolution;
    rows = height/resolution;

    field = new PVector[cols][rows];

    init();
  }

  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        
        // calculate the field for this cell (i, j)
        float theta = map(i+j, 0, cols+rows, -TWO_PI, TWO_PI);
        //float theta = map(i, 0, cols, -TWO_PI, TWO_PI);
        
        // assign the field value to current cell's vector 
        //field[i][j] = new PVector(2, -2);
        field[i][j]   = new PVector(cos(theta), sin(theta));
        
        pushMatrix();
        translate(i*resolution, j*resolution);
        rotate(theta);
        line(0, 0, resolution/2, 0);
        popMatrix();
        
      }
    }
  }
  
  

  void display() {

    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        line(i*resolution, j*resolution, i*resolution + resolution/2, j*resolution+resolution/2);
        //rect(i * resolution, j * resolution, resolution/2, resolution/2);
      }
    }
  }
}