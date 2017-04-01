/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
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
	  // toggle showDepthPixels on/off
	  else if (key == 'r') {
		gConfig.showDepthPixels = !gConfig.showDepthPixels;
		println("showing depth pixels: " + gConfig.showDepthPixels);
	  }


	// different blend modes
	  else if (key == '1') {
		gConfig.depthImageBlendMode = BLEND;
		println("Blend mode: BLEND");
	  }
	  else if (key == '2') {
		gConfig.depthImageBlendMode = ADD;
		println("Blend mode: ADD");
	  }
	  else if (key == '3') {
		gConfig.depthImageBlendMode = SUBTRACT;
		println("Blend mode: SUBTRACT");
	  }
	  else if (key == '4') {
		gConfig.depthImageBlendMode = DARKEST;
		println("Blend mode: DARKEST");
	  }
	  else if (key == '5') {
		gConfig.depthImageBlendMode = LIGHTEST;
		println("Blend mode: LIGHTEST");
	  }
	  else if (key == '6') {
		gConfig.depthImageBlendMode = DIFFERENCE;
		println("Blend mode: DIFFERENCE");
	  }
	  else if (key == '7') {
		gConfig.depthImageBlendMode = EXCLUSION;
		println("Blend mode: EXCLUSION");
	  }
	  else if (key == '7') {
		gConfig.depthImageBlendMode = MULTIPLY;
		println("Blend mode: MULTIPLY");
	  }
	  else if (key == '8') {
		gConfig.depthImageBlendMode = SCREEN;
		println("Blend mode: SCREEN");
	  }
	}
