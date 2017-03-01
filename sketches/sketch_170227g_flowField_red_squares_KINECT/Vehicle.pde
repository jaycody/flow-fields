class Vehicle {
  
 PVector loc;
 PVector gridVector;
 PVector vel;
 PVector acc;
 PVector size;
 
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
    
 }
  
  void display(){
    
    //fill(255,0,0,(100*thetaScale)+10);
    stroke(255,0,0,(20*thetaScale)+30);
    //strokeWeight(thetaScale+1);
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    
    rect(0,0, (size.x*(cos(theta))*1.5), (size.y*(sin(theta)))*1.5);

    popMatrix();
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