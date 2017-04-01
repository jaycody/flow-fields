

// Return a perline noise vector field, size of `rows` x `columns`.
PVector[][] makePerlinNoiseField(int rows, int cols) {
  //noiseSeed((int)random(10000));  // TODO???   
  PVector[][] field = new PVector[cols][rows];
  float xOffset = 0;
  for (int col = 0; col < cols; col++) {
    float yOffset = 0;
    for (int row = 0; row < rows; row++) {
      // Use perlin noise to get an angle between 0 and 2 PI
      float theta = map(noise(xOffset,yOffset),0,1,0,TWO_PI);
      // Polar to cartesian coordinate transformation to get x and y components of the vector
      field[col][row] = new PVector(cos(theta),sin(theta));
      yOffset += 0.1;
    }
    xOffset += 0.1;
  }
  return field;
}



/*
    // checks raw depth of kinect: if within certain depth range - color everything white, else black
    rawDepth = kinect.getRawDepth();
    for (int i=0; i < kWidth*kHeight; i++) {
      if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
        int greyScale = (int)map((float)rawDepth[i], minDepth, maxDepth, 255, 0);
        depthImg.pixels[i] = color(greyScale, greyScale, greyScale, 0);
        rawDepth[i] = 255;
      } 
      else {
        depthImg.pixels[i] = 0;  // transparent black
        rawDepth[i] = 0;
      }
    }
*/
