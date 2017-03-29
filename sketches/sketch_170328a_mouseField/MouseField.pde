
class MouseField extends NoiseField {

  PVector mouseLoc;

  MouseField(int res_, float noiseVal_, float noiseTime_) {
    super(res_, noiseVal_, noiseTime_);

    mouseLoc = new PVector();
  }

  /*
  void testMouseFieldClass() {
   fill(0,255, 0);
   ellipse(mouseX, mouseY, 90, 90);
   }
   */

  void update() {
    super.update(); 
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        fill(0, 255/(i+1), 0);
        ellipse((i*res)+45, j*res, 90, 90);
      }
    }
    fill(255,0,0);
    ellipse(75,75,150,150);
  }
}