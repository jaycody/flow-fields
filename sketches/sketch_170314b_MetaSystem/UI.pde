
void mousePressed() {
  meta.addNewParticleSystem(int(random(100)), mouseX, mouseY);
}

void keyPressed() {
  if (key == ' ') {
    meta.removeParticleSystem();
  }
  if (key == 'c') {
    meta.clearHome();
  }
}