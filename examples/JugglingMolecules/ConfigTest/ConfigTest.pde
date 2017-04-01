/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

import oscP5.*;	// TouchOSC
import netP5.*;	// TouchOSC

////////////////////////////////////////////////////////////
//	Global objects
////////////////////////////////////////////////////////////

	// Configuration object, manipulated by TouchOSC and OmiCron
	MolecularConfig gConfig;

	// TouchOsc controller for our app
	MolecularController gController;

	OscP5 gOscMaster;

// Initialize all of our global objects.
//
// NOTE: We want as much as possible to come from our gConfig object,
//		 which we can dynamically reload.  All config variables
//		 can be overridden except for the `setupXXX` items.
//
void setup() {
	// create the config object
	gConfig = new MolecularConfig();

// TODO... make port come from config
	gOscMaster = new OscP5(this, gConfig.setupOscInboundPort);

	// create and set up our controller
	gController = new MolecularController();
	gConfig.addController(gController);



	// save the configuration!!!
	gConfig.save();

	// save setup and defaults
	gConfig.saveSetup();
	gConfig.saveDefaults();


//	exit();
}


// Our draw loop.
void draw() {}



	////////////////////////////////////////////////////////////
	//	Receiving events from the device.
	////////////////////////////////////////////////////////////

	// create function to recv and parse oscP5 messages
	void oscEvent(OscMessage message) {
		gController.oscEvent(message);
	}
