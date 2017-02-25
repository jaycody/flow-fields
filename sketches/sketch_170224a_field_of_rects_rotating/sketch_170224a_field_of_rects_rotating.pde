/* jstephens
 NOC gungfu - prep for ecpc project
 create simplest vector field 
 */
 
 FlowField grid;
 
 void setup() {
   size(1024,768);
   rectMode(CENTER);
   //size(640, 480);
   //background(0);
   grid = new FlowField(45);
 }
 
 
 
 void draw() {
   //background(0);
   
   grid.display();
   
   fill(255,15);
   rect(width/2, height/2, width, height);
 }
 
 
 