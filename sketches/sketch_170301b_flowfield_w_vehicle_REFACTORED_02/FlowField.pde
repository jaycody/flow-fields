class FlowField {

  PVector[][] field;
  PVector perlinVelocity;
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

  ///// ref image
  PImage img;
  float[][] brightField; //2D array of brightness values from ref image for lookup
  color[][] colorField;  //2D array of color values taken from reference image
  //////////////////////////////////////////////////

  FlowField(int r) {
    resolution =  r;
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];
    perlinVelocity = new PVector(0.1, 0.1, 0.01);

    //// rotating cell
    squareLoc = new PVector(0, 0);
    squareRot = new PVector(0, 0);
    rot = 0.0;
    speed = 0.01;
    ///////////////////

    //// ref image
    img = loadImage("../../images/31.jpg");
    brightField = new float[cols][rows];
    colorField = new color[cols][rows];
    init();
  }

  // overload the constructor. I'm sure inheritence would be useful in here somewhere
  FlowField(int r, PImage img_) {
    resolution =  r;
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];
    perlinVelocity = new PVector(0.1, 0.1, 0.01);

    //// rotating cell
    squareLoc = new PVector(0, 0);
    squareRot = new PVector(0, 0);
    rot = 0.0;
    speed = 0.01;
    ///////////////////

    //// ref image
    img = img_;
    brightField = new float[cols][rows]; // store ref image brightness in 2D
    colorField  = new color[cols][rows]; // 
    initRefImage();
  }
  //////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////
  //////  STATIC FIELDS ////////////////////
  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        //// VECTOR FROM: CELL LOCATION
        float theta = map(i+j, 0, cols+rows, -TWO_PI, TWO_PI);
        field[i][j]   = new PVector(cos(theta), sin(theta));
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
  
  void initRefImage() {
    img.loadPixels();
    for (int i = 0; i < cols; i++) {
      for (int j=0; j < rows; j++) {

        //// VECTOR FROM: REF IMAGE
        int x = i * resolution;
        int y = j * resolution;
        int index = x + y * img.width;

        float b = brightness(img.pixels[index]);
        brightField[i][j] = b;

        color c = img.pixels[index];
        colorField[i][j]  = c;

        float theta = map(b, 0, 255, -TWO_PI, TWO_PI);
        field[i][j]   = new PVector(cos(theta), sin(theta));
      }
    }
  }

  void displayRefImage() {
    image(img, 0, 0, width, height);
  }

  //////// END STATIC FIELDS //////////////////////
  //////////////////////////////////////////////////////////////////


  /////// Animate PERLIN in Z-dimension at every frame
  void updateField() {
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j=0; j<rows; j++) {
        //// UPDATE VECTOR WITH: 3RD NOISE ZOFFSET ADDED TO LOCATTION
        float theta = map(noise(xoff, yoff, zoff), 0, 1, 0, TWO_PI);
        field[i][j]   = PVector.fromAngle(theta);
        yoff += perlinVelocity.y;
      }
      xoff += perlinVelocity.x;
    }
    zoff += perlinVelocity.z;
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

  /////////////////////////////////////////////////////////////////////////////
  ////// LOOKUP METHODS ///////////////////////////
  /* allows vehicles to ask this flowfield for: 
   - a vector at a particular x,y location
   - or the brightness of this fields ref image at an x.y. location
   1. derive cell's [col][row] location from vehicle's (x,y) screen location
   2. constrain the col row to the grid boundary
   */
  PVector lookup(PVector vehicleLocation) { 
    int column = int(constrain(vehicleLocation.x/resolution, 0, cols-1));
    int row    = int(constrain(vehicleLocation.y/resolution, 0, rows-1));
    return field[column][row].get();                  // use .get() to return a COPY
  }

  float lookupBrightness(PVector vehicleLocation) { 
    int column = int(constrain(vehicleLocation.x/resolution, 0, cols-1));
    int row    = int(constrain(vehicleLocation.y/resolution, 0, rows-1));
    return brightField[column][row];
  }

  color lookupColor(PVector vehicleLocation) { 
    int column = int(constrain(vehicleLocation.x/resolution, 0, cols-1));
    int row    = int(constrain(vehicleLocation.y/resolution, 0, rows-1));
    return colorField[column][row];
  }
  ///////// END LOOKUPS /////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////
  // experiment that I just couldn't bring myself to move
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

        ////fill option:01
        //stroke(255-255*cos(theta), strokeTheta);

        ////fill option:02
        // fill(strokeTheta, strokeTheta/theta);
        //stroke(255-strokeTheta, strokeTheta);

        ////fill option:03
        fill(strokeTheta*theta/22, strokeTheta*.4);
        stroke(strokeTheta*radius+20, (255*(strokeTheta/255)));
        strokeWeight(map(theta, -PI, PI, 2, 4));

        pushMatrix(); 
        translate(squareLoc.x, squareLoc.y);

        //rotate options
        //rotate(theta);
        rotate(((theta*.5)*rot)+i);

        //rect options
        //rect(0,0, radius, radius);
        //rect(0, 0, radius*cos(theta)*3, radius*sin(theta)*3);
        //rect(0, 0, (strokeTheta*cos(theta))*theta*2, ((strokeTheta*sin(theta)))*theta*3);
        rect(0, 0, (radius*cos(theta))*theta, (radius*sin(theta))*theta*1.2);

        popMatrix();
      }
    }
    rot += speed;
  }
}