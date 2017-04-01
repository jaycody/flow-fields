/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

float gLastParticleHue = 0;

////////////////////////////////////////////////////////////
//	Particle class
////////////////////////////////////////////////////////////
class Particle {
	// ParticleManager we interact with, set in our constructor.
	ParticleManager manager;

	// Our configuration object, set in our constructor.
	MolecularConfig config;

	// set on `reset()`
	PVector location;
	PVector prevLocation;
	PVector acceleration;
	float zNoise;
	int life;					// lifetime of this particle
	color clr;

	// randomized on `reset()`
	float stepSize;

	// working calculations
	PVector velocity;
	float angle;


	// for flowfield
	PVector steer;
	PVector desired;
	PVector flowFieldLocation;



	// Particle constructor.
	// NOTE: you can count on the particle being `reset()` before it will be drawn.
	public Particle(ParticleManager _manager, MolecularConfig _config) {
		// remember our configuration object & particle manager
		manager = _manager;
		config  = _config;

		// initialize data structures
		location 			= new PVector(0, 0);
		prevLocation 		= new PVector(0, 0);
		acceleration 		= new PVector(0, 0);
		velocity 			= new PVector(0, 0);
		flowFieldLocation 	= new PVector(0, 0);
	}


	// resets particle with new origin and velocitys
	public void reset(float _x,float _y,float _zNoise, float _dx, float _dy) {
		location.x = prevLocation.x = _x;
		location.y = prevLocation.y = _y;
		zNoise = _zNoise;
		acceleration.x = _dx;
		acceleration.y = _dy;

		// reset lifetime
		life = config.particleLifetime;

		// randomize step size each time we're reset
		stepSize = random(config.particleMinStepSize, config.particleMaxStepSize);

		// set up now if we're basing particle color on its initial x/y coordinate
		if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_XY) {
			int r = (int) map(_x, 0, width, 0, 255);
			int g = (int) map(_y, 0, width, 0, 255);	// NOTE: this is nice w/ Y plotted to width
			int b = (int) map(_x + _y, 0, width+height, 0, 255);
			clr = color(r, g, b, config.particleAlpha);
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_YX) {
			int r = (int) map(_x + _y, 0, width+height, 0, 255);
			int g = (int) map(_x, 0, width, 0, 255);
			int b = (int) map(_y, 0, height, 0, 255);
			clr = color(r, g, b, config.particleAlpha);
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_XYX) {
			if (++gLastParticleHue > 360) gLastParticleHue = 0;
			float nextHue = map(gLastParticleHue, 0, 360, 0, 1);
			clr = color(colorFromHue(nextHue), config.particleAlpha);
		} else {	//if (config.particleColorScheme == gConfig.PARTICLE_COLOR_SCHEME_SAME_COLOR) {
			clr = color(config.particleColor, config.particleAlpha);
		}
	}

	// Is this particle still alive?
	public boolean isAlive() {
		return (life > 0);
	}

	// Update this particle's position.
	public void update() {
		prevLocation = location.get();

		if (acceleration.mag() < config.particleAccelerationLimiter) {
			life--;
			angle = noise(location.x / (float)config.noiseScale, location.y / (float)config.noiseScale, zNoise);
			angle *= (float)config.noiseStrength;

//EXTRA CODE HERE

			velocity.x = cos(angle);
			velocity.y = sin(angle);
			velocity.mult(stepSize);

		}
		else {
			// normalise an invert particle position for lookup in flowfield
			flowFieldLocation.x = norm(width-location.x, 0, width);		// width-location.x flips the x-axis.
			flowFieldLocation.x *= gKinectWidth; // - (test.x * wscreen);
			flowFieldLocation.y = norm(location.y, 0, height);
			flowFieldLocation.y *= gKinectHeight;

			desired = manager.flowfield.lookup(flowFieldLocation);
			desired.x *= -1;	// TODO??? WHAT'S THIS?

			steer = PVector.sub(desired, velocity);
			steer.limit(stepSize);	// Limit to maximum steering force
			acceleration.add(steer);
		}

		acceleration.mult(config.particleAccelerationFriction);

// TODO:  HERE IS THE PLACE TO CHANGE ACCELERATION, BEFORE IT IS APPLIED.   ???


// END ACCELERATION

		velocity.add(acceleration);
		location.add(velocity);

		// apply exponential (*=) friction or normal (+=) ? zNoise *= 1.02;//.95;//+= zNoiseVelocity;
		zNoise += config.particleNoiseVelocity;

		// slow down the Z noise??? Dissipative Force, viscosity
		//Friction Force = -c * (velocity unit vector) //stepSize = constrain(stepSize - .05, 0,10);
		//Viscous Force = -c * (velocity vector)
		stepSize *= config.particleViscocity;
	}

	// 2-d render using processing OPENGL rendering context
	void render() {
		stroke(clr);
		line(prevLocation.x, prevLocation.y, location.x, location.y);
	}
}
