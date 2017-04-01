/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Depth image manipulation
////////////////////////////////////////////////////////////

	// Draw the depth image to the screen according to our global config.
	void drawDepthImage() {
		pushStyle();
		pushMatrix();
//TODO...
//		tint(depthImageColor);
//		tint(256,128);
		scale(-1,1);	// reverse image to mirrored direction
		blendMode(gConfig.depthImageBlendMode);
		image(gDepthImg, 0, 0, -width, height);
		blendMode(BLEND);	// NOTE: things don't look good if you don't restore this!
		popMatrix();
		popStyle();
	}

	// Draw the raw depth info as a pixel at each coordinate.
	void drawDepthPixels() {
		pushStyle();
		int delta = 2;//gConfig.flowfieldResolution;	// 1;
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


////////////////////////////////////////////////////////////
//	Drawing utilities.
////////////////////////////////////////////////////////////

	// Partially fade the screen by drawing a translucent black rectangle over everything.
	void fadeScreen(color bgColor, int opacity) {
		pushStyle();
		noStroke();
		fill(bgColor, opacity);
		rect(0, 0, width, height);
		popStyle();
	}

	// Show the instruction screen as an overlay.
	void drawInstructionScreen() {
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
	PVector[][] makePerlinNoiseField(int rows, int cols) {
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
		  yOffset += 0.1;
		}
		xOffset += 0.1;
	  }
	  return field;
	}


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
//	Debuggy
////////////////////////////////////////////////////////////

	// Return a color as `rgba(r,g,b,a)`.
	String echoColor(color clr) {
		return "rgba("+(int)red(clr)+","+(int)green(clr)+","+(int)blue(clr)+","+(int)alpha(clr)+")";
	}

	// Return a boolean as `true` or `false`.
	String echoBoolean(boolean bool) {
		if (bool) return "true";
		return "false";
	}

