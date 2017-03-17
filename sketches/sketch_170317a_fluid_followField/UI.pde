/* color scheme
tex0 = red
tex1 = green
tex2 = brightblue
tex3 = darkblue
tex4 = yellow
tex5 = white
tex6 = corona
tex7 = emitter
tex8 = particle
tex9 = reflection
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
  if (i >= 0 && i < 10) {
    meta.addNewParticleSystem(i);
  }
}