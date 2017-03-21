
class NoiseField extends BaseField {

  PVector fieldNoise;
  PVector noiseOff;


  NoiseField(int res_) {
    super(res_);
   // fieldNoise = new PVector();
    //noiseOff   = new PVector(.1, .1,  .01);
  
  }

  void init() {
    noiseSeed((int)random(1138808));
    fieldNoise = new PVector(0,0,0);
    noiseOff   = new PVector(.01, .01, .01);
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(fieldNoise.x, fieldNoise.y, fieldNoise.z), 0, 1, -TWO_PI, TWO_PI);
        field[i][j] = new PVector(cos(theta), sin(theta));
        fieldNoise.y += noiseOff.y; 
      }
      fieldNoise.x += noiseOff.x;
    }
    fieldNoise.z += noiseOff.z;
  }
  
}