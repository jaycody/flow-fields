/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Handle keypress to adjust parameters
////////////////////////////////////////////////////////////
	void keyPressed() {
	  println("*** CURRENT FRAMERATE: " + frameRate);

	  // up arrow to move kinect down
	  if (keyCode == UP) {
		gConfig.kinectAngle = constrain(++gConfig.kinectAngle, 0, 30);
		gKinecter.kinect.setTilt(gConfig.kinectAngle);
		gConfig.saveSetup();
	  }
	  // down arrow to move kinect down
	  else if (keyCode == DOWN) {
		gConfig.kinectAngle = constrain(--gConfig.kinectAngle, 0, 30);
		gKinecter.kinect.setTilt(gConfig.kinectAngle);
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