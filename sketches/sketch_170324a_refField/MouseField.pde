
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
  /*
  void update() {
     fill(0,255, 0);
    ellipse(mouseX, mouseY, 90, 90);
  }
  */
}