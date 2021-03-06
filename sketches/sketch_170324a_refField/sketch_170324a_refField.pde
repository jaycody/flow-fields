/* jstephens 
 FlowField gongfu 
 
 NEXT:
<<<<<<< HEAD
 [ ] RefImageField from ref image brightness
=======
 [ ] mouseField
 [ ] update ref image sizes to match sketch size (to simplify the code for now)
 [ ] vector angle mapped to brightness
>>>>>>> 224ddd3a8cb6bfbe17957d40ee13989a091d699c
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

boolean showField = false;
boolean testField = true;
FieldTester[] fieldtests;
int totalTestObjects = 500;

void setup() {
<<<<<<< HEAD
  fullScreen(1);
  //size(1920, 1080);
  //size(1024, 768);
  smooth();
  background(0);

  //refImage       = loadImage("wavemotion.jpg");
  refImage       = loadImage("kamehameha.jpg");
  referencefield = new ReferenceField(64, 0.09, 0.004, refImage);  // resolution, noiseVel, noiseTime

=======
  size(1024, 768, P2D);
  smooth();
  
  refImages      = new PImage[2]; 
  refImages[0]   = loadImage("wavemotion.jpg");
  refImages[1]   = loadImage("kamehameha.jpg");
  
  // args = resolution, noiseVel, noiseTime, array of ref images
  referencefield = new ReferenceField(64, 0.09, 0.004, refImages); 
  mouseField     = new MouseField(128, 0.2, 0.01);
  
>>>>>>> 224ddd3a8cb6bfbe17957d40ee13989a091d699c
  setup_tests_and_instructions();
}

void draw() {
  //background(255);

<<<<<<< HEAD
  if (testField) {
    referencefield.run(fieldtests);
  } else {
    referencefield.run();
  }
  
  fill(0,10);
  rect(0,0,width,height);
=======
  
    //referencefield.run(fieldtests);
    //referencefield.run();
  
  
  mouseField.run(fieldtests);
  
>>>>>>> 224ddd3a8cb6bfbe17957d40ee13989a091d699c
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