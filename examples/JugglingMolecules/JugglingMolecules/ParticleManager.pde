/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

class ParticleManager {
	// Current configuration.
	MolecularConfig config;		// set DURING init

	// flowfield which influences our drawing.
	OpticalFlow flowfield;		// set AFTER init

	// Particles we manage.  Currently created DURING init.
	Particle particles[];
	// Index of next particle to revive when its time to "create" a new particle.
	int particleId = 0;


	public ParticleManager(MolecularConfig _config) {
		// remember our configuration object.
		config = _config;

		// pre-create all particles for efficiency when drawing.
		int particleCount = config.MAX_particleMaxCount;
		particles = new Particle[particleCount];
		for (int i=0; i < particleCount; i++) {
			// initialise maximum particles
			particles[i] = new Particle(this, config);
		}
	}

	public void updateAndRender() {
		// NOTE: doing pushStyle()/popStyle() on the outside of the loop makes this much much faster
		pushStyle();
		// loop through all particles
		int particleCount = config.particleMaxCount;
		for (int i = 0; i < particleCount; i++) {
			Particle particle = particles[i];
			if (particle.isAlive()) {
				particle.update();
				particle.render();
			}
		}// end loop through all particles
		popStyle();
	}

	// Add a bunch of particles to represent a new vector in the flow field
	public void addParticlesForForce(float x, float y, float dx, float dy) {
		regenerateParticles(x * width, y * height, dx * config.particleForceMultiplier, dy * config.particleForceMultiplier);
	}

	// Update a set of particles based on a force vector.
	// NOTE: We re-use particles created at construction time.
	//		 `particleId` is a global index of the next particles to take over when it's time to "make" some new particles.
	// NOTE: With a small `config.particleMaxCount`, we'll re-use particles before they've fully decayed.
	public void regenerateParticles(float startX, float startY, float forceX, float forceY) {
		for (int i = 0; i < config.particleGenerateRate; i++) {
			float originX = startX + random(-config.particleGenerateSpread, config.particleGenerateSpread);
			float originY = startY + random(-config.particleGenerateSpread, config.particleGenerateSpread);
			float noiseZ = particleId/float(config.particleMaxCount);

			particles[particleId].reset(originX, originY, noiseZ, forceX, forceY);

			// increment counter -- go back to 0 if we're past the end
			particleId++;
			if (particleId >= config.particleMaxCount) particleId = 0;
		}
	}

}