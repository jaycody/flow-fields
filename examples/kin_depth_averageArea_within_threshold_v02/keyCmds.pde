/* 
0 =48
1 =49
2 =50
3 =51
4 =52
*/

void keyPressed() {
  
  // convert ascii code to actual int
  int i = int(key)-48;
  println(i);
  
  // switch screens
  if (i >= 0 || i < 10) {
    currentScreen = i;
  }
  
  // toggle mouse calibration
  if (key == 'm') {
    calibrate_with_mouse = !calibrate_with_mouse;
  } 
}

void showInstructions() {
  
  println("FS_SCALE_X = " + FS_SCALE_X);
  println("FS_SCALE_Y = " + FS_SCALE_Y); 
  
  println("Switch screens:");
  println("1: 2D rects red --> blue");
  println("2: 3D rects greyscale");
  println("all other keys: toggle calibration view");

  
}