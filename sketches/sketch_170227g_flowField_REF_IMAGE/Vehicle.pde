class Vehicle {
  
 PVector loc;
 PVector gridVector;
 PVector vel;
 PVector acc;
 PVector size;
 PVector fillVector;
 
 float maxspeed;  // stops teleportation
 float maxforce;  // ability to steer
 
 float theta;
 float thetaScale;
 
 
 
 Vehicle(){
  loc         = new PVector(random(width), random(height));
  gridVector  = new PVector(0,0);
  vel         = new PVector(0,0);
  acc         = new PVector(0,0);
  size        = new PVector(10,10);
  fillVector  = new PVector(255,255);
    
 }
  
  void display(){
    
    fillVector.y = (100*thetaScale)+10;
    //fill(fillVector.x,0,0,fillVector.y);
    stroke(255,0,0,(20*thetaScale)+30);
    //strokeWeight(thetaScale+1);
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    
    rect(0,0, (size.x*(cos(theta))*1.5), (size.y*(sin(theta)))*1.5);

    popMatrix();
  }
  
  void getBrightnessFrom(FlowField flow){
    fillVector.x = flow.lookupBrightness(loc);
    fill(fillVector.x,0,0,fillVector.y);
    
    
  }
  
  
  void follow(FlowField flow){   
   gridVector = flow.lookup(loc);
   size.x = flow.resolution;
   size.y = flow.resolution;
   theta = gridVector.heading2D();
   thetaScale = map(theta, -PI, PI, 0, 1);
   //println(theta, sizeScale);
  
   size.mult(theta*.5);
   //size.x *= sizeScale;
   
   //size.add(gridVector);
 
   
   
    
    
    
    
  }
  
  
  
  
  
  
  
}