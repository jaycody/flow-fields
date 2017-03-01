void showCalibration() {

  CALIBRATION_img.loadPixels();

  // Get the raw depth as array of integers
  int[] rawDepth = kinect.getRawDepth();

  // use mouseX, mouseY to quickly establish thresholds
  if (calibrate_with_mouse) {
    MIN_THRESH = map(mouseX, 0, kinect.width, 0, 2048);
    MAX_THRESH = map(mouseY, 0, kinect.height, 0, 2048);
  }
  
  // use the image dimension to find the index
  for (int x = 0; x < kinect.width; x++) {
    for (int y = 0; y < kinect.height; y++) {

      int offset = x + y * kinect.width;
      int d = rawDepth[offset];

      // determine if it falls into threshold                     
      if (d > MIN_THRESH && d < MAX_THRESH) {   // subtracts a specific area for detection && x > 100 && y > 50) {

        CALIBRATION_img.pixels[offset] = color(255, 0, 150);
      } else {
        CALIBRATION_img.pixels[offset] = color(0);
      }
    }
  }

  CALIBRATION_img.updatePixels();
  image(CALIBRATION_img, 0, 0);

  displayMinMax();
}

///////////////////////////////////////////////
void displayMinMax() {
  fill(255);
  textSize(32);
  text("min: " + MIN_THRESH + "   max: " + MAX_THRESH, 10, 64);

  textSize(12);
  text("1-5: switch screens", 10, height*.93);
  text(" all other keys: toggle calibration view", 10, height*.95);
  text("   MouseX: adjust min threshold: " + MIN_THRESH, 10, height*.97);
  text("   MouseY: adjust max threshold: " + MAX_THRESH, 10, height*.99);
}