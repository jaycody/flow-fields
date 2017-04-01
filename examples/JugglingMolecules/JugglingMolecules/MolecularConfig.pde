/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Configuration class for project.
//
//  We can load and save these to disk
//  to restore "interesting" states to play with.
////////////////////////////////////////////////////////////


// Particle color schemes
	int PARTICLE_COLOR_SCHEME_SAME_COLOR 	= 0;
	int PARTICLE_COLOR_SCHEME_XY 			= 1;
	int PARTICLE_COLOR_SCHEME_RAINBOW		= 2;
	int PARTICLE_COLOR_SCHEME_IMAGE			= 3;

	String[] _SETUP_FIELDS 	 = 	{ "setup*", "kinect*" };
	String[] _DEFAULT_FIELDS = 	{ "MIN_*", "MAX_*" };
	String[] _FIELDS 		 =  { "show*", "fade*", "flowfield*", "noise*",
								  "particle*", "flowLine*", "depthImage*",
								  "blend*"
								};


class MolecularConfig extends Config {

	// Initialize our fields on construction.
	public MolecularConfig() {
println("MolecularConfig INIT");
		this.SETUP_FIELDS 	= this.expandFieldList(_SETUP_FIELDS);
		this.DEFAULT_FIELDS = this.expandFieldList(_DEFAULT_FIELDS);
		this.FIELDS 		= this.expandFieldList(_FIELDS);
	}

////////////////////////////////////////////////////////////
//  Global setup.  Note that we cannot override these at runtime.
////////////////////////////////////////////////////////////

	// Window size
	int setupWindowWidth = 640;
	int setupWindowHeight = 480;

	// Desired frame rate
	// NOTE: requires restart to change.
	int setupFPS = 30;

	// Random noise seed.
	// NOTE: requires restart to change.
	// Trent Brooks sez:  "finding the right noise seed makes a difference!"
	int setupNoiseSeed = 26103;

	// OSC ports
	int setupOscInboundPort = 8000;
	int setupOscOutboundPort = 9000;

	// Kinect setup
	int kinectMinDepth = 100;
	int MIN_kinectMinDepth = 0;
	int MAX_kinectMinDepth = 2047;

	int kinectMaxDepth = 950;
	int MIN_kinectMaxDepth = 0;
	int MAX_kinectMaxDepth = 2047;

	int kinectAngle = 20;
	int MIN_kinectAngle = 0;
	int MAX_kinectAngle = 30;



////////////////////////////////////////////////////////////
//	Master controls for what we're showing on the screen
//	Note: they currently show in this order.
////////////////////////////////////////////////////////////

	// Show particles.
	boolean showParticles = true;

	// Show force lines.
	boolean showFlowLines = false;

	// Show the depth image.
	boolean showDepthImage = false;

	// Show perlin noise field
	boolean showNoise = true;

	// Show "fade" overlay
	boolean showFade = true;

	// Show setup screen OVER the rest of the screen.
	boolean showSettings = false;


////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// Should we map the window bg to greyscale, or hue?
	boolean fadeGreyscale = true;

	// Amount to "dim" the background each round by applying partially opaque background
	// Higher number means less of each screen sticks around on subsequent draw cycles.
	int fadeAlpha = 20;	//	0-255
	int MIN_fadeAlpha = 0;
	int MAX_fadeAlpha = 255;

	// background color (black)
	color fadeColor = color(0,0,0,255);	// black




////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// Resolution of the flow field.
	// Smaller means more coarse flowfield = faster but less precise
	// Larger means finer flowfield = slower but better tracking of edges
	// NOTE: requires restart to change this.
//TODO: make this a "setup" factor? and have a control
	int setupFlowFieldResolution = 15;	// 1..50 ?
	int MIN_setupFlowFieldResolution = 1;
	int MAX_setupFlowFieldResolution = 50;

	// Amount of time (in seconds) between "averages" to compute the flow.
	float flowfieldPredictionTime = 0.5;
	float MIN_flowfieldPredictionTime = .1;
	float MAX_flowfieldPredictionTime = 2;

	// Velocity must exceed this to add/draw particles in the flow field.
	int flowfieldMinVelocity = 20;
	int MIN_flowfieldMinVelocity = 1;
	int MAX_flowfieldMinVelocity = 100;

	// Regularization term for regression.
	// Larger values for noisy video (?).
	float flowfieldRegularization = pow(10,8);
	float MIN_flowfieldRegularization = 0;
	float MAX_flowfieldRegularization = pow(10,10);

	// Smoothing of flow field.
	// Smaller value for longer smoothing.
	float flowfieldSmoothing = 0.05;
	float MIN_flowfieldSmoothing = 0.05;	// NOTE: if this goes to 0, we get NO lines at all!
	float MAX_flowfieldSmoothing = 1;		// ????

////////////////////////////////////////////////////////////
//	Perlin noise generation.
////////////////////////////////////////////////////////////

	// Cloud variation.
	// Low values have long stretching clouds that move long distances.
	// High values have detailed clouds that don't move outside smaller radius.
//TODO: convert to int?
	int noiseStrength = 100; //1-300;
	int MIN_noiseStrength = 1;
	int MAX_noiseStrength = 300;

	// Cloud strength multiplier.
	// Low strength values makes clouds more detailed but move the same long distances. ???
//TODO: convert to int?
	int noiseScale = 100; //1-400
	int MIN_noiseScale = 1;
	int MAX_noiseScale = 400;

////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////

	// How much particle slows down in fluid environment.
	float particleViscocity = .995;	//0-1	???
	float MIN_particleViscocity = 0;
	float MAX_particleViscocity = 1;

	// Force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300
	float MIN_particleForceMultiplier = 1;
	float MAX_particleForceMultiplier = 300;

	// How fast to return to the noise after force velocities.
	float particleAccelerationFriction = .75;	//.001-.999	// WAS: .075
	float MIN_particleAccelerationFriction = .001;
	float MAX_particleAccelerationFriction = .999;

	// How fast to return to the noise after force velocities.
	float particleAccelerationLimiter = .35;	// - .999
	float MIN_particleAccelerationLimiter = .001;
	float MAX_particleAccelerationLimiter = .999;

	// Turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008; // .005 - .3
	float MIN_particleNoiseVelocity = .005;
	float MAX_particleNoiseVelocity = .3;



////////////////////////////////////////////////////////////
//	Particle drawing
////////////////////////////////////////////////////////////

	// Scheme for how we name particles.
	// 	- 0 = all particles same color, coming from `particle[Red|Green|Blue]` below
	// 	- 1 = particle color set from origin
	//	- 2 = rainbow
	//	- 3 = set according to particleImage, which is loaded automatically
	int particleColorScheme = PARTICLE_COLOR_SCHEME_XY;
//	int MIN_particleColorScheme = 0;
//	int MAX_particleColorScheme = 3;

	// if we're in PARTICLE_COLOR_SCHEME_IMAGE, does the color get applied
	//	when the particle is created, or when it's drawn?
	boolean applyParticleImageColorAtDrawTime = true;

	// Opacity for all particle lines, used for all color schemes.
	int particleAlpha		= 50;	//0-255
	int MIN_particleAlpha 	= 10;
	int MAX_particleAlpha 	= 255;

	// Color for particles iff `PARTICLE_COLOR_SCHEME_SAME_COLOR` color scheme in use.
	color particleColor		= color(255);



	// Maximum number of particles that can be active at once.
	// More particles = more detail because less "recycling"
	// Fewer particles = faster.
// TODO: must restart to change this
	int particleMaxCount = 30000;
	int MIN_particleMaxCount = 1000;
	int MAX_particleMaxCount = 30000;

	// how many particles to emit when mouse/tuio blob move
	int particleGenerateRate = 2; //2-200
	int MIN_particleGenerateRate = 1;
	int MAX_particleGenerateRate = 50;// 2000;

	// random offset for particles emitted, so they don't all appear in the same place
	int particleGenerateSpread = 20; //1-50
	int MIN_particleGenerateSpread = 1;
	int MAX_particleGenerateSpread = 50;

	// Upper and lower bound of particle movement each frame.
	int particleMinStepSize = 4;
	int MIN_particleMinStepSize = 2;
	int MAX_particleMinStepSize = 10;

	int particleMaxStepSize = 8;
	int MIN_particleMaxStepSize = 2;
	int MAX_particleMaxStepSize = 10;

	// Particle lifetime.
	int particleLifetime = 400;
	int MIN_particleLifetime = 50;
	int MAX_particleLifetime = 1000;



////////////////////////////////////////////////////////////
//	Drawing flow field lines
////////////////////////////////////////////////////////////

//TODO: apply alpha separately from hue
	int flowLineAlpha = 30;
	int MIN_flowLineAlpha 	= 10;
	int MAX_flowLineAlpha 	= 255;

	// color for optical flow lines
	color flowLineColor = color(255, 0, 0, 30);	// RED



////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////

	int depthImageAlpha = 30;
	int MIN_depthImageAlpha 	= 10;
	int MAX_depthImageAlpha 	= 255;

	// color for the depth image.
	// NOTE: NOT CURRENTLY USED.  see
	color depthImageColor = color(0,0,0,255);

	// show depth image as black/white or greyscale?
	boolean depthImageAsGreyscale = false;

	// Depth image blend mode constants.
	//	REPLACE:     0
	//	BLEND:       1
	//	ADD:         2
	//	SUBTRACT:    4
	//	LIGHTEST:    8
	//	DARKEST:     16
	//	DIFFERENCE:  32
	//	EXCLUSION:   64
	//	MULTIPLY:    128
	//	SCREEN:      256

	// blend mode for the depth image
	int[] blendChoices = {0, 1, 2, 4, 8, 16, 32, 64, 128, 256};
	int blendMode = BLEND;


////////////////////////////////////////////////////////////
//	Particle image settings
////////////////////////////////////////////////////////////
	int particleImage = 0;
	int MIN_particleImage = 0;
	int MAX_particleImage = 0;

	PImage _particleImage;
	int _currentparticleImage = -1;
	PImage getParticleImage() {
		if (particleImage != _currentparticleImage) {
			String fileName = particleImage+".jpg";
			_particleImage = loadImage(fileName);
			_particleImage.loadPixels();
			println("Loaded image "+ fileName+" with dimensions "+_particleImage.width+" x "+_particleImage.height);
			_currentparticleImage = particleImage;
		}
		return _particleImage;
	}
}