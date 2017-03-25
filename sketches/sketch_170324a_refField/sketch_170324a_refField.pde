/* jstephens 
 FlowField gongfu 
 
 NEXT:
 [x] BaseField class  - FlowField base class
 [ ] RandomField extends BaseField
 [ ] NoiseField extends BaseField
 [ ] AttractorField extends BaseField
 [ ] RefImageField extends BaseField
 [ ] DepthField extends RefImageField
 [ ] MetaField class 
 - single field to manage all fields
 - is a 2D array of 1D arrays // Array[][] metafield
 - each array in the 2D array of arrays is a list of PVectors
 - the list of PVectors for each index in the 2D array describes each flowfield at that location
 - etc
 */

NoiseField noisefield;
ReferenceField referencefield;
PImage refImage;



boolean showField = true;
boolean testField = true;
FieldTester[] fieldtests;
int totalTestObjects = 100;

void setup() {
  size(1024, 768);
  smooth();
  
  refImage       = loadImage("wavemotion.jpg");
  noisefield     = new NoiseField(32, 0.05, 0.007);      // resolution, noiseVel, noiseTime
  referencefield = new ReferenceField(64, 0.09, 0.004, refImage);  // resolution, noiseVel, noiseTime

  initializeTestObjects();
  displayInstructions();
}

void draw() {
  background(255);
  
  if (testField) {
    referencefield.run(fieldtests);
  } else {
    referencefield.run();
  }
}


void initializeTestObjects() {
  fieldtests = new FieldTester[totalTestObjects];
  for (int i = 0; i < totalTestObjects; i++) {
    fieldtests[i] = new FieldTester();
  }
}

void displayInstructions() {
  println("\nkey commands:\n\tspacebar: toggle field");
  println("\t't': test field");
  
}

void keyPressed() {
  if (key == ' ') {
    showField = !showField;
    println("\nshowField is: " + showField);
    println("testField is: " + testField);
  }
  if (key == 't') {
    testField = !testField;
    println("\nshowField is: " + showField);
    println("testField is: " + testField);
  }
}