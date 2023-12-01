class Die{
  int index;
  boolean horizontal = true;
  color col;
  int[] val;
  boolean[] showFor;
  public Die(int i, String info){
    index = i;
    String[] parts = info.split("\t");
    val = new int[DIE_SIDES];
    for(int p = 0; p < DIE_SIDES; p++){
      val[p] = Integer.parseInt(parts[p]);
    }
    horizontal = parts[6].equals("H");
    col = toColor(parts,7);
    showFor = new boolean[CAM_COUNT];
    for(int k = 0; k < CAM_COUNT; k++){
      showFor[k] = false;
    }
    for(int j = 0; j < parts.length-10; j++){
      int k = Integer.parseInt(parts[j+10]);
      showFor[k] = true;
    }
  }
  void drawDie(PGraphics c){
    c.pushMatrix();
    if(horizontal){
      c.scale(1,-1,1);
    }else{
      c.scale(1,1,1);
      c.rotate(-PI/2);
    }
    c.fill(col);
    for(int v = 0; v < DIE_SIDES; v++){
      boolean curve_before = (v >= 1 && val[v-1] != val[v]);
      boolean curve_after = (v < DIE_SIDES-1 && val[v+1] != val[v]);
      
      c.pushMatrix();
      c.translate(v*SCALE,0,val[v]*SCALE);
      if(curve_before){
        int diff = val[v-1]-val[v];
        c.pushMatrix();
        c.rotateY((diff > 0) ? -PI/2 : PI/2);
        c.rect(CURVE_R*SCALE,0,(abs(diff)-CURVE_R*2)*SCALE,DIE_SIDES*SCALE);
        c.popMatrix();
        drawCurvedSurface(c, 1, ((diff > 0) ? 1 : -1));
      }else if(curve_after){
        int diff = val[v+1]-val[v];
        c.pushMatrix();
        c.translate(SCALE,0,0);
        drawCurvedSurface(c, -1, ((diff > 0) ? 1 : -1));
        c.popMatrix();
      }
      float start_x = curve_before ? CURVE_R : 0;
      float end_x = curve_after ? 1-CURVE_R : 1;
      c.rect(start_x*SCALE,0,(end_x-start_x)*SCALE,DIE_SIDES*SCALE);
      c.popMatrix();
    }
    c.popMatrix();
    c.textFont(font,48);
    c.textAlign(CENTER);
    c.fill(TEXT_COLOR);
    for(int x = 0; x < DIE_SIDES; x++){
      for(int y = 0; y < DIE_SIDES; y++){
        int z = horizontal ? val[x] : val[y];
        c.pushMatrix();
        c.translate((x+0.5)*SCALE,-(y+0.5)*SCALE,(z+Z_EPS)*SCALE);
        c.text(z,0,20);
        c.popMatrix();
      }
    }
  }
  
}
void drawCurvedSurface(PGraphics c, float X_SCALE, float Z_SCALE){
  for(int a = 0; a < CURVE_N; a++){
    float ang1 = a*PI/2/CURVE_N;
    float ang2 = (a+1)*PI/2/CURVE_N;
    float x1 = (CURVE_R-CURVE_R*cos(ang1))*SCALE*X_SCALE;
    float x2 = (CURVE_R-CURVE_R*cos(ang2))*SCALE*X_SCALE;
    float z1 = (CURVE_R-CURVE_R*sin(ang1))*SCALE*Z_SCALE;
    float z2 = (CURVE_R-CURVE_R*sin(ang2))*SCALE*Z_SCALE;
    c.beginShape();
    c.vertex(x1,0,z1);
    c.vertex(x2,0,z2);
    c.vertex(x2,DIE_SIDES*SCALE,z2);
    c.vertex(x1,DIE_SIDES*SCALE,z1);
    c.endShape(CLOSE);
  }
}
color toColor(String[] parts, int i){
  float red = Float.parseFloat(parts[i]);
  float green = Float.parseFloat(parts[i+1]);
  float blue = Float.parseFloat(parts[i+2]);
  return color(red, green, blue);
}
