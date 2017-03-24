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



boolean showField = true;

boolean testField = true;
FieldTester[] testObjects;
int totalTestObjects = 1000;

void setup() {
  size(1024, 768);
  smooth();
  noisefield     = new NoiseField(32, 0.05, 0.007);      // resolution, noiseVel, noiseTime
  referencefield = new ReferenceField(64, 0.09, 0.004);  // resolution, noiseVel, noiseTime

  initializeTestObjects();
  displayInstructions();
}

void draw() {
  background(255);
  
  //noisefield.display();
  referencefield.display();
  
  conductFieldTest(referencefield);
  //conductFieldTest(noisefield);
}


void initializeTestObjects() {
  //field test init
  testObjects = new FieldTester[totalTestObjects];
  for (int i = 0; i < totalTestObjects; i++) {
    testObjects[i] = new FieldTester();
  }
}

void displayInstructions() {
  println("\nkey commands:\n\ttoggle field: spacebar");
}

void conductFieldTest(BaseField field) {
  if (testField) {
    for (int i = 0; i < testObjects.length; i++) {
      testObjects[i].test(field);
    }
  }
}


void keyPressed() {
  if (key == ' ') {
    showField = !showField;
  }
}