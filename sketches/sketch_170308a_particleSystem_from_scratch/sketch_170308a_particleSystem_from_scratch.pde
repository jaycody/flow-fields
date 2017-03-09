/* jstephens 
 ParticleSystem gongfu 
 */

ArrayList<Particle> particles;
int totalParticles = 1000;


void setup() {
  size(1024, 768);

  particles = new ArrayList<Particle>();

  for (int i = 0; i < totalParticles; i++) {
    particles.add(new Particle(random(width), random(height)));
  }
}


void draw() {
  background(150);
  ellipse(10, 10, 10, 19);

  for (int i = particles.size()-1; i > 0; i--){
    Particle p = particles.get(i);
    p.display();
    if (p.isDead()){
      particles.remove(p);
     // particles.add(new Particle(random(width), random(height)));
    } 
  }
}