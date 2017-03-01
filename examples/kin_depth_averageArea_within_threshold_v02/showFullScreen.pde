void showFullScreen() {

  //FULL_img.loadPixels();

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  ////////////////////////////////////////////////////
  // setup for closest-point tracking via world record
  // int record = 2500;            // closest
  int record = kinect.height;   // or highest
  int rx = 0;
  int ry = 0;

  ////////////////////////////////////////////////////
  // setup for average area tracking
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;


  // define rect size and grid size
  int skip = 5;

  // loop through Kinect's 640x480 dimensions 
  for (int x = 0; x < kinect.width; x+=skip) {
    for (int y = 0; y < kinect.height; y+=skip) {

      // convert the x,y cordinate into 1D index number
      int depthIndex = x + y * kinect.width;

      // extract raw depth value from the raw depth array
      int depthValue = depth[depthIndex];

      // test pixel against depth threshold 
      if (depthValue > MIN_THRESH && depthValue < MAX_THRESH) {   

        float b = map(depthValue, MAX_THRESH, MIN_THRESH, 0, 300);
        color r = color(b, 0, 255-b);
        //fill(b);
        fill(r);

        rect(x * FS_SCALE_X, y*FS_SCALE_Y*1.1, skip*.9 * FS_SCALE_X, skip*.9 * FS_SCALE_Y);

        //FULL_img.pixels[depthIndex] = color(r);

        ////////////////////////////////////////////////////
        // accumulate number of pixels within range for average area tracking
        sumX += x;
        sumY += y;
        totalPixels++;
            
        ////////////////////////////////////////////////////
        // closest point : check record
        if (x < width*.7 && y < record) {
          record = y;
          //if (depthValue < record) {
          //record = depthValue;
          rx = x;
          ry = y;
        }
      } else {
        //KINECT_img.pixels[depthIndex] = color(0);
        //KINECT_img.pixels[depthIndex] = dImg.pixels[depthIndex];
      }
    }
  }
  //FULL_img.updatePixels();
  //image(FULL_img,0,0,width,height);

  // calc and draw center of average area
  float avgX = sumX / totalPixels;
  float avgY = sumY / totalPixels;
  fill(0,0,255);
  ellipse(avgX * FS_SCALE_X, avgY * FS_SCALE_Y, 55,55);

  // draw closest/highest point
  fill(0, 255, 0);
  ellipse(rx*FS_SCALE_X, ry*FS_SCALE_Y, 42, 42);
}