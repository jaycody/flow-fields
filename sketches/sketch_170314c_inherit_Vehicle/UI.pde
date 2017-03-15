
void mousePressed() {
  meta.addNewParticleSystem();
}

void keyPressed() {
  if (key == ' ') {
    meta.removeParticleSystem();
  }
  if (key == 'c') {
    meta.clearHome();
  }
}