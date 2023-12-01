int DIE_SIDES = 6;
color BG_COLOR = color(150, 200, 255);
color TEXT_COLOR = color(255,255,255);
float SCALE = 100;
int CAM_COUNT = 7;

float W_W = 1280;
float W_H = 1080;
float S_W = 640;
float S_H = 1080;
float CURVE_R = 0.5;
int CURVE_N = 20;
float Z_EPS = 0.004;
float TURN_SPEED = 0.025;

int dieShown = 0;
char[] toPress = {'w','a','s','d'};
float[] weirdRotation = {0,0,0,0};
boolean[] WASDpressed = {false,false,false,false};
String[] diceData;
Die[] dice;
Camera camera = new Camera();
int COUNT;
PGraphics main_canvas;
PGraphics side_canvas;
PFont font;
void setup(){
  processData();
  size(1920, 1080, P3D);
  setUpCanvases();
  font = loadFont("Calibri-Bold-48.vlw");
}
void draw(){
  updateKeyHolds();
  main_canvas.beginDraw();
  moveCamera(main_canvas, camera);
  drawDice(main_canvas);
  main_canvas.endDraw();
  image(main_canvas, 0, 0);
  image(side_canvas, W_W, 0);
  drawTitleText();
}
void updateKeyHolds(){
  for(int i = 0; i < WASDpressed.length; i++){
    if(WASDpressed[i]){
      weirdRotation[i] = min(1,weirdRotation[i]+TURN_SPEED);
    }else{
      weirdRotation[i] = max(0,weirdRotation[i]-TURN_SPEED);
    }
  }
}
void drawTitleText(){
  String insert = "";
  for(int d = 0; d < COUNT; d++){
    if(dice[d].showFor[dieShown]){
      insert += (d+1)+" & ";
    }
  }
  String title = "Dice "+insert.substring(0,insert.length()-3)+" showing";
  textFont(font,48);
  textAlign(LEFT);
  fill(0);
  text(title,30,80);
}
void processData(){
  diceData = loadStrings("data.tsv");
  COUNT = diceData.length;
  dice = new Die[COUNT];
  for(int d = 0; d < COUNT; d++){
    dice[d] = new Die(d, diceData[d]);
  }
}
void drawDice(PGraphics c){
  c.background(BG_COLOR);
  
  c.directionalLight(128, 128, 128, 0, 0, -1);
  c.directionalLight(128, 128, 128, 0, 0, 1);
  c.ambientLight(128, 128, 128);
  c.lightFalloff(1, 0, 0);
  c.lightSpecular(0, 0, 0);
  
  c.pushMatrix();
  c.translate(c.width/2.0,c.height/2.0,0);
  c.rotate(weirdRotation[0]*PI);
  c.rotateX(weirdRotation[1]*PI);
  c.rotateY(weirdRotation[2]*PI);
  c.scale(1,1-2*weirdRotation[3],1);
  c.translate(-DIE_SIDES/2.0*SCALE,DIE_SIDES/2.0*SCALE,-DIE_SIDES/2.0*SCALE);
  
  for(int d = 0; d < COUNT; d++){
    if(dice[d].showFor[dieShown]){
      dice[d].drawDie(c);
    }
  }
  c.popMatrix();
}
void moveCamera(PGraphics c, Camera camera) {
  float cameraZ = ((c.height/2.0) / tan(PI*60.0/360.0));
  float fovy = PI/3.0;
  c.perspective(fovy, ((float)c.width/c.height), cameraZ/1000.0, cameraZ*10.0);

  camera.x_ang = (mouseX-c.width/2.0)/(c.width/2.0)*PI/2;
  camera.y_ang = (mouseY-c.height/2.0)/(c.height/2.0)*PI+0.0001;

  float dis = pow(1.1, camera.zoom) * (c.height/2.0) / tan(PI*30.0 / 180.0);
  float centerX = c.width/2;
  float centerY = c.height/2;
  float centerZ = 0;
  float Y_DIRECTION = (camera.y_ang < PI/2) ? 1 : -1;
  c.camera(centerX, centerY+dis*sin(camera.y_ang), 
    centerZ+dis*cos(camera.y_ang), 
    centerX, centerY, centerZ, 0, Y_DIRECTION, 0);
  c.translate(centerX, centerY, centerZ);
  c.rotateZ(-camera.x_ang);
  c.translate(-centerX, -centerY, -centerZ);
}
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  camera.zoom += e;
}
void keyPressed(){
  if (key == CODED) {
    if (keyCode == RIGHT) {
      dieShown = (dieShown+1)%(COUNT+3);
    } else if (keyCode == LEFT) {
      dieShown = (dieShown+(COUNT+3)-1)%(COUNT+3);
    }
  }
  for(int i = 0; i < toPress.length; i++){
    if(key == toPress[i]){
      WASDpressed[i] = true;
    }
  }
}
void keyReleased(){
  for(int i = 0; i < toPress.length; i++){
    if(key == toPress[i]){
      WASDpressed[i] = false;
    }
  }
}
void setUpCanvases(){
  main_canvas = createGraphics((int)W_W, (int)W_H, P3D);
  side_canvas = createGraphics((int)S_W, (int)S_H, P3D);
  main_canvas.beginDraw();
  main_canvas.noStroke();
  main_canvas.endDraw();
  side_canvas.beginDraw();
  side_canvas.noStroke();
  side_canvas.endDraw();
}
