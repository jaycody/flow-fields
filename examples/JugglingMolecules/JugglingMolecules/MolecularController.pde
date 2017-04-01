/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
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


	void sync() {
		super.sync();
		updateSaverFileGrid();
	}

	// Update the "Saver" grid with the set of files which already exist.
	void updateSaverFileGrid() {
		this.sendActiveFiles("Saver", gConfig.configExistsMap);
	}

	// Update a multi-toggle control with a set of booleans indicating
	//	whether or not a given set of files exist.
	void sendActiveFiles(String controlName, boolean[] fileExistsMap) {
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
	void updateConfig(String fieldName, OscMessage message) {
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

			color clr;
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
			int mode = int(fieldName.replace("particleColorScheme-", ""));
			fieldName = "particleColorScheme";
			value = (float) mode;
		}

		// "blendMode-0", "blendMode-1", etc
		if (fieldName.startsWith("blendMode-")) {
			int mode = int(fieldName.replace("blendMode-", ""));
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
					gKinecter.kinect.setTilt(angle);

					// remember angle on restart
					gConfig.saveSetup();
				} catch (Exception e){};
			}
		}
	}


	// Special case for fields with special needs.
	void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
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