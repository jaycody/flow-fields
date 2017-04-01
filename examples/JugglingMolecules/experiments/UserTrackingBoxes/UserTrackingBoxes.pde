/* --------------------------------------------------------------------------
 * SimpleOpenNI UserScene3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhkd / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * this demos is at the moment only for 1 user, will be implemented later
 * ----------------------------------------------------------------------------
 */

////// NOTE:  based on example: "OpenNTI/UserScene3d"


import SimpleOpenNI.*;


SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);
//color[]      userColors = { color(255,0,0), /*color(0,255,0), */color(0,0,255), color(255,255,0), color(255,0,255), color(0,255,255) };
color[]      userColors = { color(255,100,100), color(100,255,100), color(100,100,255), color(255,255,100), color(255,100,255), color(100,255,255) };
color[]      userCoMColors = { color(255,100,100), color(100,255,100), color(100,100,255), color(255,255,100), color(255,100,255), color(100,255,255) };

// steps to jump through the map.  Larger value == faster, smaller == more accurate.
int steps = 10;  // skip lots of points to make this faster

int DEPTH_HEIGHT;
int DEPTH_WIDTH;
int A_BIG_NUMBER = 100000;

void setup()
{
  size(1024,768,P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  context = new SimpleOpenNI(this);

  // turn on mirror
  context.setMirror(true);

  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  if (context.enableIR() == false) {
     println("Can't open the irMap, maybe the camera is not connected!"); 
     exit();
     return;
  }

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  // enable the scene, to get the floor
  context.enableScene();
  
  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
 }

void draw()
{
  // update the cam
  context.update();

  background(0,0,0);
  
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  
  int[]   depthMap = context.depthMap();
  int     index;
  PVector realWorldPoint;
 
  // set up constants to speed up the below
  DEPTH_HEIGHT = context.depthHeight();
  DEPTH_WIDTH = context.depthWidth();
  
  translate(0,0,-1000);  // set the rotation center of the scene 1000 infront of the camera

  int userCount = context.getNumberOfUsers();
  int[] userMap = null;

  int user1MinX = 10000;
  int user1MaxX = 0;
  int[][] userSizes = null;
  
  if(userCount > 0) {
    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);
    userSizes = getUserSizes(userCount, userMap);
  }
  
  for(int y=0;y < DEPTH_HEIGHT;y+=steps) {
    for(int x=0;x < DEPTH_WIDTH;x+=steps) {
      index = x + y * DEPTH_WIDTH;
      if(depthMap[index] > 0) { 
        // get the realworld points
        realWorldPoint = context.depthMapRealWorld()[index];
        
        // check if there is a user
        if(userMap != null && userMap[index] != 0) {  
          // if so, draw in the user's color
          int colorIndex = userMap[index] % userColors.length;
          stroke(userColors[colorIndex]); 
          strokeWeight(2);
        }
        else {
          // otherwise draw in the default color
          stroke(100);
          strokeWeight(1);
        } 
        point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
      }
    } 
  } 
  
  // draw the center of mass
  PVector centerOfMass = new PVector();
  color userColor;
  pushStyle();
  for(int userId=1;userId <= userCount;userId++) {
    // figure out color for this user
    userColor = userCoMColors[userId % userCoMColors.length];
    stroke(userColor);
    noFill();

    // get the center of mass
    context.getCoM(userId, centerOfMass);

    // print size for each user
    int[] userSize = userSizes[userId];
    if (userSize[0] > -1) {
      strokeWeight(1);
      int userLeft = userSize[0];
      int userTop = userSize[3];
      int userWidth = userSize[2];
      int userHeight = userSize[5]; 
      println("user "+userId+"  width: "+userWidth+"  height:"+userHeight);
      pushMatrix();
      translate(centerOfMass.x,centerOfMass.y,centerOfMass.z);
      box(userWidth, userHeight, 100);
//      rect(-(userWidth/2), -(userHeight/2), userWidth, userHeight);

      // draw center of mass as a point      
      strokeWeight(15);
      point(0,0,0);  // draw at 0,0,0 cause we already translated
      popMatrix();
    } else {
      println("USER "+userId+" IS BOGUS MAN!!!");
    }
  }  
  popStyle();
    
  /*
  // draw the floor
  PVector floorCenter = new PVector();
  PVector floorNormal = new PVector();
  PVector floorEnd = new PVector();
  
  context.getSceneFloor(floorCenter,floorNormal);
  floorEnd = PVector.add(floorCenter,PVector.mult(floorNormal,1000));
  println(floorCenter + " - " + floorEnd);
  pushStyle();
    strokeWeight(8);
    stroke(0,255,255);
    line(floorCenter.x,floorCenter.y,floorCenter.z,
         floorEnd.x,floorEnd.y,floorEnd.z);
     stroke(0,255,100);     
    line(floorEnd.x,floorEnd.y,floorEnd.z,
         0,0,0);
  popStyle();
  */ 
  
  // draw the kinect cam
  //context.drawCamFrustum();
}


int[][] getUserSizes(int userCount, int[] userMap) {
  if (userCount == 0) {
   return null; 
  }
  
  int[] minX = new int[userCount+1];
  int[] minY = new int[userCount+1];
  int[] maxX = new int[userCount+1];
  int[] maxY = new int[userCount+1];
  
  // set up arrays
  for(int u=1; u <= userCount; u++) {
     minX[u] = A_BIG_NUMBER;
     maxX[u] = 0;
     minY[u] = A_BIG_NUMBER;
     maxY[u] = 0;
  } 
  
   //figure out min/max size for user 1
  for(int y=0;y < DEPTH_HEIGHT;y+=steps) {
    for(int x=0;x < DEPTH_WIDTH;x+=steps) {
      int index = x + y * DEPTH_WIDTH;
      // what user does this belong to
      int userNum = userMap[index];
      if (userNum > 0 && userNum <= userCount) { 
        if (x < minX[userNum]) minX[userNum] = x;
        if (x > maxX[userNum]) maxX[userNum] = x; 
        if (y < minY[userNum]) minY[userNum] = y;
        if (y > maxY[userNum]) maxY[userNum] = y; 
      }
    }
  }
  
  // generate output
  int[][] results = new int[userCount+1][6];
  int[] nullResult = {-1, -1, -1, -1, -1, -1 };
  for (int u=1; u <= userCount; u++) {
    if (minX[u] < A_BIG_NUMBER && minY[u] < A_BIG_NUMBER) {
      int deltaX = maxX[u] - minX[u];
      int deltaY = maxY[u] - minY[u];
      int[] userResult = {minX[u], maxX[u], deltaX, minY[u], maxY[u], deltaY};
      results[u] = userResult;
    } else {
      results[u] = nullResult;
    }
  }
  return results;
} 


// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);  
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}


// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
    
  switch(keyCode)
  {
    case LEFT:
      rotY += 0.1f;
      break;
    case RIGHT:
      // zoom out
      rotY -= 0.1f;
      break;
    case UP:
      if(keyEvent.isShiftDown())
        zoomF += 0.01f;
      else
        rotX += 0.1f;
      break;
    case DOWN:
      if(keyEvent.isShiftDown())
      {
        zoomF -= 0.01f;
        if(zoomF < 0.01)
          zoomF = 0.01;
      }
      else
        rotX -= 0.1f;
      break;
  }
}
