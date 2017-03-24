
class NoiseField extends BaseField {

  float zoff;

  NoiseField(int res_, float noiseVel_, float noiseTime_) {
    super(res_, noiseVel_, noiseTime_);
  }

  void initVars() {
    // initialize time
    zoff = 0.0;
  }

  void initField() {
    println("Initializing NoiseField vectors:");
    println("\tres=" + res + " cols=" + cols + " rows=" + rows);
    println("\tnoiseVel(x, y, and time) " + noiseVel);
    noiseSeed((int)random(1138808));
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(xoff, yoff), 0, 1, -TWO_PI, TWO_PI);
        field[i][j] = new PVector(cos(theta), sin(theta));
        yoff += noiseVel.y;
      }
      xoff += noiseVel.x;
    }
  }

  void display() {
    update();
    if (showField) super.display();
  }

  void update() {
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(xoff, yoff, zoff), 0, 1, -TWO_PI, TWO_PI);
        field[i][j] = new PVector(cos(theta), sin(theta));
        yoff += noiseVel.y;
      }
      xoff += noiseVel.x;
    }
    zoff += noiseVel.z;
  }
  
  // lookup see super
}