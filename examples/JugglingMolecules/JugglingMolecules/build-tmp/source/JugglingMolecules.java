import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import processing.video.*; 
import processing.opengl.*; 
import javax.media.opengl.*; 
import java.util.Iterator; 
import java.lang.reflect.*; 
import oscP5.*; 
import netP5.*; 
import org.openkinect.*; 
import org.openkinect.processing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class JugglingMolecules extends PApplet {

/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

	// TouchOSC






////////////////////////////////////////////////////////////
//	Global objects
////////////////////////////////////////////////////////////
	// TouchOSC controller
	OscP5 gOscMaster;

	// Configuration object, manipulated by TouchOSC and OmiCron
	MolecularConfig gConfig;

	// TouchOsc controller for our app
	MolecularController gController;

	// Kinect helper
	Kinecter gKinecter;

	// OpticalFlow field which converts Kinect depth into a vector flow field
	OpticalFlow gFlowfield;

	// Particle manager which renders the flow field
	ParticleManager gParticleManager;

	// Raw depth info from the kinect.
	int[] gRawDepth;

	// Adjusted depth, thresholded by `updateKinectDepth()`.
	int[] gNormalizedDepth;

	// Depth image, thresholded by `updateKinectDepth()` and displayable.
	PImage gDepthImg;


// Start() is the very first thing that's run, then setup().
// Load our config object first thing!
public void start() {
	// create the config object
	gConfig = new MolecularConfig();
	// Load setup, defaults and the last config automatically
	gConfig.loadAll();

}

// Initialize all of our global objects.
//
// NOTE: We want as much as possible to come from our gConfig object,
//		 which we can dynamically reload.  All config variables
//		 can be overridden except for the `setupXXX` items.
//
public void setup() {
	// window size comes from config
	size(gConfig.setupWindowWidth, gConfig.setupWindowHeight, OPENGL);

	// Initialize TouchOSC control bridge and start it listening on port 8000
	gOscMaster = new OscP5(this, 8000);

	// create and set up our controller
	gController = new MolecularController();
	gConfig.addController(gController);

	// set up display parametets
	background(gConfig.fadeColor);

	// set up noise seed
	noiseSeed(gConfig.setupNoiseSeed);
	frameRate(gConfig.setupFPS);

	// helper class for kinect
	gKinecter = new Kinecter(this);

	// initialize depth variables
    gRawDepth = new int[gKinectWidth*gKinectHeight];
	gNormalizedDepth = new int[gKinectWidth*gKinectHeight];
    gDepthImg = new PImage(gKinectWidth, gKinectHeight);

	// Create the particle manager.
	gParticleManager = new ParticleManager(gConfig);

	// Create the flowfield
	gFlowfield = new OpticalFlow(gConfig, gParticleManager);

	// Tell the particleManager about the flowfield
	gParticleManager.flowfield = gFlowfield;


	// print the configuration
	gConfig.echo();

	// save our startup state
	gConfig.saveSetup();
// MOW: NOTE - no need to save defaults, just pull them from the config variables directly
//	gConfig.saveDefaults();
//	gConfig.saveRestartState();


/*	print out the blendModes...

	println("	BLEND:       "+BLEND);
	println("	ADD:         "+ADD);
	println("	SUBTRACT:    "+SUBTRACT);
	println("	DARKEST:     "+DARKEST);
	println("	LIGHTEST:    "+LIGHTEST);
	println("	DIFFERENCE:  "+DIFFERENCE);
	println("	EXCLUSION:   "+EXCLUSION);
	println("	MULTIPLY:    "+MULTIPLY);
	println("	SCREEN:      "+SCREEN);
	println("	REPLACE:     "+ REPLACE);
*/
}


// Our draw loop.
public void draw() {
	pushStyle();
	pushMatrix();

	// updates the kinect gRawDepth, gNormalizedDepth & gDepthImg variables
	gKinecter.updateKinectDepth();

	// draw the depth image underneath the particles
	if (gConfig.showDepthImage) drawDepthImage();

	// update the optical flow vectors from the gKinecter depth image
	// NOTE: also draws the force vectors if `showFlowLines` is true
	gFlowfield.update();

	// show the flowfield particles
	if (gConfig.showParticles) gParticleManager.updateAndRender();

	// apply a full-screen color overlay
	// NOTE: this is where the blend mode is applied!
	if (gConfig.showFade) fadeScreen(gConfig.fadeColor, gConfig.fadeAlpha);

	// display instructions for adjusting kinect depth image on top of everything else
	if (gConfig.showSettings) drawInstructionScreen();


	popStyle();
	popMatrix();
}


////////////////////////////////////////////////////////////
//	Receiving events from the device.
////////////////////////////////////////////////////////////

// create function to recv and parse oscP5 messages
public void oscEvent(OscMessage message) {
	try {
		gController.oscEvent(message);
	} catch (Exception e) {
		println("ERROR processing oscEvent: "+e);
	}
}

// Take a picture, fool!
public void snapshot() {
	println("TAKE A PICTURE, FOOL!!!!");
}


// That's all folks!
public void stop() {
  gKinecter.quit();
  super.stop();
}

/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Configuration base class.
//
//  We can load and save these to disk to restore "interesting" states to play with.
//
//	Configurations are stored in ".tsv" files in Tab-Separated-Value format.
//		We have a header row as 		type<TAB>field<TAB>value
//		and then each row of data is 	<type><TAB><field><TAB><value>
//										<type><TAB><field><TAB><value>
//
//	We can auto-parse these config files using reflection.
//		TODOC... more details
//
////////////////////////////////////////////////////////////

//import java.lang.reflect.Field;



// Internal "logical data types" we understand.
static final int _UNKNOWN_TYPE	= 0;
static final int _INT_TYPE 		= 1;
static final int _FLOAT_TYPE 	= 2;
static final int _BOOLEAN_TYPE 	= 3;
static final int _COLOR_TYPE 	= 4;
static final int _STRING_TYPE 	= 5;



class Config {
	// Set to true to print debugging information if something goes wrong
	//	which would normally be swallowed silently.
	boolean debugging = true;

	String restartConfigFile = "RESTART";

	// Default config file to load if "RESTART" config not found.
	String defaultConfigFile = "PS01";

	// Name of the last config file we loaded.
	String lastConfigFileSaved;

	// constructor
	public Config() {
println("CONFIG INIT");
		this.controllers = new ArrayList<Controller>();

		// Set up our file existance map.
		this.initConfigExistsMap();
	}

////////////////////////////////////////////////////////////
//	Controllers that we're aware of.
////////////////////////////////////////////////////////////
	ArrayList<Controller> controllers;

////////////////////////////////////////////////////////////
//	Sets of fields that we manage
////////////////////////////////////////////////////////////

	// List of "setup" fields.
	// These will be loaded/saved in "config/setup.config" and will be loaded
	//	BEFORE initialization begins (so you can have dynamic screen size, etc).
	String[] SETUP_FIELDS;

	// List of "default" fields.
	// These will be loaded/saved in "config/defaults.config" and will be loaded
	//	at startup BEFORE the "main" config file is loaded.
	// Put your "MIN_" and "MAX_" constants in here.
	String[] DEFAULT_FIELDS;

	// Names of all of our "normal" configuration fields.
	// These are what are actually saved per each configuration.
	String[] FIELDS;


////////////////////////////////////////////////////////////
//	Config file path.  Use  `getFilePath()` to get the full path.
//	as:  <filepath>/<filename>.tsv
////////////////////////////////////////////////////////////

	// Path to ALL config files for this type, local to sketch directory.
	// The path will be created if necessary.
	// YOU MUST include the trailing slash.
	String filepath = "config/";


	// Prefix for "normal" config files.
	String normalFilePrefix = "PS";

	// Extension (including period) for all files of this type.
	String configExtension = ".tsv";

	// Number of "normal" configs we support in this config.
	int maxNormalConfigCount = 100;

	// Return the full path for a given config file instance.
	// If you pass `_fileName`, we'll use that.
	// Returns `null` if no filename specified.
	public String getFilePath() {
		return this.getFilePath(null);
	}
	public String getFilePath(String _fileName) {
		if (_fileName == null) _fileName = this.defaultConfigFile;
		if (_fileName == null) {
			this.error("ERROR in config.getFilePath(): no filename specified.");
			return null;
		}
		return filepath + _fileName + configExtension;
	}

	// Return the full path to a "normal" file given an integer index.
	public String getFilePath(int configFileIndex) {
		String fileName = this.getFileName(configFileIndex);
		return this.getFilePath(fileName);
	}

	// Return the FILE NAME to a "normal" file given an integer index
	//	WITHOUT THE EXTENSION!!!
	// NOTE: the base implementation assumes we have 2-digit file indexing.
	//			override this in your subclass if that's not the case!
	public String getFileName(int configFileIndex) {
		return normalFilePrefix + String.format("%02d", configFileIndex);
	}

	// Return the index associated with a "normal" config file name.
	// Returns -1 if it doesn't match our normal config naming pattern.
	public int getFileIndex(String fileName) {
		if (!fileName.startsWith(normalFilePrefix)) return -1;
		// reduce down to just numbers
		String stringValue = fileName.replaceAll( "[^\\d]", "" );
		return Integer.parseInt(stringValue, 10);
	}

////////////////////////////////////////////////////////////
//	Dealing with change.
////////////////////////////////////////////////////////////

	// Tell the controller(s) about the state of all of our FIELDs.
	public void syncControllers() {
		println("-------------------------");
		println("SYNC");
		println("-------------------------");
		// get normal fields
		Table table = this.getFieldsAsTable(FIELDS);
		// add setup fields as well
		this.getFieldsAsTable(SETUP_FIELDS, table);
		// now signal that all of those fields have changed
		this.fieldsChanged(table);
		// Notify that we're synchronized.
		if (gController != null) {
			gController.sync();
		}
	}

	// One of our fields has changed.
	// Tell all of our controllers.
	public void fieldChanged(String fieldName, String typeName, String currentValueString) {
		Field field = this.getField(fieldName, "fieldChanged("+fieldName+"): field not found");
		this.fieldChanged(field, typeName, currentValueString);
	}
	public void fieldChanged(Field field, String typeName, String currentValueString) {
		if (field == null) return;
		for (Controller controller : this.controllers) {
			try {
				float controllerValue = this.valueForController(field, controller.minValue, controller.maxValue);
				controller.onFieldChanged(field.getName(), controllerValue, typeName, currentValueString);
			} catch (Exception e) {
				this.warn("fieldChanged("+field.getName()+") exception setting controller value", e);
			}
		}
	}

	// A bunch of fields have changed.
	// Tell all of our controllers.
	public void fieldsChanged(Table changeLog) {
		for (TableRow row : changeLog.rows()) {
			this.fieldChanged(row.getString("field"), row.getString("type"), row.getString("value"));
		}
	}

	// Record a change to a field in our changeLog.
	// If no changeLog found, we'll call `fieldChanged()` immediately.
	public void recordChange(Field field, String typeName, String currentValueString, Table changeLog) {
		if (changeLog != null) {
			TableRow row = changeLog.addRow();
			row.setString("field", field.getName());
			row.setString("type" , typeName);
			row.setString("value", currentValueString);
		} else {
			this.fieldChanged(field, typeName, currentValueString);
		}
	}

	// Echo the current state of our FIELDS to the output.
	public void echo() {
		this.echo(this.getFieldsAsTable(this.FIELDS, null));
	}
	public void echo(Table table) {
//TODO...
	}


////////////////////////////////////////////////////////////
//	Dealing with controllers and messages from controllers.
////////////////////////////////////////////////////////////
	public void addController(Controller controller) {
		this.controllers.add(controller);
	}
	public void removeController(Controller controller) {
		this.controllers.remove(controller);
	}


////////////////////////////////////////////////////////////
//	Setting values as they come from the controller.
////////////////////////////////////////////////////////////

	public void setFromController(String fieldName, float controllerValue, float controllerMin, float controllerMax) {
		Field field = this.getField(fieldName, "setFromController({{fieldName}}): field not found");
		if (field != null) this.setFromController(field, controllerValue, controllerMin, controllerMax);
	}

	public void setFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		try {
			int type = this.getType(field);
			switch (type) {
				case _INT_TYPE:		this.setIntFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _FLOAT_TYPE:	this.setFloatFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _BOOLEAN_TYPE:	this.setBooleanFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _COLOR_TYPE:	this.setColorFromController(field, controllerValue, controllerMin, controllerMax); return;
				default:			break;
			}
		} catch (Exception e) {
			this.warn("setFromController("+field.getName()+"): exception setting field value", e);
		}
	}

	// Set internal integer value from controller value.
	public void setIntFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		int configMin, configMax, newValue;
		// try to get min/max from variables and use that to scale the value.
		try {
			configMin = this.getInt("MIN_"+field.getName());
			configMax = this.getInt("MAX_"+field.getName());
			newValue = (int) map(controllerValue, controllerMin, controllerMax, configMin, configMax);
		}
		// if that didn't work, just coerce to an int
		catch (Exception e) {
			newValue = (int) controllerValue;
		}
		this.debug("setIntFromController("+field.getName()+"): setting to "+newValue);
		this.setInt(field, newValue);
	}


	// Set internal float value from controller value.
	public void setFloatFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		float configMin, configMax, newValue;
		// try to get min/max from variables and use that to scale the value.
		try {
			configMin = this.getFloat("MIN_"+field.getName());
			configMax = this.getFloat("MAX_"+field.getName());
			newValue = map(controllerValue, controllerMin, controllerMax, configMin, configMax);
		}
		// if that didn't work, just coerce to an int
		catch (Exception e) {
			newValue = controllerValue;
		}
		this.debug("setFloatFromController("+field.getName()+"): setting to "+newValue);
		this.setFloat(field, newValue);
	}

	// Set internal boolean value from controller value.
	public void setBooleanFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		boolean newValue = controllerValue != 0;
		this.debug("setBooleanFromController("+field.getName()+"): setting to "+newValue);
		this.setBoolean(field, newValue);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	public void setColorFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		float theHue = map(controllerValue, controllerMin, controllerMax, 0, 1);
		int newValue = this.colorFromHue(theHue);
		this.debug("setColorFromController("+field.getName()+"): setting to "+this.colorToString(newValue));
		this.setColor(field, newValue);
	}

	public void setColorFromController(String fieldName, int newValue) {
		Field field = this.getField(fieldName, "setColorFromController({{fieldName}}): field not found");
		if (field == null) return;
		this.debug("setColorFromController("+field.getName()+"): setting to "+this.colorToString(newValue));
		this.setColor(field, newValue);
	}


////////////////////////////////////////////////////////////
//	Getting values to send to the controller as floats. (???)
////////////////////////////////////////////////////////////


	public float valueForController(String fieldName, float controllerMin, float controllerMax) throws Exception {
		Field field = this.getField(fieldName, "valueForController({{fieldName}}): field not found");
		return this.valueForController(field, controllerMin, controllerMax);
	}
	public float valueForController(Field field, float controllerMin, float controllerMax) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		int type = this.getType(field);
		switch (type) {
			case _INT_TYPE:		return this.intForController(field, controllerMin, controllerMax);
			case _FLOAT_TYPE:	return this.floatForController(field, controllerMin, controllerMax);
			case _BOOLEAN_TYPE:	return this.booleanForController(field, controllerMin, controllerMax);
			case _COLOR_TYPE:	return this.colorForController(field, controllerMin, controllerMax);
			default:			this.warn("valueForController("+field.getName()+"): type not understood");
		}
		throw new NoSuchFieldException();
	}

	// Return internal integer field value as a float, scaled for our controller.
	public float intForController(Field field, float controllerMin, float controllerMax) throws Exception {
		float currentValue = (float) this.getInt(field);
		// attempt to map to MIN_ and MAX_ for control
		try {
			int configMin, configMax;
			configMin = this.getInt("MIN_"+field.getName());
			configMax = this.getInt("MAX_"+field.getName());
			// if we can find them, coerce the value
			currentValue = map((float)currentValue, configMin, configMax, controllerMin, controllerMax);
		} catch (Exception e) {/* eat this error */}

		return currentValue;
	}

	// Return internal float field value as a float, scaled for our controller.
	public float floatForController(Field field, float controllerMin, float controllerMax) throws Exception {
		float currentValue = this.getFloat(field);
		// attempt to get min and max
		try {
			float configMin, configMax;
			configMin = this.getFloat("MIN_"+field.getName());
			configMax = this.getFloat("MAX_"+field.getName());
			// if we can find them, coerce the value
			currentValue = map(currentValue, configMin, configMax, controllerMin, controllerMax);
		} catch (Exception e) {	/* eat this error */}
		return currentValue;
	}

	// Return internal boolean field value as a float, scaled for our controller.
	public float booleanForController(Field field, float controllerMin, float controllerMax) throws Exception {
		boolean isTrue = this.getBoolean(field);
		return (isTrue ? controllerMax : controllerMin);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	// Return internal color field value as a float, scaled for our controller.
	public float colorForController(Field field, float controllerMin, float controllerMax) throws Exception {
		int clr = this.getColor(field);
		return this.hueFromColor(clr);
	}



////////////////////////////////////////////////////////////
//	Loading from disk and parsing.
////////////////////////////////////////////////////////////

	public Table loadAll() {
		// load our setup fields
		this.loadSetup();

		// load our defaults
// MOW: NOTE -- there's no reason to load/save defaults to a file
//				as we can just
//		this.loadDefaults();

		// attempt to load our "RESTART" file if it exists
		if (this.configFileExists(this.restartConfigFile)) {
			this.load(this.restartConfigFile);
		} else {
			this.load(this.defaultConfigFile);
		}

		return null;
	}

	// Load our "main" configuration from data stored on disk.
	// If you pass `_fileName`, we'll load from that file and remember as our `filename` for later.
	// If you pass null, we'll use our stored `filename`.
	// Returns `changeLog` Table of actual changed values.
	public Table load() {
		return this.load(null);
	}
	public Table load(String _fileName) {
		// remember filename if passed in
		if (_fileName != null) {
			// save current setup config
			this.saveSetup();
		}
		return this.loadFromFile(_fileName);
	}

	// Load our setup file from disk.
//	Table loadDefaults() {
//		return this.loadFromFile("defaults");
//	}

	// Load our defaults from disk.
	public Table loadSetup() {
		return this.loadFromFile("setup");
	}


	// Load ANY configuration file from data stored on disk.
	// Returns `changeLog` Table of actual changed values.
	public Table loadFromFile(String _fileName) {
		String path = this.getFilePath(_fileName);
		if (path == null) {
			this.error("ERROR in config.loadFromConfigFile(): no filename specified");
			return null;
		}

		this.debug("Loading from '"+path+"'");
		// load as a .tsv file with loadTable()
		Table inputTable;
		try {
			inputTable = loadTable(path, "header,tsv");
		} catch (Exception e) {
			this.warn("loadFromFile('"+path+"'): couldn't load table file.  Does it exist?", e);
			return null;
		}

//		this.debug("Values before load:");
//		if (this.debugging) this.echo();

		// make a table to hold changes found while setting values
		Table changeLog = makeFieldTable();

		// iterate through our inputTable, updating our fields
		for (TableRow row : inputTable.rows()) {
			String fieldName = row.getString("field");
			String value 	 = row.getString("value");
			String typeHint	 = row.getString("type");
			this.setField(fieldName, value, typeHint, changeLog);
		}

		// update all controllers with the current value for all FIELDS
		this.syncControllers();

		return changeLog;
	}



	// Parse a single field/value pair from our config file and update the corresponding value.
	// Eats all exceptions.
	public void setField(String fieldName, String stringValue) { this.setField(fieldName, stringValue, null, null); }
	public void setField(String fieldName, String stringValue, String typeHint) { this.setField(fieldName, stringValue, typeHint, null); }
	public void setField(String fieldName, String stringValue, String typeHint, Table changeLog) {
		Field field = this.getField(fieldName, "setField({{fieldName}}): field not found");
		this.setField(field, stringValue, typeHint, changeLog);
	}

	public void setField(Field field, String stringValue) { this.setField(field, stringValue, null, null);	}
	public void setField(Field field, String stringValue, String typeHint) { this.setField(field, stringValue, null, null);	}
	public void setField(Field field, String stringValue, String typeHint, Table changeLog) {
		int type = this.getType(field, typeHint);
		switch (type) {
			case _INT_TYPE:		this.setInt(field, stringValue, changeLog); return;
			case _FLOAT_TYPE:	this.setFloat(field, stringValue, changeLog); return;
			case _BOOLEAN_TYPE:	this.setBoolean(field, stringValue, changeLog); return;
			case _COLOR_TYPE:	this.setColor(field, stringValue, changeLog); return;
			case _STRING_TYPE:	this.setString(field, stringValue, changeLog); return;
			default:			break;
		}
	}


	// Set an integer field to a string value or an integer value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	public void setInt(String fieldName, String stringValue) { this.setInt(fieldName, stringValue, null); }
	public void setInt(Field field, int newValue) { this.setInt(field, newValue, null); }
	public void setInt(String fieldName, int newValue) {
		Field field = this.getField(fieldName, "setInt({{fieldName}}): field not found.");
		this.setInt(field, newValue, null);
	}
	public void setInt(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setInt({{fieldName}}): field not found.");
		this.setInt(field, stringValue, changeLog);
	}
	public void setInt(Field field, String stringValue, Table changeLog) {
		try {
			int newValue = this.stringToInt(stringValue);
			this.setInt(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setInt("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	public void setInt(Field field, int newValue, Table changeLog) {
		if (field == null) return;
		try {
			// attempt to pin to min value but ignore it if we can't find a MIN_XXX field
			try {
				int configMin = this.getInt("MIN_"+field.getName());
				if (newValue < configMin) newValue = configMin;
			} catch (Exception e){}
			// attempt to pin to max value but ignore it if we can't find a MAX_XXX field
			try {
				int configMax = this.getInt("MAX_"+field.getName());
				if (newValue > configMax) newValue = configMax;
			} catch (Exception e){}

			// only continue if we're actually changing the value
			int oldValue = this.getInt(field);
			if (oldValue != newValue) {
				field.setInt(this, newValue);
				this.recordChange(field,  this.getTypeName(_INT_TYPE), this.intFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setInt("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}


	// Set an float field to a string value or an float value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	public void setFloat(String fieldName, String stringValue) { this.setFloat(fieldName, stringValue, null); }
	public void setFloat(Field field, float newValue) { this.setFloat(field, newValue, null); }
	public void setFloat(String fieldName, float newValue) {
		Field field = this.getField(fieldName, "setFloat({{fieldName}}): field not found.");
		this.setFloat(field, newValue, null);
	}
	public void setFloat(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setFloat({{fieldName}}): field not found.");
		this.setFloat(field, stringValue, changeLog);
	}
	public void setFloat(Field field, String stringValue, Table changeLog) {
		try {
			float newValue = this.stringToFloat(stringValue);
			this.setFloat(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setFloat("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	public void setFloat(Field field, float newValue, Table changeLog) {
		if (field == null) return;
		try {
			// attempt to pin to min value but ignore it if we can't find a MIN_XXX field
			try {
				float configMin = this.getFloat("MIN_"+field.getName());
				if (newValue < configMin) newValue = configMin;
			} catch (Exception e){}
			// attempt to pin to max value but ignore it if we can't find a MAX_XXX field
			try {
				float configMax = this.getFloat("MAX_"+field.getName());
				if (newValue > configMax) newValue = configMax;
			} catch (Exception e){}

			// only record a change if the value is actually different
			float oldValue = this.getFloat(field);
			if (oldValue != newValue) {
				field.setFloat(this, newValue);
				this.recordChange(field,  this.getTypeName(_FLOAT_TYPE), this.floatFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setFloat("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}



	// Set a boolean field to a string value or an boolean value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	public void setBoolean(String fieldName, String stringValue) { this.setBoolean(fieldName, stringValue, null); }
	public void setBoolean(Field field, boolean newValue) { this.setBoolean(field, newValue, null); }
	public void setBoolean(String fieldName, boolean newValue) {
		Field field = this.getField(fieldName, "setBoolean({{fieldName}}): field not found.");
		this.setBoolean(field, newValue, null);
	}
	public void setBoolean(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setBoolean({{fieldName}}): field not found.");
		this.setBoolean(field, stringValue, changeLog);
	}
	public void setBoolean(Field field, String stringValue, Table changeLog) {
		try {
			boolean newValue = this.stringToBoolean(stringValue);
			this.setBoolean(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setBoolean("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	public void setBoolean(Field field, boolean newValue, Table changeLog) {
		if (field == null) return;
		try {
			boolean oldValue = this.getBoolean(field);
			if (oldValue != newValue) {
				field.setBoolean(this, newValue);
				this.recordChange(field,  this.getTypeName(_BOOLEAN_TYPE), this.booleanFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setBoolean("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}


	// Set a color field to a string value or an color value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	public void setColor(String fieldName, String stringValue) { this.setColor(fieldName, stringValue, null); }
	public void setColor(Field field, int newValue) { this.setColor(field, newValue, null); }
	public void setColor(String fieldName, int newValue) {
		Field field = this.getField(fieldName, "setColor({{fieldName}}): field not found.");
		this.setColor(field, newValue, null);
	}
	public void setColor(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setColor({{fieldName}}): field not found.");
		this.setColor(field, stringValue, changeLog);
	}
	public void setColor(Field field, String stringValue, Table changeLog) {
		try {
			int newValue = this.stringToColor(stringValue);
			this.setColor(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setColor("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	public void setColor(Field field, int newValue, Table changeLog) {
		if (field == null) return;
		try {
			int oldValue = this.getColor(field);
			if (oldValue != newValue) {
				field.setInt(this, (int)newValue);
				this.recordChange(field,  this.getTypeName(_BOOLEAN_TYPE), this.colorFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setColor("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}



	// Set a String field to a string value or an String value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	public void setString(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setString({{fieldName}}): field not found.");
		this.setString(field, stringValue, changeLog);
	}
	public void setString(Field field, String newValue, Table changeLog) {
		if (field == null) return;
		try {
			String oldValue = this.getString(field);
			if (oldValue != newValue) {
				field.set(this, newValue);
				this.recordChange(field,  this.getTypeName(_BOOLEAN_TYPE), this.stringFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setString("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}



////////////////////////////////////////////////////////////
//	Saving to disk.
////////////////////////////////////////////////////////////

	// Save the FIELDS in our current config to a file.
	// If you pass `_fileName`, we'll use that file (and remember it for later).
	// Otherwise we'll save to the current filename.
	// Returns a Table with the data as it was saved.
	public Table save() {
		return this.save(null);
	}
	public Table save(String _fileName) {
		if (_fileName != null) this.lastConfigFileSaved = _fileName;
//println("SAVING "+_fileName);
		return this.saveToFile(this.lastConfigFileSaved, this.FIELDS);
	}

	// Save our current state so we'll restart in the same place.
	public Table saveRestartState() {
//println("SAVING RESTART STATE");
		return this.saveToFile(this.restartConfigFile, this.FIELDS);
	}

	// Load our defaults from disk.
	public Table saveSetup() {
		return this.saveToFile("setup", this.SETUP_FIELDS);
	}

	// Load our setup file from disk.
//	Table saveDefaults() {
//		return this.saveToFile("defaults", this.DEFAULT_FIELDS);
//	}

	// Save an arbitrary set of fields in our current config to a file.
	// You must pass `_fileName`.
	public Table saveToFile(String _fileName, String[] fields) {
		String path = getFilePath(_fileName);
		if (path == null) {
			this.error("ERROR in config.saveToFile(): no filename specified");
			return null;
		}
		this.debug("Saving to '"+path+"'");

		// update our configExistsMap for this file if it maps to a "normal" file
		int fileIndex = this.getFileIndex(_fileName);
		if (fileIndex > -1) {
			if (fileIndex >= maxNormalConfigCount) {
				println("Warning: saving '"+_fileName+"' which returned index of "+fileIndex);
			} else {
				configExistsMap[fileIndex] = true;
			}
		}

		// Get the data as a table
		Table table = getFieldsAsTable(fields);

		// Write to the file.
		saveTable(table, path);

		// save current setup config
		if (_fileName != null && !_fileName.equals("setup")) this.saveSetup();

		return table;
	}


	// Create a new table for this config class which is set up to go.
	public Table makeFieldTable() {
		Table table = new Table();
		table.addColumn("type");		// field type (eg: "int" or "string" or "color")
		table.addColumn("field");		// name of the field
		table.addColumn("value");		// string value for the field
		return table;
	}

	// Return output for a set of fieldNames as a Table with columns:
	//		"type", "field", "value" (stringified)
	// If you pass a Table, we'll add to that, otherwise we'll create a new one.
	// Eats exceptions.
	public Table getFieldsAsTable(String[] fieldNames) {
		return this.getFieldsAsTable(fieldNames, null);
	}
	public Table getFieldsAsTable(String[] fieldNames, Table table) {
		if (fieldNames == null) fieldNames = this.FIELDS;

		// if we weren't passed a table, create one now
		if (table == null) table = makeFieldTable();
		if (fieldNames == null) return table;

		for (String fieldName : fieldNames) {
			Field field;
			int type;
			String value;
			try {
				// get the field definition
				field = this.getField(fieldName, "getFieldsAsTable(): field {{fieldName}} not found.");

				// get the type of the field
				type = this.getType(field);
				if (type == _UNKNOWN_TYPE) continue;

				value = this.typedFieldToString(field, type);

			} catch (Exception e) {
				this.warn("getFieldsAsTable(): error processing field "+fieldName, e);
				continue;
			}

			// add row up front, we'll remove it in the exception handler if something goes wrong
			TableRow row = table.addRow();
			row.setString("field", fieldName);
			row.setString("type", getTypeName(type));
			row.setString("value", value);
		}
		return table;
	}


////////////////////////////////////////////////////////////
//	Reflection methods
////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////
	//	Getting field definitions.
	////////////////////////////////////////////////////////////

	// Return the Field definition for a named field.
	// Returns null if no field can be found.
	// Swallows all exceptions.
	public Field getField(String fieldName) {
		try {
//TODO: how to genericise this to current class?
			return this.getClass().getDeclaredField(fieldName);
		} catch (Exception e){
			return null;
		}
	}

	// Return the field definition for a named field, printing a debug message if not found.
	//
	// If field cannot be found, we'll:
	//	- print debug message (with "{{fieldName}}" replaced with the name of the field), and
	//	- return null.
	public Field getField(String fieldName, String message) {
		Field field = this.getField(fieldName);
		if (field == null && message != null) {
			this.debug(message.replace("{{fieldName}}", fieldName));
		}
		return field;
	}

	////////////////////////////////////////////////////////////
	//	Getting lists of fields
	////////////////////////////////////////////////////////////
	public String[] expandFieldList(String[] fields) {
		ArrayList<String> output = new ArrayList<String>(100);
		for (String fieldName : fields) {
			if (!fieldName.contains("*")) {
				output.add(fieldName);
			} else {
				String prefix = fieldName.substring(0, fieldName.length()-1);
				this.addFieldNamesStartingWith(prefix, output);
			}
		}
		String[] allFields = output.toArray(new String[output.size()]);
		return allFields;
	}

	// Add field nams declared on us (NOT on supers) which start with a prefix.
	public void addFieldNamesStartingWith(String prefix, ArrayList<String>output) {
		Field[] allFields = this.getClass().getDeclaredFields();
		for (Field field : allFields) {
			String name = field.getName();
			if (name.startsWith(prefix)) output.add(name);
		}
	}


	////////////////////////////////////////////////////////////
	//	Getting "logical" field types.
	////////////////////////////////////////////////////////////

	// Return the "logical" data type for a field, specified by `fieldName` or by `field`,
	//	eg: `_INT_TYPE` or `_FLOAT_TYPE`
	// If you have a `typeHint` (eg: from a tsv file), pass that, it might help.
	// Returns `_UNKNOWN_TYPE` if we can't find the field or it's not a type we understand.
	// Swallows all exceptions.
	public int getType(String fieldName) { return this.getType(getField(fieldName), null); }
	public int getType(String fieldName, String typeHint) { return this.getType(getField(fieldName), typeHint); }
	public int getType(Field field) { return this.getType(field, null); }
	public int getType(Field field, String typeHint) {
		if (field == null) return _UNKNOWN_TYPE;
//TODO: how best to genericise this???  some type of MAP ???
		if (typeHint != null && typeHint.equals("color")) return _COLOR_TYPE;

		Type type = field.getType();
		if (type == Integer.TYPE) {
			// Ugh.  Processing masquerades `color` variables as `int`s.
			// If the field name ends with "Color", assume it's a color.
//TODO: how best to genericise this???
			if (field.getName().endsWith("Color")) return _COLOR_TYPE;
			return _INT_TYPE;
		}
		if (type == Float.TYPE) 	return _FLOAT_TYPE;
		if (type == Boolean.TYPE) 	return _BOOLEAN_TYPE;
//try {
//	static final Class<?> _STRING_CLASS = Class.forName("String");
//} catch (Exception e) {
//	println("ERROR: can't get string class!");
//}

		if (type == "".getClass())	return _STRING_TYPE;
		return _UNKNOWN_TYPE;
	}

	// Return our logical 'name' for each `type`.
	public String getTypeName(int type) {
		switch(type) {
			case _INT_TYPE:		return "int";
			case _FLOAT_TYPE:	return "float";
			case _BOOLEAN_TYPE:	return "boolean";
			case _COLOR_TYPE:	return "color";
			case _STRING_TYPE:	return "string";
			default:			return "UNKNOWN";
		}
	}


////////////////////////////////////////////////////////////
//	Return internal value for a given field, specified by field name or Field.
// 	They will throw:
//		- `NoSuchFieldException` if no field found with that name, or
//		- `IllegalArgumentException` if we can't parse the value.
////////////////////////////////////////////////////////////

	public int getInt(String fieldName) throws Exception {return this.getInt(getField(fieldName));}
	public int getInt(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getInt(this);
	}
	public float getFloat(String fieldName) throws Exception {return this.getFloat(getField(fieldName));}
	public float getFloat(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getFloat(this);
	}
	public boolean getBoolean(String fieldName) throws Exception {return this.getBoolean(getField(fieldName));}
	public boolean getBoolean(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getBoolean(this);
	}
	public int getColor(String fieldName) throws Exception {return this.getColor(getField(fieldName));}
	public int getColor(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (int)field.getInt(this);
	}
	public String getString(String fieldName) throws Exception {return this.getString(getField(fieldName));}
	public String getString(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (String) field.get(this);
	}


////////////////////////////////////////////////////////////
//	Return internal values for a given field, returning `defaultValue` on exception.
//	Swallows all exceptions.
////////////////////////////////////////////////////////////

	// Get internal int value.
	public int getInt(String fieldName, int defaultValue) {
		Field field = this.getField(fieldName, "getInt({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getInt(field, defaultValue);
	}
	public int getInt(Field field, int defaultValue) {
		if (field == null) return defaultValue;
		try {
			return field.getInt(this);
		} catch (Exception e) {
			this.warn("getInt("+field.getName()+"): error getting int value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal float value.
	public float getFloat(String fieldName, float defaultValue) {
		Field field = this.getField(fieldName, "getFloat({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getFloat(field, defaultValue);
	}
	public float getFloat(Field field, float defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getFloat(this);
		} catch (Exception e) {
			this.warn("getFloat("+field.getName()+"): error getting float value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal boolean value.
	public boolean getBoolean(String fieldName, boolean defaultValue) {
		Field field = this.getField(fieldName, "getBoolean({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getBoolean(field, defaultValue);
	}
	public boolean getBoolean(Field field, boolean defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getBoolean(this);
		} catch (Exception e) {
			this.warn("getBoolean("+field.getName()+"): error getting boolean value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal color value.
	public int getColor(String fieldName, int defaultValue) {
		Field field = this.getField(fieldName, "getColor({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getColor(field, defaultValue);
	}
	public int getColor(Field field, int defaultValue){
		if (field == null) return defaultValue;
		try {
			return (int) field.getInt(this);
		} catch (Exception e) {
			this.warn("getColor("+field.getName()+"): error getting color value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal string value.
	public String getString(String fieldName, String defaultValue) {
		Field field = this.getField(fieldName, "getString({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getString(field, defaultValue);
	}
	public String getString(Field field, String defaultValue){
		if (field == null) return defaultValue;
		try {
			return (String) field.get(this);
		} catch (Exception e) {
			this.warn("getString("+field.getName()+"): error getting String value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}



////////////////////////////////////////////////////////////
//	Coercing native field value to our string equivalent.
//	Returns `null` on exception.
////////////////////////////////////////////////////////////

	// Return the value for one of our fields, specified by `fieldName` or `field`.
	public String fieldToString(String fieldName) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.fieldToString(field);
	}
	public String fieldToString(String fieldName, int type) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.typedFieldToString(field, type);
	}
	public String fieldToString(Field field) {
		int type = this.getType(field);
		return this.typedFieldToString(field, type);
	}

	// Given a Field record and a corresponding "logical" `type"
	//	return the current value of that field as a String.
	public String typedFieldToString(Field field, int type) {
		if (field == null) return null;
		switch (type) {
			case _INT_TYPE:		return this.intFieldToString(field);
			case _FLOAT_TYPE:	return this.floatFieldToString(field);
			case _BOOLEAN_TYPE:	return this.booleanFieldToString(field);
			case _COLOR_TYPE:	return this.colorFieldToString(field);
			case _STRING_TYPE:	return this.stringFieldToString(field);
			default:
				this.warn("typedFieldToString(field "+field.getName()+" field type '"+type+"' not understood");
		}
		return null;
	}

////////////////////////////////////////////////////////////
//	Coercing native field value to our string equivalent.
//	Returns `null` on exception.
////////////////////////////////////////////////////////////

	// Return string value for integer field.
	public String intFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "intFieldToString({{fieldName}}): field not found.");
		return this.intFieldToString(field);
	}
	public String intFieldToString(Field field) {
		try {
			return this.intToString(this.getInt(field));
		} catch (Exception e) {
			this.warn("intFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for float field.
	public String floatFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "floatFieldToString({{fieldName}}): field not found.");
		return this.floatFieldToString(field);
	}
	public String floatFieldToString(Field field) {
		try {
			return this.floatToString(this.getFloat(field));
		} catch (Exception e) {
			this.warn("floatFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for boolean field.
	public String booleanFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "booleanFieldToString({{fieldName}}): field not found.");
		return this.booleanFieldToString(field);
	}
	public String booleanFieldToString(Field field) {
		try {
			return this.booleanToString(this.getBoolean(field));
		} catch (Exception e) {
			this.warn("booleanFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for color field.
	public String colorFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "colorFieldToString({{fieldName}}): field not found.");
		return this.colorFieldToString(field);
	}
	public String colorFieldToString(Field field) {
		try {
			return this.colorToString(this.getColor(field));
		} catch (Exception e) {
			this.warn("colorFieldToString(field "+field.getName()+"): returning null");
			return null;
		}
	}

	// Return string value for string field.  :-)
	public String stringFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "stringFieldToString({{fieldName}}): field not found.");
		return this.stringFieldToString(field);
	}
	public String stringFieldToString(Field field) {
		try {
			return this.getString(field);
		} catch (Exception e) {
			this.warn("stringFieldToString("+field.getName()+"): returning null");
			return null;
		}
	}




////////////////////////////////////////////////////////////
//	Given a native data type, return the equivalent String value.
//	Returns null on exception.
////////////////////////////////////////////////////////////

	// Return string value for integer.
	public String intToString(int value) {
		return ""+value;
	}

	// Return string value for float field.
	public String floatToString(float value) {
		return ""+value;
	}

	// Return string value for boolean value.
	public String booleanToString(boolean value) {
		return (value ? "true" : "false");
	}

	// Return string value for color value.
	public String colorToString(int value) {
		try {
			return "color("+(int)red(value)+","+(int)green(value)+","+(int)blue(value)+","+(int)alpha(value)+")";
		} catch (Exception e) {
			this.warn("ERROR in colorToString("+value+"): returning null", e);
			return null;
		}
	}

	// Return string value for string (base case).
	public String stringToString(String string) {
		return string;
	}





////////////////////////////////////////////////////////////
//	Given a String representation of a native data type,
//		return the equivalent data type.
//	Returns throws on exception.
////////////////////////////////////////////////////////////

	public int stringToInt(String stringValue) throws Exception {
		return PApplet.parseInt(stringValue);
	}

	public float stringToFloat(String stringValue) throws Exception {
		return PApplet.parseFloat(stringValue);
	}

	public boolean stringToBoolean(String stringValue) throws Exception {
		return (stringValue.equals("true") ? true : false);
	}

	public int stringToColor(String stringValue) throws Exception {
		String[] colorMatch = match(stringValue, "[color|rgba]\\((\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\)");
		if (colorMatch == null) throw new Exception();	// TODO: more specific...
// TODO: variable # of arguments
// TODO: #FFCCAA
		int r = PApplet.parseInt(colorMatch[1]);
		int g = PApplet.parseInt(colorMatch[2]);
		int b = PApplet.parseInt(colorMatch[3]);
		int a = PApplet.parseInt(colorMatch[4]);
//		this.debug("parsed color color("+r+","+g+","+b+","+a+")");
		return color(r,g,b,a);
	}



////////////////////////////////////////////////////////////
//	Color utilities.
////////////////////////////////////////////////////////////

	// Given a hue of 0..1, return a fully saturated color().
	// NOTE: assumes we're normally in RGB mode
	public int colorFromHue(float hue) {
		// switch to HSB color mode
		colorMode(HSB, 1.0f);
		int clr = color(hue, 1, 1);
		// restore RGB color mode
		colorMode(RGB, 255);
		return clr;
	}

	// Given a color, return its hue as 0..1.
	// NOTE: assumes we're normally in RGB mode
	public float hueFromColor(int clr) {
		// switch to HSB color mode
		colorMode(HSB, 1.0f);
		float result = hue(clr);
		// restore RGB color mode
		colorMode(RGB, 255);
		return result;
	}



////////////////////////////////////////////////////////////
//	Reflection for our config files on disk.
////////////////////////////////////////////////////////////
	// Array of boolean values for whether config files actually exist on disk.
	boolean[] configExistsMap;

	// Initialize our configExistsMap map.
	public void initConfigExistsMap() {
		configExistsMap = new boolean[maxNormalConfigCount];
		for (int i = 0; i < this.maxNormalConfigCount; i++) {
			configExistsMap[i] = this.configFileExists(i);
		}
	}

	public boolean configFileExists(int index) {
		// get local path (relative to sketch)
		String localPath = this.getFilePath(index);
		return this.configPathExists(localPath);
	}

	public boolean configFileExists(String name) {
		String localPath = this.getFilePath(name);
		return this.configPathExists(localPath);
	}

	public boolean configPathExists(String localPath) {
		// use sketchPath to convert to full path
		String path = sketchPath(localPath);
		return new File(path).exists();
	}

////////////////////////////////////////////////////////////
//	Debugging and error handling.
////////////////////////////////////////////////////////////

	// Log a debug message -- something unexpected happened, but no biggie.
	public void debug(String message) {
		if (this.debugging) println(message);
	}


	// Log a warning message -- something unexpected happened, but it's not fatal.
	public void warn(String message) {
		this.warn(message, null);
	}

	public void warn(String message, Exception e) {
		if (!this.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  WARNING: " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}

	// Log an error message -- something unexpected happened, and it's pretty bad.
	public void error(String message) {
		this.error(message, null);
	}

	public void error(String message, Exception e) {
		if (!this.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  ERROR!!:   " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}


}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Simple Controller class, to go with Config.
////////////////////////////////////////////////////////////

	// TouchOSC


class Controller {
	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;

	public void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {}

	// Return the current SCALED value of our config object from just a field name.
	public float getFieldValue(String fieldName) throws Exception {
		return gConfig.valueForController(fieldName, this.minValue, this.maxValue);
	};

}

class TouchOscController extends Controller {
	OscP5 oscMessenger;

	ArrayList<NetAddress> outboundAddresses;

	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;

	// have we been synced already
	boolean synced = false;

////////////////////////////////////////////////////////////
//	Initial setup.
////////////////////////////////////////////////////////////

	public TouchOscController() {
		outboundAddresses = 	new ArrayList<NetAddress>();
	}

	// create function to recv and parse oscP5 messages
	public void oscEvent(OscMessage message) {
		// Add this message as a controller we'll talk to
		//	by remembering its outbound address.
		this.rememberOutboundAddress(message.netAddress());

		try {
			// get the name of the field being affected, minus the initial slash
			String fieldName = message.addrPattern().substring(1);

			// update the configuration
			this.updateConfig(fieldName, message);

			// tell the controller to save the "RESTART" config
			//	which we'll use to come back to the same state on restart
			gConfig.saveRestartState();
		} catch (Exception e) {}
	}


	// Tell the config object about the message.
	// Override if you need to munge values.
	public void updateConfig(String fieldName, OscMessage message) {
		float value = message.get(0).floatValue();
		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
	}

	// Add an outbound address to the list of addresses that we talk to.
	// OK to call this more than once with the same address.
	public void rememberOutboundAddress(NetAddress inboundAddress) {
		for (NetAddress address : this.outboundAddresses) {
			if (address.address().equals(inboundAddress.address())) return;
		}
		println("******* ADDING ADDRESS "+inboundAddress);
		// convert to the OUTBOUND address
		NetAddress outboundAddress = new NetAddress(inboundAddress.address(), gConfig.setupOscOutboundPort);
		this.outboundAddresses.add(outboundAddress);
		// tell the config to update all controllers (including us) with the current values
		gConfig.syncControllers();
	}


////////////////////////////////////////////////////////////
//	Sync the current state with gConfig
////////////////////////////////////////////////////////////
	public void sync() {
		// override in your subclass to do anything special
		gController.say("Synced");
	}


////////////////////////////////////////////////////////////
//	Generic send of a prepared message to all controllers.
////////////////////////////////////////////////////////////

	// Send a prepared `message` to the OSCTouch controller.
	// NOTE: if `gOscMasterAddress` hasn't been set up, we'll show a warning and bail.
	// TODO: support many controllers?
	public void sendMessage(OscMessage message) {
		if (this.outboundAddresses.size() == 0) {
			println("osc.sendMessageToController("+message.addrPattern()+"): controller.outboundAddress not set up!  Skipping message.");
		} else {
			for (NetAddress outboundAddress : this.outboundAddresses) {
				try {
					gOscMaster.send(message, outboundAddress);
				} catch (Exception e) {
					println("Exception sending message "+message.addrPattern()+": "+e);
				}
			}
		}
	}






////////////////////////////////////////////////////////////
//	Dealing with changes in the model.
////////////////////////////////////////////////////////////

	// A configuration field has changed.  Tell the controller.
	public void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
// TODO: need some field mapping here...
		this.sendFloat(fieldName, controllerValue);
		this.sendLabel(fieldName, valueLabel);
	}

	public void sendBoolean(String fieldName, boolean value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	public void sendInt(String fieldName, int value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	public void sendInts(String fieldName, int value1, int value2) {
		println("  setting controller "+fieldName+" to "+value1+"/"+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.sendMessage(message);
	}

	public void sendString(String fieldName, String value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	public void sendFloat(String fieldName, float value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	public void sendFloats(String fieldName, float value1, float value2) {
		println("  setting controller "+fieldName+" to "+value1+" "+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.sendMessage(message);
	}

	// Send a series of messages for different choice values, from 0 - maxValues, inclusive.
	public void sendChoice(String fieldName, int value, int maxValues) {
		for (int i = 0; i <= maxValues; i++) {
			this.sendInt(fieldName+"-"+i, (value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	// Send a series of messages for different choice values,
	//	with choices as an array of ints.
	public void sendChoice(String fieldName, int value, int[] choices) {
		for (int i : choices) {
			this.sendFloat(fieldName+"-"+i, (value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	// Combine two values together and send as one composite field.
	public void sendXY(String outputFieldName, String firstFieldName, String secondFieldName) {
		try {
			float x = this.getFieldValue(firstFieldName);
			float y = this.getFieldValue(secondFieldName);
			this.sendFloats(outputFieldName, x, y);
		} catch (Exception e) {
			println("Error in sendXY("+outputFieldName+"): "+e);
		}
	}

	public void togglePresetButton(String presetName, boolean turnOn) {
		this.sendInt("/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Load/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Save/"+presetName, turnOn ? 1 : 0);
	}

	public void sendLabel(String fieldName, String value) {
		println("  sending label "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName+"Label");
		message.add(fieldName+"="+value);
		this.sendMessage(message);
	}

	// Set color of a control.
	// Valid colors are:
	//		"red", "green", "blue", "yellow", "purple",
	//		"gray", "orange", "brown", "pink"
	public void setColor(String fieldName, String value) {
		OscMessage message = new OscMessage("/"+fieldName+"/color");
		message.add(value);
		this.sendMessage(message);
	}

	// Show a named control.
	public void showControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(1);
		this.sendMessage(message);
	}

	// Hide a named control.
	public void hideControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(0);
		this.sendMessage(message);
	}


////////////////////////////////////////////////////////////
//	Talk-back to the user
////////////////////////////////////////////////////////////
	public void say(String msgText) {
		println("  saying "+msgText);
		OscMessage message = new OscMessage("/message");
		message.add(msgText);
		this.sendMessage(message);
	}


////////////////////////////////////////////////////////////
//	Exotic controller types
////////////////////////////////////////////////////////////

	// Return the row associated with an Osc Multi-Toggle control.
	// Throws an exception if the message doesn't conform to your expectations.
	// NOTE: Osc Multi-toggles have the BOTTOM row at 0, and rows start with 1.
	//		 So if you want to convert to TOP-based, starting at 0, do:
	//			`int row = ROWCOUNT - (controller.getMultiToggleRow(message) - 1);`
	//		 or use:
	//			`int row = controller.getZeroBasedRow(message, ROWCOUNT);`
	public int getMultiToggleRow(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return PApplet.parseInt(msgName[2]);
	}

	// Return the column associated with an Osc Multi-Toggle control.
	// Throws an exception if the message doesn't conform to your expectations.
	// NOTE: Osc Multi-toggles have the LEFT-MOST row at 1.
	//		 So if you want to convert to LEFT-based, starting at 0, do:
	//			`int row = COLCOUNT - (controller.getMultiToggleColumn(message) - 1);`
	//		 or use:
	//			`int row = controller.getZeroBasedColumn(message, COLCOUNT);`
	public int getMultiToggleColumn(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return PApplet.parseInt(msgName[3]);
	}


	// Return the zero-based, top-left-counting row associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	public int getZeroBasedRow(OscMessage message, int rowCount) {
		try {
			int bottomBasedRow = this.getMultiToggleRow(message);
			return rowCount - bottomBasedRow;
		} catch (Exception e) {
			return -1;
		}
	}

	// Return the zero-based, top-left-counting column associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	public int getZeroBasedColumn(OscMessage message, int ColCount) {
		try {
			int bottomBasedCol = this.getMultiToggleColumn(message);
			return (bottomBasedCol - 1);
		} catch (Exception e) {
			return -1;
		}
	}



////////////////////////////////////////////////////////////
//	Specific senders
////////////////////////////////////////////////////////////

	// NOTE: multi-toggle is backwards!
	public void showMultiToggle(String control, int row, int col, int maxRows, int maxCols) {
/*
println(control+":"+row+":"+col+":"+maxRows+":"+maxCols);
		OscMessage message = new OscMessage("/"+control);
		for (int r = maxRows; r > 0; r--) {
println("row"+r);
			for (int c = 0; c < maxCols; c++) {
println("col"+c + "    " + (r == row && c == col ? "YES" : ""));
				if (r == row && c == col) {
					message.add(1);
				} else {
					message.add(0);
				}
			}
		}
println("all done!");
*/
	}







}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Handle keypress to adjust parameters
////////////////////////////////////////////////////////////
	public void keyPressed() {
	  println("*** CURRENT FRAMERATE: " + frameRate);

	  // up arrow to move kinect down
	  if (keyCode == UP) {
		gConfig.kinectAngle = constrain(++gConfig.kinectAngle, 0, 30);
		gKinecter.kinect.tilt(gConfig.kinectAngle);
		gConfig.saveSetup();
	  }
	  // down arrow to move kinect down
	  else if (keyCode == DOWN) {
		gConfig.kinectAngle = constrain(--gConfig.kinectAngle, 0, 30);
		gKinecter.kinect.tilt(gConfig.kinectAngle);
		gConfig.saveSetup();
	  }
	  // space bar for settings to adjust kinect depth
	  else if (keyCode == 32) {
		gConfig.showSettings = !gConfig.showSettings;
	  }

	  // 'p' key to echo current parameters
	  else if (key == 'p') {
		gConfig.echo();
	  }


	  // 'a' pressed add to minimum depth
	  else if (key == 'a') {
		gConfig.kinectMinDepth = constrain(gConfig.kinectMinDepth + 10, 0, gKinecter.thresholdRange);
		gConfig.saveSetup();
		println("minimum depth: " + gConfig.kinectMinDepth);
	  }
	  // z pressed subtract to minimum depth
	  else if (key == 'z') {
		gConfig.kinectMinDepth = constrain(gConfig.kinectMinDepth - 10, 0, gKinecter.thresholdRange);
		gConfig.saveSetup();
		println("minimum depth: " + gConfig.kinectMinDepth);
	  }
	  // s pressed add to maximum depth
	  else if (key == 's') {
		gConfig.kinectMaxDepth = constrain(gConfig.kinectMaxDepth + 10, 0, gKinecter.thresholdRange);
		println("maximum depth: " + gConfig.kinectMaxDepth);
	  }
	  // x pressed subtract to maximum depth
	  else if (key == 'x') {
		gConfig.kinectMaxDepth = constrain(gConfig.kinectMaxDepth - 10, 0, gKinecter.thresholdRange);
		println("maximum depth: " + gConfig.kinectMaxDepth);
	  }

	  // toggle showParticles on/off
	  else if (key == 'q') {
		gConfig.showParticles = !gConfig.showParticles;
		println("showing particles: " + gConfig.showParticles);
	  }
	  // toggle showFlowLines on/off
	  else if (key == 'w') {
		gConfig.showFlowLines = !gConfig.showFlowLines;
		println("showing optical flow: " + gConfig.showFlowLines);
	  }
	  // toggle showDepthImage on/off
	  else if (key == 'e') {
		gConfig.showDepthImage = !gConfig.showDepthImage;
		println("showing depth image: " + gConfig.showDepthImage);
	  }
	  // toggle showFade on/off
	  else if (key == 'r') {
		gConfig.showFade = !gConfig.showFade;
		println("showing depth pixels: " + gConfig.showFade);
	  }


	// different blend modes
	  else if (key == '1') {
		gConfig.blendMode = BLEND;
		println("Blend mode: BLEND");
	  }
	  else if (key == '2') {
		gConfig.blendMode = ADD;
		println("Blend mode: ADD");
	  }
	  else if (key == '3') {
		gConfig.blendMode = SUBTRACT;
		println("Blend mode: SUBTRACT");
	  }
	  else if (key == '4') {
		gConfig.blendMode = DARKEST;
		println("Blend mode: DARKEST");
	  }
	  else if (key == '5') {
		gConfig.blendMode = LIGHTEST;
		println("Blend mode: LIGHTEST");
	  }
	  else if (key == '6') {
		gConfig.blendMode = DIFFERENCE;
		println("Blend mode: DIFFERENCE");
	  }
	  else if (key == '7') {
		gConfig.blendMode = EXCLUSION;
		println("Blend mode: EXCLUSION");
	  }
	  else if (key == '7') {
		gConfig.blendMode = MULTIPLY;
		println("Blend mode: MULTIPLY");
	  }
	  else if (key == '8') {
		gConfig.blendMode = SCREEN;
		println("Blend mode: SCREEN");
	  }
	}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *								http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/




////////////////////////////////////////////////////////////
//	Kinect setup (constant for all configs)
////////////////////////////////////////////////////////////

	// size of the kinect, use by optical flow and particles
	int	gKinectWidth=640;
	int gKinectHeight = 480;


class Kinecter {
	Kinect kinect;
	boolean isKinected = false;

	int kAngle	 = gConfig.kinectAngle;
	int thresholdRange = 2047;

	public Kinecter(PApplet parent) {
		try {
			kinect = new Kinect(parent);
			kinect.start();
			kinect.enableDepth(true);
			kinect.tilt(kAngle);

			// the below makes getRawDepth() faster
			kinect.processDepthImage(false);

			isKinected = true;
			println("KINECT IS INITIALISED");
		}
		catch (Throwable t) {
			isKinected = false;
			println("KINECT NOT INITIALISED");
			println(t);
		}
	}

	int lowestMin = 2047;
	int highestMax = 0;
	public void updateKinectDepth() {
		if (!isKinected) return;

		// checks raw depth of kinect: if within certain depth range - color everything white, else black
		gRawDepth = kinect.getRawDepth();
		int lastPixel = gRawDepth.length;
		for (int i=0; i < lastPixel; i++) {
			int depth = gRawDepth[i];

			// if less than min, make it white
			if (depth <= gConfig.kinectMinDepth) {
				gDepthImg.pixels[i] = color(255);	// solid white
				gNormalizedDepth[i] = 255;

			} else if (depth >= gConfig.kinectMaxDepth) {
				gDepthImg.pixels[i] = 0;	// transparent black
				gNormalizedDepth[i] = 0;

			} else {
				int greyScale = (int)map((float)depth, gConfig.kinectMinDepth, gConfig.kinectMaxDepth, 255, 0);

//				if (depth < lowestMin) println("LOWEST: "+(lowestMin = depth)+"::"+greyScale);
//				if (depth > highestMax) println("HIGHEST: "+(highestMax = depth)+"::"+greyScale);

				gDepthImg.pixels[i] = (gConfig.depthImageAsGreyscale ? color(greyScale) : 255);
				gNormalizedDepth[i] = 255;
			}
		}

		// update the thresholded image
		gDepthImg.updatePixels();
	}


	public void quit() {
		if (isKinected) kinect.quit();
	}
}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
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
	int fadeColor = color(0,0,0,255);	// black




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
	float flowfieldPredictionTime = 0.5f;
	float MIN_flowfieldPredictionTime = .1f;
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
	float flowfieldSmoothing = 0.05f;
	float MIN_flowfieldSmoothing = 0.05f;	// NOTE: if this goes to 0, we get NO lines at all!
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
	float particleViscocity = .995f;	//0-1	???
	float MIN_particleViscocity = 0;
	float MAX_particleViscocity = 1;

	// Force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300
	float MIN_particleForceMultiplier = 1;
	float MAX_particleForceMultiplier = 300;

	// How fast to return to the noise after force velocities.
	float particleAccelerationFriction = .75f;	//.001-.999	// WAS: .075
	float MIN_particleAccelerationFriction = .001f;
	float MAX_particleAccelerationFriction = .999f;

	// How fast to return to the noise after force velocities.
	float particleAccelerationLimiter = .35f;	// - .999
	float MIN_particleAccelerationLimiter = .001f;
	float MAX_particleAccelerationLimiter = .999f;

	// Turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008f; // .005 - .3
	float MIN_particleNoiseVelocity = .005f;
	float MAX_particleNoiseVelocity = .3f;



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
	int particleColor		= color(255);



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
	int flowLineColor = color(255, 0, 0, 30);	// RED



////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////

	int depthImageAlpha = 30;
	int MIN_depthImageAlpha 	= 10;
	int MAX_depthImageAlpha 	= 255;

	// color for the depth image.
	// NOTE: NOT CURRENTLY USED.  see
	int depthImageColor = color(0,0,0,255);

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
	public PImage getParticleImage() {
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

/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  TouchOsc controller for JugglingMolecules sketch
////////////////////////////////////////////////////////////

class MolecularController extends TouchOscController {

	boolean saveLock = false;

	public MolecularController() {
		super();
	}


	public void sync() {
		super.sync();
		updateSaverFileGrid();
	}

	// Update the "Saver" grid with the set of files which already exist.
	public void updateSaverFileGrid() {
		this.sendActiveFiles("Saver", gConfig.configExistsMap);
	}

	// Update a multi-toggle control with a set of booleans indicating
	//	whether or not a given set of files exist.
	public void sendActiveFiles(String controlName, boolean[] fileExistsMap) {
		OscMessage message = new OscMessage("/"+controlName);
//		String debug = "/"+controlName;
		for (int col = 0; col < 10; col++) {
			for (int row = 9; row >= 0; row--) {
				int cell = (row*10) + col;
				boolean exists = fileExistsMap[cell];
				if (exists) {
					message.add("1");
//					debug += " 1";
				} else {
					message.add("0");
//					debug += " 0";
				}
			}
		}
//		println("sending message "+debug);
//		message.print();
		this.sendMessage(message);
	}

	// Update the config with messages from OSC.
	// Special stuff to update the config w/weird controls, etc.
	public void updateConfig(String fieldName, OscMessage message) {
		// Load switcher control
		if (fieldName.startsWith("Loader")) {
			println("Loader "+fieldName);
			int row = this.getZeroBasedRow(message, 10);		// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 10);		// TODO: get # cols from config
			String fileName = "PS"+row+col;
			try {
				gConfig.load(fileName);
				this.say("Loaded "+fileName);
// This SHOULD work to tell the Saver which we just selected...
//				this.showMultiToggle("Saver", row, col, 10, 10);
			} catch (Exception e) {
				this.say(" Slot "+fileName+" is empty!");
			}
			return;
		}


		// If they're pressing the "Savelock" button, toggle the `saveLock` state.
		// We'll only save if `saveLock` is true.
		if (fieldName.equals("Savelock")) {
			float value = message.get(0).floatValue();
			this.saveLock = (value == 1);
println("--- saveLock:	" +  (this.saveLock ? "ON" : "OFF"));
			// if saveLock is down, make sure the "Saver" grid is showing the current state.
			if (this.saveLock) {
				this.updateSaverFileGrid();
			}
			return;
		}

		// Save switcher control.
		// Only works if `saveLock == true`.
		if (fieldName.startsWith("Saver")) {
			if (!this.saveLock) {
				println("!!!! YOU MUST PRESS SAVE BUTTON TO SAVE, F0O0O0O0O0O0L!!!!");
				this.say("!!Press SAVE to save!!");
				return;
			}
			println("Saver "+fieldName);
			int row = this.getZeroBasedRow(message, 10);		// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 10);		// TODO: get # cols from config
			String fileName = "PS"+row+col;						// TODO: get "PS" from config
			println("!!! SAVING to "+fileName);
			this.say("Saving "+fileName);
			gConfig.save(fileName);
			this.say("Saved "+fileName);

			// update saver file grid
			this.updateSaverFileGrid();

			return;
		}

		if (fieldName.equals("sync")) {
			gConfig.syncControllers();
			return;
		}
		// Handle screen resolution toggles
// TODO: move into controller base class!!!!
		if (fieldName.startsWith("screenSize")) {
			int row = this.getZeroBasedRow(message, 3);			// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 2);		// TODO: get # cols from config
			int value = (row*2)+col;
			int _width, _height;
			switch (value) {
				case 1:		_width = 1280; _height = 960; break;
				case 2:		_width = 1024; _height = 768; break;
				case 3:		_width = 1280; _height = 800; break;
				case 4:		_width = 1920; _height = 1200; break;
				case 5:		_width = 2560; _height = 1440; break;
				default:	_width = 640; _height = 480; break;
			}
			gConfig.setupWindowWidth = _width;
			gConfig.setupWindowHeight = _height;
			this.say("Restart for "+_width+"x"+_height);
			gConfig.saveSetup();
			return;
		}

		if (fieldName.startsWith("imageIndex/")) {
println(message);
			int row = this.getZeroBasedRow(message, 4);			// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 3);		// TODO: get # cols from config
			int value = (row*3)+col;
			gConfig.setInt("particleImage", value);
			this.say("Changed image to "+value+".jpg");
			return;
		}

		float value = message.get(0).floatValue();


		// Window background hue/greyscale toggle.
		if (fieldName.startsWith("fade")) {
			if (fieldName.startsWith("fadeAlpha")) {
				gConfig.setFromController("fadeAlpha", value, this.minValue, this.maxValue);
				return;
			}

			float _hue;
			if (fieldName.equals("fadeGreyscale")) {
				gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
				_hue = gConfig.hueFromColor(gConfig.fadeColor);
			} else {
				_hue = value;
			}

			int clr;
			if (gConfig.fadeGreyscale) {
				int _grey = (int)map(_hue, 0, 1, 0, 255);
				gConfig.fadeColor = color(_grey);
			} else {
				gConfig.fadeColor = colorFromHue(_hue);
			}
			return;
		}

		// "snapshot" buttons takes a screen shot.
		if (fieldName.equals("snapshot")) {
			snapshot();
			return;
		}


		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerate")) {
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("particleGenerateSpread", value, this.minValue, this.maxValue);
			gConfig.setFromController("particleGenerateRate", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "noise" x/y pad
		if (fieldName.equals("noise")) {
			// x-y pad which returns 2 values
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("noiseStrength", value, this.minValue, this.maxValue);
			gConfig.setFromController("noiseScale", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "particleColorScheme-0", "particleColorScheme-1", etc
		if (fieldName.startsWith("particleColorScheme-")) {
			int mode = PApplet.parseInt(fieldName.replace("particleColorScheme-", ""));
			fieldName = "particleColorScheme";
			value = (float) mode;
		}

		// "blendMode-0", "blendMode-1", etc
		if (fieldName.startsWith("blendMode-")) {
			int mode = PApplet.parseInt(fieldName.replace("blendMode-", ""));
			fieldName = "blendMode";
			value = (float) mode;
		}

		// hue controls.  Note that the config currently expects "Color" to be setting hue value.
		if (fieldName.endsWith("Hue")) {
			fieldName = fieldName.replace("Hue", "") + "Color";
		}


		// generic set from controller
		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);

		// if we changed kinect angle, move the device.
		if (fieldName.startsWith("kinect")) {
			gConfig.saveSetup();
			if (fieldName.equals("kinectAngle")) {
				try {
					int angle = gConfig.getInt("kinectAngle");
					gKinecter.kinect.tilt(angle);

					// remember angle on restart
					gConfig.saveSetup();
				} catch (Exception e){};
			}
		}
	}


	// Special case for fields with special needs.
	public void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		this.sendLabel(fieldName, valueLabel);

		// map "Color" to "Hue"
		if (fieldName.endsWith("Color")) fieldName = fieldName.replace("Color", "Hue");

		// do "specials"

		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerateRate") || fieldName.equals("particleGenerateSpread")) {
			this.sendXY("particleGenerate", "particleGenerateSpread", "particleGenerateRate");
		}

		// "noise" x/y pad
		else if (fieldName.equals("noiseStrength") || fieldName.equals("noiseScale")) {
			this.sendXY("noise", "noiseStrength", "noiseScale");
		}

		// particleColorScheme toggles
		else if (fieldName.equals("particleColorScheme"))	{
			this.sendChoice("particleColorScheme", (int)controllerValue, 3);
			return;
		}

		// blendMode toggles
		else if (fieldName.equals("blendMode")) {
			this.sendChoice("blendMode", (int)controllerValue, gConfig.blendChoices);
			return;
		}

		else if (fieldName.equals("particleImage")) {
			int row = 4 - ((int) (gConfig.particleImage / 3));
			int col = 1 + ((int) (gConfig.particleImage % 3));
println("fieldChanged for pII to "+ gConfig.particleImage+" row="+row+" col="+col);
//			this.sendString("imageIndex/"+row+"/"+col, "f");
			return;
		}

		// fade overlay
		else if (fieldName.startsWith("fade")) {
			this.sendBoolean("fadeGreyscale", gConfig.fadeGreyscale);
			float hueValue;
			try {
				if (gConfig.fadeGreyscale) {
					println("GREYSCALE");
// TODO...
					hueValue = this.getFieldValue("fadeColor");
				} else{
					println("COLOR");
					hueValue = this.getFieldValue("fadeColor");
				}
				this.sendFloat("fadeHue", hueValue);
			} catch (Exception e) {
				println("Exception setting fadeHue: "+e);
			}
		}

		// send the raw value if we haven't returned above
		this.sendFloat(fieldName, controllerValue);
	}

}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/


/**
 * Note from Trent Brooks NoiseInk project:
 * 	MODIFICATIONS TO HIDETOSHI'S OPTICAL FLOW
 * 	modified to use kinect camera image & optimised a fair bit as rgb calculations are not required - still needs work.
 *
 **/

class OpticalFlow {
	// Our configuration object, set in our constructor.
	MolecularConfig config;

	// ParticleManager we interact with, set in our constructor.
	ParticleManager particles;

	// A flow field is a two dimensional array of PVectors
	PVector[][] field;

	int cols, rows; // Columns and Rows
	int resolution; // How large is each "cell" of the flow field

	int avSize; //as;	// window size for averaging (-as,...,+as)
	float df;

	// regression vectors
	float[] fx, fy, ft;
	int regressionVectorLength = 3*9; // length of the vectors

	// internally used variables
	float[] dtr; 				// differentiation by t (red,gree,blue)
	float[] dxr; 				// differentiation by x (red,gree,blue)
	float[] dyr; 				// differentiation by y (red,gree,blue)
	float[] par; 				// averaged grid values (red,gree,blue)
	float[] flowx, flowy; 		// computed optical flow
	float[] sflowx, sflowy; 	// slowly changing version of the flow


	OpticalFlow(MolecularConfig _config, ParticleManager _particles) {
		// remember our configuration object & particle manager
		config = _config;
		particles = _particles;

		// set up resolution of the flow field.
		// NOTE: requires a restart or at least a re-initialization to change this.
		resolution = config.setupFlowFieldResolution;

		// Determine the number of columns and rows based on sketch's width and height
		cols = gKinectWidth/resolution;
		rows = gKinectHeight/resolution;
		field = makePerlinNoiseField(rows, cols);

		avSize = resolution * 2;

		// arrays
		par = new float[cols*rows];
		dtr = new float[cols*rows];
		dxr = new float[cols*rows];
		dyr = new float[cols*rows];
		flowx = new float[cols*rows];
		flowy = new float[cols*rows];
		sflowx = new float[cols*rows];
		sflowy = new float[cols*rows];

		fx = new float[regressionVectorLength];
		fy = new float[regressionVectorLength];
		ft = new float[regressionVectorLength];

		init();
		update();
	}

	public void init() {}

	public void update() {
		difT();
		difXY();
		solveFlow();
	}

	// Calculate average pixel value (r,g,b) for rectangle region
	public float averagePixelsGrayscale(int x1, int y1, int x2, int y2) {
		if (x1 < 0)					x1 = 0;
		if (x2 >= gKinectWidth)		x2 = gKinectWidth - 1;
		if (y1 < 0)					y1 = 0;
		if (y2 >= gKinectHeight)	y2 = gKinectHeight - 1;

		float sum = 0.0f;
		for (int y = y1; y <= y2; y++) {
			for (int i = gKinectWidth * y + x1; i <= gKinectWidth * y+x2; i++) {
				 sum += gNormalizedDepth[i];
			}
		}
		int pixelCount = (x2-x1+1) * (y2-y1+1); // number of pixels

		return sum / pixelCount;
	}

	// extract values from 9 neighbour grids
	public void getNeigboringPixels(float x[], float y[], int i, int j) {
		y[j+0] = x[i+0];
		y[j+1] = x[i-1];
		y[j+2] = x[i+1];
		y[j+3] = x[i-cols];
		y[j+4] = x[i+cols];
		y[j+5] = x[i-cols-1];
		y[j+6] = x[i-cols+1];
		y[j+7] = x[i+cols-1];
		y[j+8] = x[i+cols+1];
	}

	// Solve optical flow at a particular point by least squares (regression analysis)
	public void solveFlowForIndex(int index) {
		float xx, xy, yy, xt, yt;
		float a,u,v,w;

		// prepare covariances
		xx = xy = yy = xt = yt = 0.0f;
		for (int i = 0; i < regressionVectorLength; i++) {
			xx += fx[i]*fx[i];
			xy += fx[i]*fy[i];
			yy += fy[i]*fy[i];
			xt += fx[i]*ft[i];
			yt += fy[i]*ft[i];
		}

		// least squares computation
		a = xx*yy - xy*xy + config.flowfieldRegularization;
		u = yy*xt - xy*yt; // x direction
		v = xx*yt - xy*xt; // y direction

		// write back
		flowx[index] = -2*resolution*u/a; // optical flow x (pixel per frame)
		flowy[index] = -2*resolution*v/a; // optical flow y (pixel per frame)
	}

	public void difT() {
		for (int col = 0; col < cols; col++) {
			int x0 = col * resolution + resolution/2;
			for (int row = 0; row < rows; row++) {
				int y0 = row * resolution + resolution/2;
				int index = row * cols + col;
				// compute average pixel at (x0,y0)
				float avg = averagePixelsGrayscale(x0-avSize, y0-avSize, x0+avSize, y0+avSize);
				// compute time difference
				dtr[index] = avg - par[index]; // red
				// save the pixel
				par[index] = avg;
			}
		}
	}


	// 2nd sweep : differentiations by x and y
	public void difXY() {
		for (int col = 1; col < cols-1; col++) {
			for (int row = 1; row<rows-1; row++) {
				int index = row * cols + col;
				// compute x difference
				dxr[index] = par[index+1] - par[index-1];
				// compute y difference
				dyr[index] = par[index+cols] - par[index-cols];
			}
		}
	}



	// 3rd sweep : solving optical flow
	public void solveFlow() {
		// get time distance between frames at current time
		df = config.flowfieldPredictionTime * config.setupFPS;
		int _lineColor = color(gConfig.flowLineColor, gConfig.flowLineAlpha);
		int _red = color(255,0,0);
		int _green = color(0,255,0);

		// for kinect to window size mapping below
		float normalizedKinectWidth   = 1.0f / ((float) gKinectWidth);
		float normalizedKinectHeight  = 1.0f / ((float) gKinectHeight);
		float kinectToWindowWidth  = ((float) width) * normalizedKinectWidth;
		float kinectToWindowHeight = ((float) height) * normalizedKinectHeight;

		for (int col = 1; col < cols-1; col++) {
			int x0 = col * resolution + resolution/2;
			for (int row = 1; row < rows-1; row++) {
				int y0 = row * resolution + resolution/2;
				int index = row * cols + col;

				// prepare vectors fx, fy, ft
				getNeigboringPixels(dxr, fx, index, 0); // dx grey
				getNeigboringPixels(dyr, fy, index, 0); // dy grey
				getNeigboringPixels(dtr, ft, index, 0); // dt grey

				// solve for (flowx, flowy) such that:
				//	 fx flowx + fy flowy + ft = 0
				solveFlowForIndex(index);

				// smoothing
				sflowx[index] += (flowx[index] - sflowx[index]) * config.flowfieldSmoothing;
				sflowy[index] += (flowy[index] - sflowy[index]) * config.flowfieldSmoothing;

				float u = df * sflowx[index];
				float v = df * sflowy[index];

				// amplitude of the vector
				float a = sqrt(u * u + v * v);

//println ("distance 'a' between 'u' and 'v' = " + a);  //debug: all vectors flowing to the left

				// register new vectors
				if (a >= gConfig.flowfieldMinVelocity) {
					field[col][row] = new PVector(u,v);

					// show optical flow as lines in `flowLineColor`
					if (config.showFlowLines) {
						stroke(_lineColor);
						float startX = width - (((float) x0) * kinectToWindowWidth);
						float startY = ((float) y0) * kinectToWindowHeight;
						float endX	 = width - (((float) (x0+u)) * kinectToWindowWidth);
						float endY	 = ((float) (y0+v)) * kinectToWindowHeight;
//println(startX+","+startY+" : "+endX+","+endY);
						line(startX, startY, endX, endY);

						// draw a red dot at the start point
						stroke(_red);
						rect(startX-1, startY-1, 2, 2);
						// draw a green dot at the end point
						stroke(_green);
						rect(endX-1, endY-1, 2, 2);
					}

					// same syntax as memo's fluid solver (http://memo.tv/msafluid_for_processing)
					float normalizedX = (x0+u) * normalizedKinectWidth;
					float normalizedY = (y0+v) * normalizedKinectHeight;
					float velocityX	= ((x0+u) - x0) * normalizedKinectWidth;
					float velocityY	= ((y0+v) - y0) * normalizedKinectHeight;
					particles.addParticlesForForce(1-normalizedX, normalizedY, -velocityX, velocityY);
				}
			}
		}
	}


	// Look up the vector at a particular world location.
	// Automatically translates into kinect size.
	public PVector lookup(PVector worldLocation) {
		int i = (int) constrain(worldLocation.x / resolution, 0, cols-1);
		int j = (int) constrain(worldLocation.y / resolution, 0, rows-1);
		return field[i][j].get();
	}


}

/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
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
	int clr;

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
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_RAINBOW) {
			if (++gLastParticleHue > 360) gLastParticleHue = 0;
			float nextHue = map(gLastParticleHue, 0, 360, 0, 1);
// NOTE: brightness of .7 so we get jewel tones rather than neon
			clr = colorFromHue(nextHue, 1, .7f);
			clr = color(clr, config.particleAlpha);
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_IMAGE) {
			clr = getParticleImageColor(_x, _y);
		} else {	//if (config.particleColorScheme == gConfig.PARTICLE_COLOR_SCHEME_SAME_COLOR) {
			clr = color(config.particleColor, config.particleAlpha);
		}
	}

	public int getParticleImageColor(float _x, float _y) {
		PImage particleImage = gConfig.getParticleImage();
		// figure out index for this pixel
		int col = (int) map(constrain(_x, 0, width-1), 0, width, 0, particleImage.width);
		int row = (int) map(constrain(_y, 0, height-1), 0, height, 0, particleImage.height);
		int index = (row * particleImage.width) + col;
		// extract the color from the image, which is opaque
		clr = particleImage.pixels[index];
		// add the current alpha
		return addAlphaToColor(clr, config.particleAlpha);
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
	public void render() {
		// apply image color at draw time?
		if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_IMAGE && gConfig.applyParticleImageColorAtDrawTime) {
			clr = getParticleImageColor(location.x, location.y);
		}

		stroke(clr);
		line(prevLocation.x, prevLocation.y, location.x, location.y);
	}
}
/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
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
			float noiseZ = particleId/PApplet.parseFloat(config.particleMaxCount);

			particles[particleId].reset(originX, originY, noiseZ, forceX, forceY);

			// increment counter -- go back to 0 if we're past the end
			particleId++;
			if (particleId >= config.particleMaxCount) particleId = 0;
		}
	}

}

/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Depth image manipulation
////////////////////////////////////////////////////////////

	// Draw the depth image to the screen according to our global config.
	public void drawDepthImage() {
		// skip if alpha is 0
		if (gConfig.depthImageAlpha == 0) return;

		pushStyle();
		pushMatrix();
		int clr = addAlphaToColor(gConfig.depthImageColor, gConfig.depthImageAlpha);
		tint(clr);
		scale(-1,1);	// reverse image to mirrored direction
		image(gDepthImg, 0, 0, -width, height);
		popMatrix();
		popStyle();
	}

/*
	// Draw the raw depth info as a pixel at each coordinate.
	void drawDepthPixels() {
		pushStyle();
		int delta = 2;//gConfig.setupFlowFieldResolution;	// 1;
		for (int row = 0; row < gKinectHeight; row += delta) {
			for (int col = 0; col < gKinectWidth; col += delta) {
				int index = col + (row*gKinectWidth);
				int zAlpha = (int) map((float) gRawDepth[index],0,2047,0,128);
// green
				stroke(0, 128, 0, zAlpha);
				int x = width - (int) map((float)col, 0, gKinectWidth, 0, width);
				int y = 		(int) map((float)row, 0, gKinectHeight, 0, height);
				point(x, y);
			}
		}
		popStyle();
	}
*/

////////////////////////////////////////////////////////////
//	Drawing utilities.
////////////////////////////////////////////////////////////

	// Partially fade the screen by drawing a translucent black rectangle over everything.
	// NOTE: this applies the current blendMode all over everything
	public void fadeScreen(int bgColor, int opacity) {
		pushStyle();
		blendMode(gConfig.blendMode);
		noStroke();
		fill(bgColor, opacity);
		rect(0, 0, width, height);
		blendMode(BLEND);
		popStyle();
	}

	// Show the instruction screen as an overlay.
	public void drawInstructionScreen() {
	  pushStyle();
	  // instructions under depth image in gray box
	  fill(50);
	  int top = height-85;
	  rect(0, top, 640, 85);
	  fill(255);
	  text("Press keys 'a' and 'z' to adjust minimum depth: " + gConfig.kinectMinDepth, 5, top+15);
	  text("Press keys 's' and 'x' to adjust maximum depth: " + gConfig.kinectMaxDepth, 5, top+30);

	  text("> Adjust depths until you get a white silhouette of your whole body with everything else black.", 5, top+55);
	  text("PRESS SPACE TO CONTINUE", 5, top+75);
	  popStyle();
	}




////////////////////////////////////////////////////////////
//	Generic math-ey utilities.
////////////////////////////////////////////////////////////

	// Return a Perlin noise vector field, size of `rows` x `columns`.
	public PVector[][] makePerlinNoiseField(int rows, int cols) {
	  //noiseSeed((int)random(10000));  // TODO???
	  PVector[][] field = new PVector[cols][rows];
	  float xOffset = 0;
	  for (int col = 0; col < cols; col++) {
		float yOffset = 0;
		for (int row = 0; row < rows; row++) {
		  // Use perlin noise to get an angle between 0 and 2 PI
		  float theta = map(noise(xOffset,yOffset),0,1,0,TWO_PI);
		  // Polar to cartesian coordinate transformation to get x and y components of the vector
		  field[col][row] = new PVector(cos(theta),sin(theta));
		  yOffset += 0.1f;
		}
		xOffset += 0.1f;
	  }
	  return field;
	}


	// Given a hue of 0..1, return a fully saturated color().
	// NOTE: assumes we're normally in RGB mode
	public int colorFromHue(float _hue) {
		return colorFromHue(_hue, 1, 1);
	}

	// Given a hue, saturation and brightness of 0..1, return a color.
	// NOTE: assumes we're normally in RGB mode
	public int colorFromHue(float _hue, float _saturation, float _brightness) {
		// switch to HSB color mode
		colorMode(HSB, 1.0f);
		int clr = color(_hue, _saturation, _brightness);
		// restore RGB color mode
		colorMode(RGB, 255);
		return clr;
	}


	// Given a color, return its hue as 0..1.
	// NOTE: assumes we're normally in RGB mode
	public float hueFromColor(int clr) {
		// switch to HSB color mode
		colorMode(HSB, 1.0f);
		float result = hue(clr);
		// restore RGB color mode
		colorMode(RGB, 255);
		return result;
	}


	public int addAlphaToColor(int clr, int alfa) {
		return (clr & 0x00FFFFFF) + (alfa << 24);
	}

////////////////////////////////////////////////////////////
//	Debuggy
////////////////////////////////////////////////////////////

	// Return a color as `rgba(r,g,b,a)`.
	public String echoColor(int clr) {
		return "rgba("+(int)red(clr)+","+(int)green(clr)+","+(int)blue(clr)+","+(int)alpha(clr)+")";
	}

	// Return a boolean as `true` or `false`.
	public String echoBoolean(boolean bool) {
		if (bool) return "true";
		return "false";
	}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "JugglingMolecules" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
