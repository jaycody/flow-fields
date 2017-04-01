
class FieldTester {

  PVector fieldTestLoc;
  PVector vFromLookup;
  float   theta;
  float   alpha;

  FieldTester() {
    fieldTestLoc = new PVector(random(10, width-10), random(10, height-10));
  }


  void test(BaseField field) {
    update(field);
    display();
  }

  void update(BaseField field) {
    vFromLookup = field.lookup(fieldTestLoc);
    theta       = vFromLookup.heading2D();
    
    alpha       = map(abs(theta), 0, PI, 0, 255); // alpha=10 when theta= +/- 10
  }

  void display() {
    pushMatrix();
    translate(fieldTestLoc.x, fieldTestLoc.y);
    rotate(theta);
    //println(alpha);
    stroke(255,0,0,255-alpha);
    //noFill();
    fill(0, 255-alpha);
    rectMode(CENTER);
    rect(0, 0, 50*(alpha*.03), 20);
    //rect(0, 0, 50*(alpha*.015), 20);
    rectMode(CORNER);
    popMatrix();
  }
}