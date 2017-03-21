
class NoiseField extends BaseField {

  PVector fieldNoise;
  PVector noiseOff;


  NoiseField(int res_) {
    super(res_);
    
    fieldNoise = new PVector(0.0,0.0);
    noiseOff   = new PVector(.01, .01);
    
    initNoise();
  
  }

  void initNoise() {
    println("cols=" + cols);
    println("rows=" + rows);
    //noiseSeed((int)random(1138808));
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        //println("fieldNoise.x=" + fieldNoise.x);
        float theta = map(noise(fieldNoise.x, fieldNoise.y), 0, 1, -TWO_PI, TWO_PI);
        //field[i][j] = PVector.fromAngle(theta);
        field[i][j] = new PVector(cos(theta), sin(theta));
        
        fieldNoise.y += noiseOff.y; 
      }
      fieldNoise.x += noiseOff.x;
    }
  }
  
  
  
}