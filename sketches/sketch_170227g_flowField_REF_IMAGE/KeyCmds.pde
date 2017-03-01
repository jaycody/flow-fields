// toggle showField
void keyPressed() {
  background(0);
  stroke(0, 255);
  fill(255, 255);
  strokeWeight(1);

  if (key == ' ') {
    showField = !showField;
  }

  // convert ascii code to actual int
  int i = int(key)-48;
  println(i);

  // switch screens
  if (i >= 0 || i < 10) {
    fieldSwitch = i;
  }
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
  println("default: display ref image");
}