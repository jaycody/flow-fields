class FlowField {

  PVector[][] field;
  int cols;
  int rows;
  int resolution;

  float arrowsize = 4;
  float grow = 0.0;
  float speed = .51;

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
        //line(0, 0, resolution/2, 0);
        
        popMatrix();
        
        drawVector(field[i][j], i, j);
      }
    }
  }

  void display() {
    //translate(width/2, height/2);
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        drawVector(field[i][j], i, j);
        //line(i*resolution, j*resolution, i*resolution + resolution/2, j*resolution+resolution/2);
        //rect(i * resolution, j * resolution, resolution/2, resolution/2);
      }
    }
  }

  void drawVector(PVector v, int i_, int j_) {
    speed = map(mouseX,0,width,.00001,1);
    float x = i_ * resolution;
    float y = j_ * resolution;
    //////////
    float theta = map(i_+j_, 0, cols+rows, -TWO_PI, TWO_PI);
    float alpha = map(i_+j_, 0, cols+rows, -255, 255);
    float radius = map(alpha, -255, 255, -20, 40);
    //stroke(255);
    //noFill();
    stroke(alpha, 255-alpha);
    fill(alpha, alpha-255);
   /////////////////
    
    pushMatrix();
    translate(x, y);
    //rotate(v.heading2D());
    rotate(grow*sin(theta));
    
    //rect(0, 0, (resolution*theta+radius*2+resolution)/cos(theta), (resolution*theta+radius*2+resolution)/sin(theta));
    
    rect(0, 0, resolution*theta+radius*2+(resolution*cos(theta)), resolution*theta+radius*2+(resolution*sin(theta)));
    
    rect(0, 0, resolution*theta+radius*2+resolution, resolution*theta+radius*2+resolution);
    //rect(0, 0, 60*v.x+radius*theta, 60*v.y+radius);
    
    //ellipse(0,0, theta*25, theta*25);
    
    popMatrix();
    //translate(0,0);
    //translate(width/2, height/2);
    //rotate(grow);
    //rotate(v.heading2D());
    //translate(0,0);
    grow += speed;
    //speed +=speed;
  }
}