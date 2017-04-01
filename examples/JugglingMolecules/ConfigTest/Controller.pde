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

		// get the name of the field being affected, minus the initial slash
		String fieldName = message.addrPattern().substring(1);

		// update the configuration
		this.updateConfig(fieldName, message);

		// save the config back out to the controller
//		this.outputStateToOSCController();
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
		gConfig.updateControllers();
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

	// Send a series of messages for different choice values.
	void sendChoice(String fieldName, float value, int maxValue) {
		for (int i = 0; i <= maxValue; i++) {
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


	void sendLabel(String fieldName, String value) {
		println("  sending label "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName+"Label");
		message.add(fieldName+"="+value);
		this.sendMessage(message);
	}

	// Send a prepared `message` to the OSCTouch controller.
	// NOTE: if `gTouchControllerAddress` hasn't been set up, we'll show a warning and bail.
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

}