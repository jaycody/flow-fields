
class FlowParticle extends Particle {

  float maxspeed;
  float maxforce;

  FlowParticle(PVector startingPoint_, float ms_, float mf_) {
    super(startingPoint_); 

    maxspeed = ms_;
    maxforce = mf_;
  }

  void follow(BaseField field) {
    PVector desired = field.lookup(loc);
    // Scale it up by maxspeed
    desired.mult(maxspeed);
    // Steering is desired minus velocity
    desired.sub(vel);
    desired.limit(maxforce);
    applyForce(desired);
    //PVector steer = PVector.sub(desired, vel);  // OPTIMIZE HERE, remove temp PVector
    //steer.limit(maxforce);  // Limit to maximum steering force
    //applyForce(steer);
  }
}