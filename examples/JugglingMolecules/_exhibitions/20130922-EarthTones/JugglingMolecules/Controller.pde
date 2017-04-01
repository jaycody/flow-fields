/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Simple Controller class, to go with Config.
////////////////////////////////////////////////////////////

import oscP5.*;	// TouchOSC
import netP5.*;

class Controller {
	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;

	void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {}

	// Return the current SCALED value of our config object from just a field name.
	float getFieldValue(String fieldName) throws Exception {
		return gConfig.valueForController(fieldName, this.minValue, this.maxValue);
	};

}

class TouchOscController extends Controller {
	OscP5 oscMessenger;

	ArrayList<NetAddress> outboundAddresses;

	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;


////////////////////////////////////////////////////////////
//	Initial setup.
////////////////////////////////////////////////////////////

	public TouchOscController() {
		outboundAddresses = 	new ArrayList<NetAddress>();
	}

	// create function to recv and parse oscP5 messages
	void oscEvent(OscMessage message) {
		// Add this message as a controller we'll talk to
		//	by remembering its outbound address.
		this.rememberOutboundAddress(message.netAddress());

		try {
			// get the name of the field being affected, minus the initial slash
			String fieldName = message.addrPattern().substring(1);

			// update the configuration
			this.updateConfig(fieldName, message);
		} catch (Exception e) {}
	}


	// Tell the config object about the message.
	// Override if you need to munge values.
	void updateConfig(String fieldName, OscMessage message) {
		float value = message.get(0).floatValue();
		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
	}

	// Add an outbound address to the list of addresses that we talk to.
	// OK to call this more than once with the same address.
	void rememberOutboundAddress(NetAddress inboundAddress) {
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
//	Generic send of a prepared message to all controllers.
////////////////////////////////////////////////////////////

	// Send a prepared `message` to the OSCTouch controller.
	// NOTE: if `gOscMasterAddress` hasn't been set up, we'll show a warning and bail.
	// TODO: support many controllers?
	void sendMessage(OscMessage message) {
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
	void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
// TODO: need some field mapping here...
		this.sendFloat(fieldName, controllerValue);
		this.sendLabel(fieldName, valueLabel);
	}

	void sendBoolean(String fieldName, boolean value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendInt(String fieldName, int value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendFloat(String fieldName, float value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendFloats(String fieldName, float value1, float value2) {
		println("  setting controller "+fieldName+" to "+value1+" "+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.sendMessage(message);
	}

	// Send a series of messages for different choice values, from 0 - maxValue.
	void sendChoice(String fieldName, float value, int maxValue) {
		for (int i = 0; i <= maxValue; i++) {
			this.sendFloat(fieldName+"-"+i, ((int)value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	// Send a series of messages for different choice values,
	//	with choices as an array of ints.
	void sendChoice(String fieldName, float value, int[] choices) {
		for (int i : choices) {
			this.sendFloat(fieldName+"-"+i, ((int)value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	// Combine two values together and send as one composite field.
	void sendXY(String outputFieldName, String firstFieldName, String secondFieldName) {
		try {
			float x = this.getFieldValue(firstFieldName);
			float y = this.getFieldValue(secondFieldName);
			this.sendFloats(outputFieldName, x, y);
		} catch (Exception e) {
			println("Error in sendXY("+outputFieldName+"): "+e);
		}
	}

	void togglePresetButton(String presetName, boolean turnOn) {
		this.sendInt("/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Load/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Save/"+presetName, turnOn ? 1 : 0);
	}

	void sendLabel(String fieldName, String value) {
		println("  sending label "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName+"Label");
		message.add(fieldName+"="+value);
		this.sendMessage(message);
	}




////////////////////////////////////////////////////////////
//	Talk-back to the user
////////////////////////////////////////////////////////////
	void say(String msgText) {
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
//UNTESTED
	int getMultiToggleRow(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return int(msgName[2]);
	}

	// Return the column associated with an Osc Multi-Toggle control.
	// Throws an exception if the message doesn't conform to your expectations.
	// NOTE: Osc Multi-toggles have the LEFT-MOST row at 1.
	//		 So if you want to convert to LEFT-based, starting at 0, do:
	//			`int row = COLCOUNT - (controller.getMultiToggleColumn(message) - 1);`
	//		 or use:
	//			`int row = controller.getZeroBasedColumn(message, COLCOUNT);`
//UNTESTED
	int getMultiToggleColumn(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return int(msgName[3]);
	}


	// Return the zero-based, top-left-counting row associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	int getZeroBasedRow(OscMessage message, int rowCount) {
		try {
			int bottomBasedRow = this.getMultiToggleRow(message);
			return rowCount - bottomBasedRow;
		} catch (Exception e) {
			return -1;
		}
	}

	// Return the zero-based, top-left-counting column associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	int getZeroBasedColumn(OscMessage message, int ColCount) {
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
	void showMultiToggle(String control, int row, int col, int maxRows, int maxCols) {
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