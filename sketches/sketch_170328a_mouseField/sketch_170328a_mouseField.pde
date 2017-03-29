/* jstephens 
 FlowField gongfu 
 
 NEXT:
 [ ] mouseField
 [ ] update ref image sizes to match sketch size (to simplify the code for now)
 [ ] vector angle mapped to brightness
 [x] BaseField class  - FlowField base class
 [x] RandomField extends BaseField
 [x] NoiseField extends BaseField
 [ ] AttractorField extends BaseField
 [x] RefImageField extends NoiseField
 [ ] DepthField extends RefImageField
 [ ] MetaField class 
 - single field to manage all fields
 - is a 2D array of 1D arrays // Array[][] metafield
 - each array in the 2D array of arrays is a list of PVectors
 - the list of PVectors for each index in the 2D array describes each flowfield at that location
 - etc
 */

ReferenceField referencefield;
PImage[] refImages;

MouseField     mouseField;

boolean showField = true;
boolean testField = true;
FieldTester[] fieldtests;
int totalTestObjects = 100;

void setup() {
  size(1024, 768, P2D);
  smooth();
  
  refImages      = new PImage[2]; 
  refImages[0]   = loadImage("wavemotion.jpg");
  refImages[1]   = loadImage("kamehameha.jpg");
  
  // args = resolution, noiseVel, noiseTime, array of ref images
  referencefield = new ReferenceField(64, 0.09, 0.004, refImages); 
  mouseField     = new MouseField(128, 0.2, 0.01);
  
  setup_tests_and_instructions();
}

void draw() {
  background(255);
  
    //referencefield.run(fieldtests);
    //referencefield.run();
  
  mouseField.run();
  
}





/////////////////////////////////////////////////////////
///////  SETUP and TEST TOOLS
void setup_tests_and_instructions() {
  initializeTestObjects();
  displayInstructions();
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

void displayToggleStates() {
  println("\nshowField is: " + showField);
  println("testField is: " + testField);
}






/////////////////////////////////////////////////////////
///////  UI
void keyPressed() {
  if (key == ' ') {
    showField = !showField;
    displayToggleStates();
  }
  if (key == 't') {
    testField = !testField;
    displayToggleStates();
  }
}