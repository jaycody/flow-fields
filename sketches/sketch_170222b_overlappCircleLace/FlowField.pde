class FlowField {

  PVector[][] force;
  int cols;
  int rows;
  int resolution;


  FlowField(int r) {
    resolution =  r;

    cols = width/resolution;
    rows = height/resolution;

    force = new PVector[cols][rows];

    init();
  }

  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        force[i][j] = new PVector(1,1);
        float alpha = map(i+j, 0, cols+rows, -355,255);
        float radius = map(alpha, -355, 255, -50, 50);
        //stroke(255);
        //noFill();
        stroke(255-alpha,255-alpha);
        fill(alpha,alpha);
        pushMatrix();
        translate(i*resolution, j*resolution);
        float theta = cos(force[i][j].x) + sin(force[i][j].y);
        theta = map(theta, 0,1, 0, TWO_PI);
        //rotate(theta);
        //line(0, 0, radius, radius);
        ellipse(0,0, 60*force[i][j].x+radius, 60*force[i][j].y+radius);
        popMatrix();
        //rect(i * resolution, j * resolution, resolution/2, resolution/2);
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