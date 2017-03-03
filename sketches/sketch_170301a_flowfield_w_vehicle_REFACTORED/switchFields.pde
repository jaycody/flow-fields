void switchFields() {
  switch(fieldSwitch) {
  
   ///////// Display PERLIN FIELD ///////////
   case 1:
    grid.displayField();
    break;
  case 2:
    grid.displayField();
    grid.updateField();
    break;
  
  ///////// Rects in PERLIN FIELD /////////////
  case 3:
    grid.updateField();
    grid.squareRotate();
    break;
  
  ///////// Vehicles in PERLIN FIELD /////////////
  case 4:
    grid.updateField();
    fill(0, 15);
    rect(0, 0, width, height);
    for (Vehicle v : vehicles) {
      v.follow(grid);
      v.display();
    }
    break;
  
  /////// Display Ref Image Field ///////////////
  case 5:
    refImageGrid.displayField();
    break;
  
  /////// Rects in Ref Image Field ///////////////
  case 6:
    refImageGrid.squareRotate();
    break;
  
  //////// Vechicles in RefImage Field ////////
  case 7:
    fill(0, 15);
    rect(0, 0, width, height);
    for (Vehicle v : vehicles) {
      v.follow(refImageGrid);
      v.getBrightnessFrom(refImageGrid);
      v.display();
    }
    break;
    
  ///////// CELLS in RefImageField ///////////////////
  case 8:
    for (Cell c : cells) {
      c.getBrightnessFrom(refImageGrid);
      c.align(refImageGrid);
      c.display();
    }
    break;
  
  ///////// CELLS in RefImageField + Align to Perlin Field (2 fields used) ///////////////////
  case 9:
    grid.updateField();
    for (Cell c : cells) {
      c.getBrightnessFrom(refImageGrid);
      c.align(grid);
      c.display();
    }
    break;
    
  ///////// display reference image ///////////////
  default:
    image(refImg, 0, 0, width, height);
  }
}