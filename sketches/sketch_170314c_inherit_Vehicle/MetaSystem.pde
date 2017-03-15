
class MetaSystem {

  ArrayList<ParticleSystem> metaSystem;
  PVector                   origin;
  boolean                   replaceEmptyPS = false;
  PImage                    pTexture;

  MetaSystem() {
    metaSystem = new ArrayList<ParticleSystem>();
    origin  = new PVector(mouseX, mouseY);
    
    pTexture    = loadImage("texture.png");

    showInstructions();
    blendMode(ADD);
  }

  void runAllSystems() {
    background(0);
    for (int i = metaSystem.size()-1; i >= 0; i--) {
      ParticleSystem ps = metaSystem.get(i);
      ps.run();
      
      removeIfEmpty(ps, i);
    }
  }

  void removeIfEmpty(ParticleSystem ps_, int psIndex_) {
    if (ps_.isEmpty()) {
      metaSystem.remove(psIndex_);

      if (replaceEmptyPS) {
        addNewParticleSystem(int(random(20)), random(width), random(height), 0);
      }
    }
  }
  
   void addNewParticleSystem() {
    int totalParticles = int(random(300));
    int pType          = int(random(2));
    origin.x           = mouseX;
    origin.y           = mouseY;
    metaSystem.add(new ParticleSystem(totalParticles, origin, pTexture, pType));
  }
  
  void addNewParticleSystem(int totalParticles, float x_, float y_, int pType_) {
    origin.x = x_;
    origin.y = y_;
    metaSystem.add(new ParticleSystem(totalParticles, origin, pTexture, pType_));
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