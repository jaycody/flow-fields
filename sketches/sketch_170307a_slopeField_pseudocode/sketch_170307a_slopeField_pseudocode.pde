/* psuedo-code for a slopeField of slopeCells with slopeVectors

at every round of animation:

depthCamera, update your 1D array of depthPixels

depthField, use depthPixels to update the depthValues for each of your depthCells
  for every depthCell in depthField {
    derive your depth from the depthPixel whose 1D index in the depthPixel array corresponds to your 2D cell location

slopeField, use the depthField to update the slopeVectors for each of your slopeCells
  for every slopeCell in slopeField {
    derive your slope from nieghboring cells in (depthField);
  }

for every particle in ParticleSystem {
  1. particle, ask slopeField for the slopeVector of the slopeCell at your location
        slopeVector at particle location = slopeField.lookupSlopeVectorAt(this particle's current location);
      
    2. particle, let the slopeVector be your desiredVector
      PVector desiredVector = newPVector(slopeVector);
      
  3. particle, use your desiredVector and currentVelocity to calculate a steering vector
       PVector steeringForce = new PVector.sub(desiredVector, currentVelocity);

  4. particle, use your viscosity to limit the steering force you can apply to your desiredVector
         steeringForce.limit(byViscosity);
  
  5. particle, use steeringForce to update your location
       particle acceleration.add(steeringForce)
       particle velocity.add(acceleration)
       particle location.add(velocity)

  6. particle, reset your acceleration in prep for recalculation at upcoming location
    particle acceleration.mult(0);
    
  7. particle, draw yourself at current location
    point(location.x, location.y);
*/

slopeCell[i].deriveSlopeFromNeighborsIn(depthField);


class SlopeCell {
  PVector locOnSlopeGrid;
  PVector correspondingDepthCellLocOnDepthGrid;
  PVector slopeVector;
  
  SlopeCell(PVector gridLocation) {
    locOnSlopeGrid = gridLocation.get();  
    correspondingDepthCellLocOnDepthGrid = new PVector(locOnSlopeGrid.x, locOnSlopeGrid.y);
}
  
  void deriveYourSlopeFromNeighborsIn(Field depthField) {
    float recordLowestDepth = 200000;
    float depthDifference;
    int    recordLowestIndex;
    float currentCellDepth = depthField.lookupDepthAt(
      correspondDepthCell.x, correspondingDepthCell.y);
    float[] depthOfNeighbors = new float[8];
    int    neighborSubIndex;
    int   directionIndex;
    int offset = 1;
    int pointTowardLowestX, pointTowardLowestY
    // iterate through neighboring cells and assign depth to 1D array
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        neighborSubIndex = i + offset + (j * offset);
        // skip self
        if (i == 0 && j == 0) {
          println('do nothing');
        } else {
          depthOfNeighbors[neighborSubIndex] 
            = depthField.lookupDepthAt(
              correspondingDepthCellLocOnGrid.x + i,
              correspondingDepthCellLocOnGrid.y + j);
          // is this neighbor the new record holder? If so, record its depth and index
          if (depthOfNeighbor[neighborSubIndex] < recordLowestDepth) {
            recordLowestDepth = depthOfNeighbor[neighborSubIndex];
            recordLowestIndex = neighborSubIndex;
            
            // set slopeVector direction !!! using i and j for unit vector
            // this saves us from having to use a directionIndex at all!
            slopeVector.x     = i;
            slopeVector.y    = j;
          }
        }
      }
      // exit the iteration through neighbors with a lowest depth and its cell index
      //   - compare lowest neighbor's depth to self
      if (recordLowestNeighbor < currentCellDepth) {
        directionIndex = recordLowestIndex;
        depthDifference = currentDepth - recordLowest;
      } else {
        directionIndex = -1;
      }
      // we dont need the switch case if we set slope direction using i, j in the forloop
      /*// set slope direction
      switch(directionIndex){
        // when all neighbors are higher
        case -1: 
          slopeVector.mult(0);
          break;
        // when top left neighbor is lower
        case 0:
          slopeVector.x = -1;  // or slopeVector.x = pointToLowestX;
          slopeVector.y = -1;  // or slopeVector.y = pointToLowestY;
          break;
        case 1:
          slopeVector.x = 0;
          slopeVector.y = -1;
          break;
        case 2: 
          slopeVector.x = 
      }
      */
      
      // set slope magnitude
      //   - first, map depthDifferene to usable slopeMagnitude
      float steepness = map(depthDifference, 0, 500, 1, 5);
      slopeVector.setMagnitude(steepness);
    }
  }  
  
  // let particles ask you for your slopeVector
  PVector getSlopeVector() {
    return slopeVector;
  }
}    
    
  