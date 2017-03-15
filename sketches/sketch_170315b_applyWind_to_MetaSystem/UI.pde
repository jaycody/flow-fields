/* color scheme
tex0 = red
tex1 = green
tex2 = brightblue
tex3 = darkblue
tex4 = yellow
tex5 = white
*/

void mousePressed() {
  meta.addNewParticleSystem(int(random(5)));
}

void keyPressed() {
  if (key == ' ') {
    meta.removeParticleSystem();
  }
  if (key == 'c') {
    meta.clearHome();
  }
  
  
   
  // convert ascii code to actual int
  int i = int(key)-48;
  println(i);
  
  // switch screens
  if (i >= 0 && i < 6) {
    meta.addNewParticleSystem(i);
  }
}