/* jstephens 
 ParticleSystem gongfu 
 
 NEXT:
 [ ] add vel & acc to particle class
 [ ] jump to the ParticleSystem class
 */

ArrayList<Particle> particles;
int totalParticles = 300;

PVector mouseLoc;

void setup() {
  size(1024, 768);
  
  mouseLoc = new PVector(mouseX, mouseY);
  
  particles = new ArrayList<Particle>();
  for (int i = 0; i < totalParticles; i++) {
    particles.add(new Particle(random(width), random(height)));
  }
}


void draw() {
  //background(150);
  mouseLoc.x = mouseX;
  mouseLoc.y = mouseY;
  
  for (int i = particles.size()-1; i > 0; i--){
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()){
      particles.remove(p);
      particles.add(new Particle(mouseLoc.x + random(-5,5), mouseLoc.y + random(-5,5)));
      //particles.add(new Particle(random(width), random(height)));
    } 
  }
}