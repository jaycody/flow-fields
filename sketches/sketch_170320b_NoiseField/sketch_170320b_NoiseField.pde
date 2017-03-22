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

BaseField  basefield;
NoiseField noisefield;

void setup() {
  size(1024, 768, P3D);
  smooth();
  //basefield  = new BaseField(32);
  noisefield = new NoiseField(16);
}

void draw() {
  //basefield.display();
  noisefield.display();
}