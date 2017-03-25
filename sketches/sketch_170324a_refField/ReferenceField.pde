
class ReferenceField extends NoiseField {

  PImage refImage;


  ReferenceField(int res_, float noiseVel_, float noiseTime_, PImage refImage_) {
    super(res_, noiseVel_, noiseTime_);

    refImage = refImage_;
  }


  void run() {
    super.run();
    image(refImage, 100, 100, 100, 100);
  }
}