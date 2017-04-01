/*keep track of the changes I made::

color changes happended in this function:  public void updateAndRenderGL() {
  
and here:
public void updateAndRenderGL() {
    
//----------------------------------------------------------------bring in the TOUCH OSC variables
    viscosity = viscosityOSC;
    
  
*/


// create function to recv and parse oscP5 messages
void oscEvent (OscMessage theOscMessage) {

  //------------------------------------debug Print upon receive OSC Message
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  
  
  
  String addr = theOscMessage.addrPattern();  //never did fully understand string syntaxxx
  float val = theOscMessage.get(0).floatValue(); // this is returning the get float from bellow

  if      (addr == "/color/faderRed")          faderRed = val;
  else if (addr == "/color/faderGreen")        faderGreen = val;
  else if (addr == "/color/faderBlue")         faderBlue = val;
  else if (addr == "/color/faderAlpha")        faderAlpha = val;
  else if (addr == "/P_Manager/viscosity")     viscosityOSC = val;

  else if (addr == "/P_Manager/forceMulti")    forceMultiOSC= val;
  else if (addr == "/P_Manager/accFriction")   accFrictionOSC = val;
  else if (addr == "/P_Manager/accLimiter")    accLimiterOSC = val;

  else if (addr == "/P_Manager/noiseStrength") noiseStrengthOSC = val;
  else if (addr == "/P_Manager/noiseScale")    noiseScaleOSC = val;
  else if (addr == "/P_Manager/zNoise")        zNoiseVelocityOSC = val;
  else if (addr == "/P_Manager/genSpread")     generateSpreadOSC = val;

}



