/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
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
//	Configurations are stored in ".config" files in Tab-Separated-Value format.
//		We have a header row as 		field<tab>value
//		and then each row of data is 	<field><tab><value>
//										<field><tab><value>
//
//	We can auto-parse these config files using reflection.
//
////////////////////////////////////////////////////////////

//import java.lang.reflect.Field;
import java.lang.reflect.*;


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

	// Should we auto-load our last config file on startoup?
	boolean setupAutoLoadLast = true;

	// Name of the last config file we loaded.
	String setupLastConfigFile = "PS01";

	// constructor
	public Config() {
		this.controllers = new ArrayList<Controller>();

		// load our setup fields
		this.loadSetup();

		// load our defaults
		this.loadDefaults();

		// if our .setupAutoLoadLast is true, load our last config file
		if (this.setupAutoLoadLast && this.setupLastConfigFile != null) {
			this.load(this.setupLastConfigFile);
		}
	}

////////////////////////////////////////////////////////////
//	Controllers that we're aware of.
////////////////////////////////////////////////////////////
	ArrayList<Controller> controllers;

////////////////////////////////////////////////////////////
//	Fields that we manage
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


	// Extension (including period) for all files of this type.
	String extension = ".tsv";


	// Name of this individual config file.
	// This is generally set by `load()`ing or `save()`ing.
	// DO NOT include the path or extension!
	String filename;


	// Return the full path for a given config file instance.
	// If you pass `_filename`, we'll use that.
	// Otherwise we'll use our internal `setupLastConfigFile` (but won't set it).
	// Returns `null` if no filename specified.
	String getFilePath() {
		return this.getFilePath(null);
	}
	String getFilePath(String _filename) {
		if (_filename == null) _filename = this.setupLastConfigFile;
		if (_filename == null) {
			this.error("ERROR in config.getFilePath(): no filename specified.");
			return null;
		}
		return filepath + _filename + extension;
	}


////////////////////////////////////////////////////////////
//	Dealing with change.
////////////////////////////////////////////////////////////

	// Tell the controller(s) about the state of all of our FIELDs.
	void updateControllers() {
		this.updateControllers(null);
	}
	void updateControllers(String[] fieldNames) {
		Table values = this.getFieldsAsTable(fieldNames);
		this.fieldsChanged(values);
	}


	// One of our fields has changed.
	// Tell all of our controllers.
	void fieldChanged(String fieldName, String typeName, String currentValueString) {
		Field field = this.getField(fieldName, "fieldChanged("+fieldName+"): field not found");
		this.fieldChanged(field, typeName, currentValueString);
	}
	void fieldChanged(Field field, String typeName, String currentValueString) {
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
	void fieldsChanged(Table changeLog) {
		for (TableRow row : changeLog.rows()) {
			this.fieldChanged(row.getString("field"), row.getString("type"), row.getString("value"));
		}
	}

	// Record a change to a field in our changeLog.
	// If no changeLog found, we'll call `fieldChanged()` immediately.
	void recordChange(Field field, String typeName, String currentValueString, Table changeLog) {
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
	void echo() {
		this.echo(this.getFieldsAsTable(this.FIELDS, null));
	}
	void echo(Table table) {
//TODO...
	}


////////////////////////////////////////////////////////////
//	Dealing with controllers and messages from controllers.
////////////////////////////////////////////////////////////
	void addController(Controller controller) {
		this.controllers.add(controller);
	}
	void removeController(Controller controller) {
		this.controllers.remove(controller);
	}


////////////////////////////////////////////////////////////
//	Setting values as they come from the controller.
////////////////////////////////////////////////////////////

	void setFromController(String fieldName, float controllerValue, float controllerMin, float controllerMax) {
		Field field = this.getField(fieldName, "setFromController({{fieldName}}): field not found");
		if (field != null) this.setFromController(field, controllerValue, controllerMin, controllerMax);
	}

	void setFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
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
	void setIntFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
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
	void setFloatFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
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
	void setBooleanFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		boolean newValue = controllerValue != 0;
		this.debug("setBooleanFromController("+field.getName()+"): setting to "+newValue);
		this.setBoolean(field, newValue);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	void setColorFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		float theHue = map(controllerValue, controllerMin, controllerMax, 0, 1);
		color newValue = this.colorFromHue(theHue);
		this.debug("setBooleanFromController("+field.getName()+"): setting to "+this.colorToString(newValue));
		this.setColor(field, newValue);
	}


////////////////////////////////////////////////////////////
//	Getting values to send to the controller as floats. (???)
////////////////////////////////////////////////////////////


	float valueForController(String fieldName, float controllerMin, float controllerMax) throws Exception {
		Field field = this.getField(fieldName, "valueForController({{fieldName}}): field not found");
		return this.valueForController(field, controllerMin, controllerMax);
	}
	float valueForController(Field field, float controllerMin, float controllerMax) throws Exception {
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
	float intForController(Field field, float controllerMin, float controllerMax) throws Exception {
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
	float floatForController(Field field, float controllerMin, float controllerMax) throws Exception {
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
	float booleanForController(Field field, float controllerMin, float controllerMax) throws Exception {
		boolean isTrue = this.getBoolean(field);
		return (isTrue ? controllerMax : controllerMin);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	// Return internal color field value as a float, scaled for our controller.
	float colorForController(Field field, float controllerMin, float controllerMax) throws Exception {
		color clr = this.getColor(field);
		return (float) this.hueFromColor(clr);
	}



////////////////////////////////////////////////////////////
//	Loading from disk and parsing.
////////////////////////////////////////////////////////////

	// Load our "main" configuration from data stored on disk.
	// If you pass `_filename`, we'll load from that file and remember as our `filename` for later.
	// If you pass null, we'll use our stored `filename`.
	// Returns `changeLog` Table of actual changed values.
	Table load() {
		return this.load(null);
	}
	Table load(String _filename) {
		// remember filename if passed in
		if (_filename != null) this.setupLastConfigFile = _filename;
		return this.loadFromFile(_filename);
	}

	// Load our setup file from disk.
	Table loadDefaults() {
		return this.loadFromFile("defaults");
	}

	// Load our defaults from disk.
	Table loadSetup() {
		return this.loadFromFile("setup");
	}


	// Load ANY configuration file from data stored on disk.
	// Returns `changeLog` Table of actual changed values.
	Table loadFromFile(String _filename) {
		String path = this.getFilePath(_filename);
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
		this.updateControllers();

		return changeLog;
	}



	// Parse a single field/value pair from our config file and update the corresponding value.
	// Eats all exceptions.
	void setField(String fieldName, String stringValue) { this.setField(fieldName, stringValue, null, null); }
	void setField(String fieldName, String stringValue, String typeHint) { this.setField(fieldName, stringValue, typeHint, null); }
	void setField(String fieldName, String stringValue, String typeHint, Table changeLog) {
		Field field = this.getField(fieldName, "setField({{fieldName}}): field not found");
		this.setField(field, stringValue, typeHint, changeLog);
	}

	void setField(Field field, String stringValue) { this.setField(field, stringValue, null, null);	}
	void setField(Field field, String stringValue, String typeHint) { this.setField(field, stringValue, null, null);	}
	void setField(Field field, String stringValue, String typeHint, Table changeLog) {
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
	void setInt(String fieldName, String stringValue) { this.setInt(fieldName, stringValue, null); }
	void setInt(Field field, int newValue) { this.setInt(field, newValue, null); }
	void setInt(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setInt({{fieldName}}): field not found.");
		this.setInt(field, stringValue, changeLog);
	}
	void setInt(Field field, String stringValue, Table changeLog) {
		try {
			int newValue = this.stringToInt(stringValue);
			this.setInt(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setInt("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	void setInt(Field field, int newValue, Table changeLog) {
		if (field == null) return;
		try {
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
	void setFloat(String fieldName, String stringValue) { this.setFloat(fieldName, stringValue, null); }
	void setFloat(Field field, float newValue) { this.setFloat(field, newValue, null); }
	void setFloat(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setFloat({{fieldName}}): field not found.");
		this.setFloat(field, stringValue, changeLog);
	}
	void setFloat(Field field, String stringValue, Table changeLog) {
		try {
			float newValue = this.stringToFloat(stringValue);
			this.setFloat(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setFloat("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	void setFloat(Field field, float newValue, Table changeLog) {
		if (field == null) return;
		try {
			float oldValue = this.getFloat(field);
			if (oldValue != newValue) {
				field.setFloat(this, newValue);
				this.recordChange(field,  this.getTypeName(_FLOAT_TYPE), this.floatFieldToString(field), changeLog);
			}
		} catch (Exception e) {
			this.warn("setFloat("+field.getName()+"): exception setting value '"+newValue+"'", e);
		}
	}



	// Set an boolean field to a string value or an boolean value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	void setBoolean(String fieldName, String stringValue) { this.setBoolean(fieldName, stringValue, null); }
	void setBoolean(Field field, boolean newValue) { this.setBoolean(field, newValue, null); }
	void setBoolean(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setBoolean({{fieldName}}): field not found.");
		this.setBoolean(field, stringValue, changeLog);
	}
	void setBoolean(Field field, String stringValue, Table changeLog) {
		try {
			boolean newValue = this.stringToBoolean(stringValue);
			this.setBoolean(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setBoolean("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	void setBoolean(Field field, boolean newValue, Table changeLog) {
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


	// Set an color field to a string value or an color value.
	// Returns `true` if we actually changed the value.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	void setColor(String fieldName, String stringValue) { this.setColor(fieldName, stringValue, null); }
	void setColor(Field field, color newValue) { this.setColor(field, newValue, null); }
	void setColor(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setColor({{fieldName}}): field not found.");
		this.setColor(field, stringValue, changeLog);
	}
	void setColor(Field field, String stringValue, Table changeLog) {
		try {
			color newValue = this.stringToColor(stringValue);
			this.setColor(field, newValue, changeLog);
		} catch (Exception e) {
			this.warn("setColor("+field.getName()+"): exception converting string value '"+stringValue+"'", e);
		}
	}
	void setColor(Field field, color newValue, Table changeLog) {
		if (field == null) return;
		try {
			color oldValue = this.getColor(field);
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
	void setString(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setString({{fieldName}}): field not found.");
		this.setString(field, stringValue, changeLog);
	}
	void setString(Field field, String newValue, Table changeLog) {
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
	// If you pass `_filename`, we'll use that file (and remember it for later).
	// Otherwise we'll save to the current filename.
	// Returns a Table with the data as it was saved.
	Table save() {
		return this.save(null);
	}
	Table save(String _filename) {
		if (_filename != null) this.filename = _filename;
		return this.saveToFile(this.filename, this.FIELDS);
	}

	// Load our defaults from disk.
	Table saveSetup() {
		return this.saveToFile("setup", this.SETUP_FIELDS);
	}

	// Load our setup file from disk.
	Table saveDefaults() {
		return this.saveToFile("defaults", this.DEFAULT_FIELDS);
	}

	// Save an arbitrary set of fields in our current config to a file.
	// You must pass `_filename`.
	Table saveToFile(String _filename, String[] fields) {
		String path = getFilePath(_filename);
		if (path == null) {
			this.error("ERROR in config.saveToFile(): no filename specified");
			return null;
		}
		this.debug("Saving to '"+path+"'");

		// Get the data as a table
		Table table = getFieldsAsTable(fields);

		// Write to the file.
		saveTable(table, path);

		return table;
	}


	// Create a new table for this config class which is set up to go.
	Table makeFieldTable() {
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
	Table getFieldsAsTable(String[] fieldNames) {
		return this.getFieldsAsTable(fieldNames, null);
	}
	Table getFieldsAsTable(String[] fieldNames, Table table) {
		if (fieldNames == null) fieldNames = this.FIELDS;

		// if we weren't passed a table, create one now
		if (table == null) table = makeFieldTable();
		if (fieldNames == null) return table;

		for (String fieldName : fieldNames) {
			try {
				// add row up front, we'll remove it in the exception handler if something goes wrong
				TableRow row = table.addRow();

				// get the field definition
				Field field = this.getField(fieldName, "getFieldsAsTable(): field {{fieldName}} not found.");
				row.setString("field", fieldName);

				// get the type of the field
				int type = this.getType(field);
				if (type == _UNKNOWN_TYPE) new NoSuchFieldException();
				row.setString("type", getTypeName(type));

				String value = this.typedFieldToString(field, type);
				row.setString("value", value);

			} catch (Exception e) {
				this.warn("getFieldsAsTable(): error processing field "+fieldName, e);
				// remove the incomplete row
				table.removeRow(table.getRowCount()-1);
			}
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
	Field getField(String fieldName) {
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
	Field getField(String fieldName, String message) {
		Field field = this.getField(fieldName);
		if (field == null && message != null) {
			this.debug(message.replace("{{fieldName}}", fieldName));
		}
		return field;
	}

	////////////////////////////////////////////////////////////
	//	Getting lists of fields
	////////////////////////////////////////////////////////////
	String[] expandFieldList(String[] fields) {
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
	void addFieldNamesStartingWith(String prefix, ArrayList<String>output) {
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
	int getType(String fieldName) { return this.getType(getField(fieldName), null); }
	int getType(String fieldName, String typeHint) { return this.getType(getField(fieldName), typeHint); }
	int getType(Field field) { return this.getType(field, null); }
	int getType(Field field, String typeHint) {
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
	String getTypeName(int type) {
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

	int getInt(String fieldName) throws Exception {return this.getInt(getField(fieldName));}
	int getInt(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getInt(this);
	}
	float getFloat(String fieldName) throws Exception {return this.getFloat(getField(fieldName));}
	float getFloat(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getFloat(this);
	}
	boolean getBoolean(String fieldName) throws Exception {return this.getBoolean(getField(fieldName));}
	boolean getBoolean(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getBoolean(this);
	}
	color getColor(String fieldName) throws Exception {return this.getColor(getField(fieldName));}
	color getColor(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (color)field.getInt(this);
	}
	String getString(String fieldName) throws Exception {return this.getString(getField(fieldName));}
	String getString(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (String) field.get(this);
	}


////////////////////////////////////////////////////////////
//	Return internal values for a given field, returning `defaultValue` on exception.
//	Swallows all exceptions.
////////////////////////////////////////////////////////////

	// Get internal int value.
	int getInt(String fieldName, int defaultValue) {
		Field field = this.getField(fieldName, "getInt({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getInt(field, defaultValue);
	}
	int getInt(Field field, int defaultValue) {
		if (field == null) return defaultValue;
		try {
			return field.getInt(this);
		} catch (Exception e) {
			this.warn("getInt("+field.getName()+"): error getting int value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal float value.
	float getFloat(String fieldName, float defaultValue) {
		Field field = this.getField(fieldName, "getFloat({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getFloat(field, defaultValue);
	}
	float getFloat(Field field, float defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getFloat(this);
		} catch (Exception e) {
			this.warn("getFloat("+field.getName()+"): error getting float value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal boolean value.
	boolean getBoolean(String fieldName, boolean defaultValue) {
		Field field = this.getField(fieldName, "getBoolean({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getBoolean(field, defaultValue);
	}
	boolean getBoolean(Field field, boolean defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getBoolean(this);
		} catch (Exception e) {
			this.warn("getBoolean("+field.getName()+"): error getting boolean value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal color value.
	color getColor(String fieldName, color defaultValue) {
		Field field = this.getField(fieldName, "getColor({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getColor(field, defaultValue);
	}
	color getColor(Field field, color defaultValue){
		if (field == null) return defaultValue;
		try {
			return (color) field.getInt(this);
		} catch (Exception e) {
			this.warn("getColor("+field.getName()+"): error getting color value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal string value.
	String getString(String fieldName, String defaultValue) {
		Field field = this.getField(fieldName, "getString({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getString(field, defaultValue);
	}
	String getString(Field field, String defaultValue){
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
	String fieldToString(String fieldName) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.fieldToString(field);
	}
	String fieldToString(String fieldName, int type) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.typedFieldToString(field, type);
	}
	String fieldToString(Field field) {
		int type = this.getType(field);
		return this.typedFieldToString(field, type);
	}

	// Given a Field record and a corresponding "logical" `type"
	//	return the current value of that field as a String.
	String typedFieldToString(Field field, int type) {
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
	String intFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "intFieldToString({{fieldName}}): field not found.");
		return this.intFieldToString(field);
	}
	String intFieldToString(Field field) {
		try {
			return this.intToString(this.getInt(field));
		} catch (Exception e) {
			this.warn("intFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for float field.
	String floatFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "floatFieldToString({{fieldName}}): field not found.");
		return this.floatFieldToString(field);
	}
	String floatFieldToString(Field field) {
		try {
			return this.floatToString(this.getFloat(field));
		} catch (Exception e) {
			this.warn("floatFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for boolean field.
	String booleanFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "booleanFieldToString({{fieldName}}): field not found.");
		return this.booleanFieldToString(field);
	}
	String booleanFieldToString(Field field) {
		try {
			return this.booleanToString(this.getBoolean(field));
		} catch (Exception e) {
			this.warn("booleanFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for color field.
	String colorFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "colorFieldToString({{fieldName}}): field not found.");
		return this.colorFieldToString(field);
	}
	String colorFieldToString(Field field) {
		try {
			return this.colorToString(this.getColor(field));
		} catch (Exception e) {
			this.warn("colorFieldToString(field "+field.getName()+"): returning null");
			return null;
		}
	}

	// Return string value for string field.  :-)
	String stringFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "stringFieldToString({{fieldName}}): field not found.");
		return this.stringFieldToString(field);
	}
	String stringFieldToString(Field field) {
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
	String intToString(int value) {
		return ""+value;
	}

	// Return string value for float field.
	String floatToString(float value) {
		return ""+value;
	}

	// Return string value for boolean value.
	String booleanToString(boolean value) {
		return (value ? "true" : "false");
	}

	// Return string value for color value.
	String colorToString(color value) {
		try {
			return "color("+(int)red(value)+","+(int)green(value)+","+(int)blue(value)+","+(int)alpha(value)+")";
		} catch (Exception e) {
			this.warn("ERROR in colorToString("+value+"): returning null", e);
			return null;
		}
	}

	// Return string value for string (base case).
	String stringToString(String string) {
		return string;
	}





////////////////////////////////////////////////////////////
//	Given a String representation of a native data type,
//		return the equivalent data type.
//	Returns throws on exception.
////////////////////////////////////////////////////////////

	int stringToInt(String stringValue) throws Exception {
		return int(stringValue);
	}

	float stringToFloat(String stringValue) throws Exception {
		return float(stringValue);
	}

	boolean stringToBoolean(String stringValue) throws Exception {
		return (stringValue.equals("true") ? true : false);
	}

	color stringToColor(String stringValue) throws Exception {
		String[] colorMatch = match(stringValue, "[color|rgba]\\((\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\)");
		if (colorMatch == null) throw new Exception();	// TODO: more specific...
// TODO: variable # of arguments
// TODO: #FFCCAA
		int r = int(colorMatch[1]);
		int g = int(colorMatch[2]);
		int b = int(colorMatch[3]);
		int a = int(colorMatch[4]);
		this.debug("parsed color color("+r+","+g+","+b+","+a+")");
		return color(r,g,b,a);
	}



////////////////////////////////////////////////////////////
//	Color utilities.
////////////////////////////////////////////////////////////

	// Given a hue of 0..1, return a fully saturated color().
	// NOTE: assumes we're normally in RGB mode
	color colorFromHue(float hue) {
		// switch to HSB color mode
		colorMode(HSB, 1.0);
		color clr = color(hue, 1, 1);
		// restore RGB color mode
		colorMode(RGB, 255);
		return clr;
	}

	// Given a color, return its hue as 0..1.
	// NOTE: assumes we're normally in RGB mode
	float hueFromColor(color clr) {
		// switch to HSB color mode
		colorMode(HSB, 1.0);
		float result = hue(clr);
		// restore RGB color mode
		colorMode(RGB, 255);
		return result;
	}




////////////////////////////////////////////////////////////
//	Debugging and error handling.
////////////////////////////////////////////////////////////

	// Log a debug message -- something unexpected happened, but no biggie.
	void debug(String message) {
		if (this.debugging) println(message);
	}


	// Log a warning message -- something unexpected happened, but it's not fatal.
	void warn(String message) {
		this.warn(message, null);
	}

	void warn(String message, Exception e) {
		if (!this.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  WARNING: " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}

	// Log an error message -- something unexpected happened, and it's pretty bad.
	void error(String message) {
		this.error(message, null);
	}

	void error(String message, Exception e) {
		if (!this.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  ERROR!!:   " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}


}