
class MouseField extends NoiseField {

  PVector mouseLoc;

  MouseField(int res_, float noiseVal_, float noiseTime_) {
    super(res_, noiseVal_, noiseTime_);

    mouseLoc = new PVector();
  }


  void update() {
    super.update(); 
    mouseLoc.x = mouseX;
    mouseLoc.y = mouseY;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        PVector desired = PVector.sub(mouseLoc, cellLoc[i][j]);
        desired.setMag(1);
        field[i][j] = desired;
        //field[i][j].add(0, -1);
        //field[i][j].add(0, random(-1,1));
        //field[i][j] = PVector.sub(mouseLoc, cellLoc[i][j]);
        stroke(255/(i+1), 0, 0);
        fill(255-(255/(i+1)), 255/(i+1), 0);
        //ellipse(cellLoc[i][j].x, cellLoc[i][j].y, res, res);
        //ellipse(mouseLoc.x, mouseLoc.y, res, res);
      }
    }
  }
}