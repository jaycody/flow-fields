// A class for an attractive body (Dancer's center of mass)

class SpiroCenter {
  color centerColor;  // color of the sun
  float mass;         // Mass, tied to size
  PVector location;   // Location
  float G;            // Universal gravitational constant 
                      //(make inversely proportional to distance between dancer's hands)
  
  float minDistanceToSun;
  float maxDistanceToSun;
  
  float angle;
  float angleDelta; 

  // A bunch of orbitting SpiroLights
  SpiroLight[] spiroLights = new SpiroLight[10];

  SpiroCenter(color _color) {
    location = new PVector(0,0,0);
    centerColor = _color;
    mass = 20;
    G = 1;
    minDistanceToSun = 15;
    maxDistanceToSun = 20;
    angle = 0;
    angleDelta = random(-.1,.1);

    // Some random spiroLights
    for (int i = 0; i < spiroLights.length; i++) {
      spiroLights[i] = new SpiroLight(random(0.1, 2), random(-width/2, width/2), random(-height/2, height/2), random(-100, 100));
    }
 }


  PVector attract(SpiroLight m) {
    PVector force = PVector.sub(ZERO_VECTOR,m.location); // Calculate direction of force
    float d = force.mag();                               // Distance between objects
    d = constrain(d,minDistanceToSun,maxDistanceToSun);  // Limiting the distance to eliminate "extreme" results for very close or very far objects
    float strength = (G * mass * m.mass) / (d * d);      // Calculate gravitional force magnitude
    force.setMag(strength);                              // Get force vector --> magnitude * direction
    return force;
  }

  // Draw SpiroCenter
  void display(float centerX, float centerY) {
  
    pushStyle();
    // set color according to our setup
    noStroke();
    fill(centerColor);

    // move to our new center point
    pushMatrix();
    translate(centerX, centerY, 0);
    rotateY(angle);

    // draw the center sun
    sphere(mass*2);

    // Draw all of their planets
    for (int i = 0; i < spiroLights.length; i++) {
      
      // Dancer's center of mass attracts spiroLights
      PVector force = attract(spiroLights[i]);
      spiroLights[i].applyForce(force);
      
      // Update and draw the spiroLights
      spiroLights[i].update();
      spiroLights[i].display();
    }
    
    // update rotation for next time
    angle += angleDelta;
    
    popMatrix();
    popStyle();
  }
}


/*
 * Simulating gravitational attraction 
 * G ---> universal gravitational constant
 * m1 --> mass of object #1
 * m2 --> mass of object #2
 * d ---> distance between objects
 * F = (G*m1*m2)/(d*d)
 */
