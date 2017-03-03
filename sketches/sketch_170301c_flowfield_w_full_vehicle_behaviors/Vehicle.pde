class Vehicle {

  PVector loc;
  PVector gridVector;
  PVector vel;
  PVector acc;
  PVector size;
  PVector fillVector;
  color refColor;
  color strokeColor;
  
  float maxspeed;  // stops teleportation
  float maxforce;  // ability to steer

  float theta;
  float thetaScale;

  Vehicle() {
    loc         = new PVector(random(width), random(height));
    gridVector  = new PVector(0, 0);
    vel         = new PVector(0, 0);
    acc         = new PVector(0, 0);
    size        = new PVector(random(gridResolution), random(gridResolution));
    fillVector  = new PVector(255, 255); 
    refColor    = color(255,0,0);
    strokeColor = color(255,0,0);

    maxspeed    = random(1.0, 5.0); //2, 5
    maxforce    = random(4, 5); //.1, .5
  }

 // time to add some autonomousness
  /* 1. calc desired vector: goal vector - current position
   2. scale desire by max speed to prohibit teleportation
   3. calc steering force: desired vector - current velocity
   4. limit steering force based on max ability (maxforce)
   5. apply steering force by adding it to acceleration
   6. acceleration informs velocity
   7. velocity informs location
   8. reset acceleration to zero
   */
  void follow(FlowField flow) {   
    theta= gridVector.heading2D(); // = 1;
    
    //PVector desired = flow.lookup(loc);
    gridVector = flow.lookup(loc);
    // scale it up by maxspeed
    
    gridVector.mult(maxspeed*theta);
    //gridVector.mult(maxspeed);

    // calculate steering force
    // PVector steering = PVector.sub(desired, velocity);
    //  - but without creating a temp PVector it looks like...
    //      desired.sub(velocity); or 
    gridVector.sub(vel);
    gridVector.limit(maxforce);
    applyForce(gridVector);


    
    thetaScale = map(theta, -PI, PI, 0, 1);
    //size.setMag(.5);


  }

  void applyForce(PVector f) {
    acc.add(f);
  }
  
  void update() {
    // update velocity with current forces
    vel.add(acc);
    // limit velocity to max speed
    vel.limit(maxspeed);
    // update location by dist/frame (velocity)
    loc.add(vel);
    // reset acc
    acc.mult(0);
  }



  void display() {
    float heading = vel.heading2D();
    
    fillVector.y = (100*thetaScale)+10;
    
    /*
    // option 1
  //  fill(fillVector.x, 0, 0, fillVector.y);
    stroke(strokeColor, (20*thetaScale)+30);
    */
    
    /*// option 2
    fill(refColor, fillVector.y);
    stroke(refColor, fillVector.y);
    */
    
    fill(refColor, 22);
    stroke(refColor, 25);
    
    
    
       
    //strokeWeight(thetaScale+1);

    pushMatrix();
    translate(loc.x, loc.y);
    //rotate(heading);
    //rotate(theta);
    //rect(0, 0, (size.x*(cos(theta))*1.5), (size.y*(sin(theta)))*1.5);
    rect(0, 0, size.x, size.y);
    popMatrix();
  }

  void getBrightnessFrom(FlowField flow) {
    fillVector.x = flow.lookupBrightness(loc);
      fill(fillVector.x, 0, 0, fillVector.y);
  }

  void getColorFrom(FlowField flow) {
    refColor = flow.lookupColor(loc);
  }
  
  void borders() {
   if (loc.x < -size.x) loc.x = width + size.x;
   if (loc.y < -size.y) loc.y = height + size.y;
   
   if (loc.x > width + size.x) loc.x = -size.x;
   if (loc.y > height + size.y) loc.y = -size.y;
  }
 
}