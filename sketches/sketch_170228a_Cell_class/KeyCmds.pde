void keyPressed() {
  
  //// RESET THE SCENE /////////
  background(0);
  stroke(0, 255);
  fill(255, 255);
  strokeWeight(1);
  //////////////////////////////
  
  ///// TOGGLE SHOWFIELD ///////
  if (key == ' ') {
    showField = !showField;
  }
  //////////////////////////////
  

  //// FIELD SWITCHER /////////
  // convert ascii code to its associated int such that key '9' is '9' and not 57
  int i = int(key)-48;
  println(i);
  // switch screens
  if (i >= 0 || i < 10) {
    fieldSwitch = i;
  }
  //// END FIELD SWITCH
  ///////////////////////////////
}


void mousePressed() {
 
}


void showInstructions() {
  println("--keyboard controls--");
  println("toggle showField: space bar");
  println();
  println("Switch screens:");
  println("1: noise field: static");
  println("2: noise field: animated");
  println("3: noise field: square rotation");
  println("4: noise field: red vehicles");
  println();
  println("5: refImage field: static");
  println("6: refImage field: square rotation");
  println("7: refImage field: red vehicles");
  println();
  println("8: refImage feild: cells");
  println();
  println("default: display ref image");
}