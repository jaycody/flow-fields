class FlowField {

  PVector[][] field;
  int cols;
  int rows;
  int resolution;
  float zoff = 0.0;  // 3rd dimension of noise
  float arrowsize = 4;

  ///// rotating cell
  PVector squareLoc;
  PVector squareRot;
  float rot, speed;
  ////////////////////

  FlowField(int r) {
    resolution =  r;
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];

    //// rotating cell
    squareLoc = new PVector(0, 0);
    squareRot = new PVector(0, 0);
    rot = 0.0;
    speed = 0.01;
    ///////////////////=

    init();
  }

  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {

        //// VECTOR FROM: CELL LOCATION
        float theta = map(i+j, 0, cols+rows, -TWO_PI, TWO_PI);
        field[i][j]   = new PVector(cos(theta), sin(theta));

        //// VECTOR FROM: RANDOM
        //field[i][j] = new PVector(random(-2, 2), random(-2, 2));
      }
    }
  }

  void noiseInit() {
    noiseSeed((int)random(10000));
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j=0; j<rows; j++) {

        //// VECTOR FROM: NOISE OFFSET FROM LOCATTION
        float theta = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
        field[i][j]   = new PVector(cos(theta), sin(theta));

        yoff += 0.1;
      }
      xoff += 0.1;
    }
  }

  /////// Animate by changing 3rd dimension of Perlin at every frame
  void updateField() {
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j=0; j<rows; j++) {

        //// UPDATE VECTOR WITH: 3RD NOISE ZOFFSET ADDED TO LOCATTION
        float theta = map(noise(xoff, yoff, zoff), 0, 1, 0, TWO_PI);
        field[i][j]   = PVector.fromAngle(theta);

        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.01;
  }





  /////////////////////////////////////////////////////////////////////////////
  void displayField() {
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        drawVector(field[i][j], i*resolution, j*resolution, resolution/2);
      }
    }
  }

  void drawVector(PVector v, float x, float y, float scaleArrow) {
    pushMatrix();
    translate(x, y);
    // draw cell
    rect(0, 0, resolution, resolution);
    // shift vector arrow to center of each cell
    translate(resolution/2, resolution/2);
    rotate(v.heading2D());        //rotate(v.heading2D()*rot);    
    // calc length of vector and draw it at the center of each cell
    float cellVectorLength = v.mag()*scaleArrow;    ///////DEBUG: optimize v.mag
    cellVectorLength = constrain(cellVectorLength, 0, resolution/2);
    // draw arrow
    line(0, 0, cellVectorLength, 0);
    line(cellVectorLength, 0, cellVectorLength/2, cellVectorLength/4);
    line(cellVectorLength, 0, cellVectorLength/2, -cellVectorLength/4);
    popMatrix();
  }
  /////////////////////////////////////////////////////////////////////////////



  PVector lookup(PVector vehicleLocation) {
    /* lookup() 
     * allows vehicles to ask the flowfield for the vector of a particular x,y location
     1. derive cell's [col][row] location from vehicle's (x,y) screen location
     2. constrain the col row to the grid boundary
     */
    int column = int(constrain(vehicleLocation.x/resolution, 0, cols-1));
    int row    = int(vehicleLocation.y/resolution);
    //column     = constrain(column, 0, cols-1);      // contrain to cell boundaries
    row        = constrain(row, 0, rows-1);
    return field[column][row].get();                  // use .get() to return a COPY
  }




  void squareRotate() {
    speed = map(mouseX, 0, width, .0001, 2);
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        squareLoc.x = i*resolution;
        squareLoc.y = j*resolution;
        squareRot = lookup(squareLoc);
        float theta  = squareRot.heading2D();
        float radius = map(theta, -PI, PI, 20, 70);
        float strokeTheta = map(theta, -PI, PI, 30, 12);
        //println(theta);

        //stroke(255-255*cos(theta), strokeTheta);

        ///////////
        // fill(strokeTheta, strokeTheta/theta);
        //stroke(255-strokeTheta, strokeTheta);
        ///////////

        fill(strokeTheta*theta/22, strokeTheta*.4);
        stroke(strokeTheta*radius+20, (255*(strokeTheta/255)));
        strokeWeight(map(theta, -PI, PI, 2, 4));
        pushMatrix(); 
        translate(squareLoc.x, squareLoc.y);
        //rotate(theta);
        float dir = (map(theta, -PI, PI, 1, -1));
        //if (dir<0) rot*=-1;
        //rotate((theta*.5)*rot);
        rotate(((theta*.5)*rot)+i);
        //rect(0,0, radius, radius);
        //rect(0, 0, radius*cos(theta)*3, radius*sin(theta)*3);
        //rect(0, 0, (strokeTheta*cos(theta))*theta*2, ((strokeTheta*sin(theta)))*theta*3);
        rect(0, 0, (radius*cos(theta))*theta, (radius*sin(theta))*theta*1.2);
        popMatrix();

        //drawVector(field[i][j], i*resolution, j*resolution, resolution/2);
      }
    }
    rot += speed;
  }
}









/*
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
 */