
class MetaSystem {

  ArrayList<ParticleSystem> metaSystem;
  PVector                   origin;
  boolean                   replaceEmptyPS = false;
  PImage[]                  pTextures;

  PVector                   wind;
  boolean                   applyWind = true;

  MetaSystem() {
    metaSystem   = new ArrayList<ParticleSystem>();
    origin       = new PVector(mouseX, mouseY);

    pTextures    = new PImage[6];
    for (int i = 0; i < pTextures.length; i++) {
      pTextures[i] = loadImage("tex" + i + ".png");
    }
    
    wind         = new PVector();

    showInstructions();
    blendMode(ADD);
  }

  void runAllSystems() {
    background(0);
    
    if (applyWind) {
      float dx = map(mouseX, 0, width, -0.2, 0.2);
      wind.x = dx;
      wind.y = 0;
    }

    for (int i = metaSystem.size()-1; i >= 0; i--) {
      ParticleSystem ps = metaSystem.get(i);

      if (applyWind) {
        ps.applyForce(wind);
      }

      ps.run();

      removeIfEmpty(ps, i);
    }
  }

  void removeIfEmpty(ParticleSystem ps_, int psIndex_) {
    if (ps_.isEmpty()) {
      metaSystem.remove(psIndex_);

      if (replaceEmptyPS) {
        addNewParticleSystem(int(random(20)), random(width), random(height), 2, 0);
      }
    }
  }

  void addNewParticleSystem(int pTexIndex_) {
    int totalParticles = int(random(300));
    int pType          = int(random(2));
    int pTexIndex      = pTexIndex_;
    origin.x           = mouseX;
    origin.y           = mouseY;
    metaSystem.add(new ParticleSystem(totalParticles, origin, pTextures, pTexIndex, pType));
  }

  void addNewParticleSystem(int totalParticles, float x_, float y_, int pTexIndex_, int pType_) {
    origin.x = x_;
    origin.y = y_;
    metaSystem.add(new ParticleSystem(totalParticles, origin, pTextures, pTexIndex_, pType_));
  }

  void removeParticleSystem() {
    if (metaSystem.size() >= 1) metaSystem.remove(metaSystem.size()-1);
  }

  void clearHome() {
    background(random(255));
  }

  void showInstructions() {
    println("Add PS: \t mousePressed");
    println("Remove PS: spacebar");
    println("ClearHome: c");
  }
}