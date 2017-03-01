void showZRects() {

  int[] depth = kinect.getRawDepth(); 
  int skip = 10;

  for (int x = 0; x < kinect.width; x+=skip) {
    for (int y = 0; y < kinect.height; y+=skip) {

      // convert the x,y cordinate into 1D index number
      int depthIndex = x + y * kinect.width;

      // extract raw depth value from the raw depth array
      int depthValue = depth[depthIndex];

      //if (depthValue > MIN_THRESH && depthValue < MAX_THRESH) {
        if (depthValue < MAX_THRESH) {
        
        float b = map(depthValue, MAX_THRESH, MIN_THRESH, 0, 255);
        
        float z = map(b, 0, 255, -255, 255);   

        fill(255-b);
        //fill(b*(b/255)*1.9,b); // the extra math here amplifies the brightness in a smaller range

        pushMatrix();
        translate(x * FS_SCALE_X, y * FS_SCALE_Y, z*2);
        //translate(x, y, z);
        rect(0, 0, skip+5, skip+5); //+(z*.1)
        popMatrix();

      }
    }
  }
}