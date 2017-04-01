/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
 *								http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

import org.openkinect.processing.*;

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
      kinect.initDepth();
      kinect.initVideo();
			kinect.enableIR(true);
			kinect.setTilt(kAngle);

			// the below makes getRawDepth() faster
			//kinect.processDepthImage(false);

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
	//	if (isKinected) kinect.quit();
	}
}