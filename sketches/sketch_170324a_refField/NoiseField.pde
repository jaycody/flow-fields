
class NoiseField extends BaseField {

  NoiseField(int res_, float noiseVel_, float noiseTime_) {
    super(res_, noiseVel_, noiseTime_);
  }

  void initVars() {
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

  void run() {
    update();
    if (showField) super.display();
  }

  void run(FieldTester[] fieldtests) {
    update();
    if (showField) super.display();

    for (int i = 0; i < fieldtests.length; i++) {
      fieldtests[i].test(this);
    }
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
}