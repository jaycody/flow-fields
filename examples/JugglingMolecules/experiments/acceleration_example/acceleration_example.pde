/**
 * Omicron-Spirolight
 * Hypocycloids + OmiCron + Kinect
 * 
 **************************
 * from Acceleration with Vectors 
 * by Shiffman.  
 * For more examples of simulating motion and physics with vectors, see 
 * Simulate/ForcesWithVectors, Simulate/GravitationalAttraction3D
 */

// A Mover object
Spiro spiro;

void setup() {
  size(640,360);
  spiro = new Spiro(); 
}

void draw() {
  background(0);
  
  // Update the location
  spiro.update();
  // Display the Mover
  spiro.display(); 
}

