
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
        //float d = dist(mouseLoc.x, mouseLoc.y, cellLoc[i][j].x, cellLoc[i][j].y);
        //println(d);
        float mapDist   = map(desired.mag(), 0, width, .5, 1.9);
        //println(desired.mag());
        //float d = dist(
        desired.setMag(mapDist);
        field[i][j].add(desired);
        //field[i][j] = desired;
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