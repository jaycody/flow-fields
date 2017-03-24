
class FieldTester {

  PVector fieldTestLoc;
  PVector vFromLookup;
  float   theta;

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
  }

  void display() {
    pushMatrix();
    translate(fieldTestLoc.x, fieldTestLoc.y);
    rotate(theta);
    fill(255, 0, 0, 100);
    rectMode(CENTER);
    rect(0, 0, 50, 50);
    rectMode(CORNER);
    popMatrix();
  }
}