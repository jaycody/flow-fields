
class ReferenceField extends NoiseField {

  PImage[] refImages;
  

  ReferenceField(int res_, float noiseVel_, float noiseTime_, PImage[] refImages_) {
    super(res_, noiseVel_, noiseTime_);

    refImages = refImages_;
  }

  void run() {
    super.run();
    image(refImages[1], 100, 100);
    image(refImages[0], 400, 400);
  }
}