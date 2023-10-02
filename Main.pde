
import processing.sound.*;

//Sounds
public SoundFile space_silence;
public SoundFile space_ambience;
public SoundFile music;
public SoundFile launch; //maybe
public SoundFile warpspeed;
public SoundFile ballhit; 
public SoundFile circlehit; 
public SoundFile typing; 
public SoundFile holehit;
public SoundFile gameover;
public boolean extraball = false;

public Star[] stars = new Star[800];
public Planet planet;
float noiseScale = 0.02;

//Effects
ArrayList<CircleEffect> circleEffects = new ArrayList<CircleEffect>(); 


public float translation = 0;
public boolean loading = false;
public int frameNum = 0;
public int timerEnd;
public int loadingLength = 4;
public int state = 0; // 0- menu, 1- transition,  2 - game, 3 - end screen
public int typingSpeed = 10;
public boolean isPlaying = false;

public int messageLength = 0;
public boolean messageDone = false;

public int staticX, staticY;
public PImage img;
public PImage arrows;
public PFont font1;
public PFont font2;

public Background bg;

public boolean paused = false;


// define theme colors to use repeatedly
color SILVER = color(192, 192, 192);
color BRIGHT_BLUE = color(200, 200, 255);
color NAVY = color(0, 0, 0);
color OFF_WHITE = color(255, 200, 255);
color WHITE = color(255, 255, 255);
color ORANGE = color(250, 0, 255);
color RED = color(255, 0, 0, 60);
color LIME = color(0, 255, 0);
color BLACK = color(0, 0, 0, 180);

Vec2 closest = new Vec2(0, 0);

// physics parameters
float GRAVITY = 10.0;
float COR = 0.7; // coefficient of restitution

Box[] boxes;
int num_boxes = 0;
Ball[] balls;
int num_balls = 0;
Circle[] circles;
int num_circles = 0;
Flipper[] flippers;
int num_flippers = 0;
Line[] lines;
int num_lines = 0;
Arc[] arcs;
int num_arcs = 0;
Launcher launcher;
Hole hole;

int x0 = 350;
int y0 = 50;
int w = 500;
int h = 800;
int GUTTER = 35;
Vec2 LAUNCH_POS = new Vec2(x0+w-20, y0+h-20);

boolean FRAME = true;

int balls_lost = 0;
int score = 0;




void setup(){
  //General Setup
  frameRate(60);
  size(1200, 900, P3D);
  background(0, 0, 0);
  
  //Creating background objects/planets/stars
  bg = new Background();
  
  planet = new Planet(0, 0, 200);
  
  for(int i = 0; i < stars.length; i++){
    stars[i] = new Star();
  }
  
  //Loading Fonts
  font1 = createFont("Agency FB Bold", 70);
  font2 = loadFont("OCRAExtended-48.vlw");
  
  
  //Loading Sounds
  space_silence = new SoundFile(this, "space_silence.wav");
  music = new SoundFile(this, "synthmusic.mp3");
  typing = new SoundFile(this, "typing.wav");
  space_ambience = new SoundFile(this, "space_noises.mp3");
  warpspeed = new SoundFile(this, "takeoff.mp3");
  holehit = new SoundFile(this, "hole.wav");
  gameover = new SoundFile(this, "gameover.wav");
  circlehit = new SoundFile(this, "hit.mp3");
  ballhit = new SoundFile(this, "ballhit.mp3");
  launch = new SoundFile(this, "launch.mp3");
  
  
  
  //load any images
  img = loadImage("try6.jpg");
  arrows = loadImage("arrows.png");
  
  loadFromFile("save1.txt");
  //loadCustom();
  
  
  //saveCurrentToFile("save1.txt");
  
  
  
  
  
  
    
    
    
    
}

void saveCurrentToFile(String fileName){
    String out = "";
    out+= "b"+num_boxes+"\n";
    for(int i = 0; i < num_boxes; i++){
      out += boxes[i].encode();
    }
    
    out+= "O"+num_balls+"\n";
    for(int i = 0; i < num_balls; i++){
      out += balls[i].encode();
    }
    
    out+= "c"+num_circles+"\n";
    for(int i = 0; i < num_circles; i++){
      out += circles[i].encode();
    }
    
    out += "f"+num_flippers+"\n";
    for(int i = 0; i < num_flippers; i++){
      out += flippers[i].encode();
    }
    
    out+= "l"+num_lines+"\n";
    for(int i = 0; i < num_lines; i++){
      out += lines[i].encode();
    }
    out+= "a"+num_arcs+"\n";
    for(int i = 0; i < num_arcs; i++){
      out += arcs[i].encode();
    }
    
    out+= "l"+1+"\n";
    out+=launcher.encode();
    
    out+="h"+1+"\n";
    out+=hole.encode();
    
    String[] out_list = {out};
    saveStrings(fileName, out_list);
}

void loadCustom(){
  boxes = new Box[10];
  balls = new Ball[2];
  circles = new Circle[10];
  flippers = new Flipper[2];
  lines  = new Line[10];
  arcs = new Arc[10];
   strokeJoin(ROUND);
   
   
   
    // box for main board (x0, y0, w, h)
    boxes[0] = new Box(x0, y0, w, h);
    boxes[0].stroke_color = WHITE;
    boxes[0].fill_color = BLACK;
    boxes[0].stroke_weight = 4;
    num_boxes++;
    
    // first ball
    balls[0] = new Ball(LAUNCH_POS, 15);
    balls[0].stroke_color = WHITE;
    balls[0].fill_color = SILVER;
    balls[0].stroke_weight = 2;
    num_balls++;
    // second ball starts on shelf
    balls[1] = new Ball(new Vec2(x0+230, y0+h-620), 15);
    balls[1].stroke_color = WHITE;
    balls[1].fill_color = SILVER;
    balls[1].stroke_weight = 2;
    num_balls++;

    // circular obstacles
    circles[0] = new Circle(x0+220, y0+300, 30);
    circles[0].fill_color = ORANGE;
    num_circles++;

    circles[1] = new Circle(x0+300, y0+350, 30);
    circles[1].fill_color = ORANGE;
    num_circles++;

    circles[2] = new Circle(x0+220, y0+400, 30);
    circles[2].fill_color = ORANGE;
    num_circles++;

    // flippers
    flippers[0] = new Flipper(new Vec2(x0+140, y0+h-90), new Vec2(x0+233, y0+h-60), new Vec2(x0+140, y0+h-60));
    num_flippers++;
    flippers[1] = new Flipper(new Vec2(x0+w-140, y0+h-90), new Vec2(x0+w-233, y0+h-60), new Vec2(x0+w-140, y0+h-60));
    flippers[1].negative = false;
    num_flippers++;

    // lines
    // left angle near flipper
    lines[0] = new Line(x0+140, y0+h-90, x0+GUTTER, y0+h-160);
    lines[0].stroke_color = ORANGE;
    lines[0].stroke_weight = 4;
    num_lines++;
    // left straight
    lines[1] = new Line(x0+GUTTER, y0+h-160, x0+GUTTER, y0+h-280);
    lines[1].stroke_color = ORANGE;
    lines[1].stroke_weight = 4;
    num_lines++;
    // right straight
    lines[2] = new Line(x0+w-GUTTER-40, y0+h-160, x0+w-GUTTER-40, y0+h-280);
    lines[2].stroke_color = ORANGE;
    lines[2].stroke_weight = 4;
    num_lines++;
    // right angle near flipper
    lines[3] = new Line(x0+w-140, y0+h-90, x0+w-GUTTER-40, y0+h-160);
    lines[3].stroke_color = ORANGE;
    lines[3].stroke_weight = 4;
    num_lines++;
    // right wall for launcher
    lines[4] = new Line(x0+w-40, y0+h, x0+w-40, y0+h-550);
    lines[4].stroke_color = ORANGE;
    lines[4].stroke_weight = 4;
    num_lines++;
    // left gutter guard
    lines[5] = new Line(x0, y0+h-370, x0+GUTTER, y0+h-330);
    lines[5].stroke_color = ORANGE;
    lines[5].stroke_weight = 4;
    num_lines++;
    // ball shelf
    lines[6] = new Line(x0+210, y0+h-600, x0+250, y0+h-600);
    lines[6].stroke_color = ORANGE;
    lines[6].stroke_weight = 4;
    num_lines++;
    // right gutter guard
    lines[7] = new Line(x0+w-GUTTER-40, y0+h-330, x0+w-40, y0+h-370);
    lines[7].stroke_color = ORANGE;
    lines[7].stroke_weight = 4;
    num_lines++;

    // arcs
    arcs[0] = new Arc(x0+w-250, y0+250, 250, PI, 2*PI);
    arcs[0].stroke_color = OFF_WHITE;
    arcs[0].stroke_weight = 4;
    num_arcs++;
    // arc for left side of launcher
    arcs[1] = new Arc(x0+w-250, y0+250, 210, 5.0*PI/3.0, 2*PI);
    arcs[1].stroke_color = ORANGE;
    arcs[1].stroke_weight = 4;
    num_arcs++;

    // launcher
    launcher = new Launcher(x0+w-40, y0+h);
    
    // hole past flippers
    hole = new Hole(x0+2, y0+h-32, 456, 30);
}

void loadFromFile(String fileName){
  String[] data = loadStrings(fileName);

  int currIndex = 0;
  strokeJoin(ROUND);
  num_boxes = int(data[currIndex].substring(1,2));//boxes
  boxes = new Box[num_boxes];
  currIndex++;
  for(int i = 0; i < num_boxes; i++){
    String[] split = split(data[currIndex+i], ',');
    boxes[i] = new Box(float(split[0]), float(split[1]),float(split[2]),float(split[3]));
    boxes[i].stroke_weight = int(split[4]);
    boxes[i].stroke_color = color(float(split[5]), float(split[6]), float(split[7]), float(split[8]));
    boxes[i].fill_color = color(float(split[9]), float(split[10]), float(split[11]), float(split[12]));
    
  }
  currIndex+= num_boxes;
  
  num_balls = int(data[currIndex].substring(1,2));//balls
  balls = new Ball[num_balls];
  currIndex++;
  for(int i = 0; i < num_balls; i++){
    String[] split = split(data[currIndex+i], ',');
    balls[i] = new Ball(new Vec2(float(split[0]), float(split[1])), float(split[2]));
  }
  currIndex+= num_balls;
  
  num_circles = int(data[currIndex].substring(1,2));//circles
  circles = new Circle[num_circles];
  currIndex++;
  for(int i = 0; i < num_circles; i++){
    String[] split = split(data[currIndex+i], ',');
    circles[i] = new Circle(float(split[0]), float(split[1]), float(split[2]));
  }
  currIndex+= num_circles;
  
  num_flippers = int(data[currIndex].substring(1,2));//flippers
  flippers = new Flipper[num_flippers];
  currIndex++;
  for(int i = 0; i < num_flippers; i++){
    String[] split = split(data[currIndex+i], ',');
    Vec2 v0 = new Vec2(float(split[0]),float(split[1]));
    Vec2 v1 = new Vec2(float(split[2]),float(split[3]));
    Vec2 v2 = new Vec2(float(split[4]),float(split[5]));
    flippers[i] = new Flipper(v0, v1, v2);
    flippers[i].negative = boolean(split[6]);
    
  }
  currIndex+= num_flippers;
  
  num_lines = int(data[currIndex].substring(1,2));//lines
  lines = new Line[num_lines];
  currIndex++;
  for(int i = 0; i < num_lines; i++){
    String[] split = split(data[currIndex+i], ',');
    lines[i] = new Line(float(split[0]),float(split[1]),float(split[2]),float(split[3]));
    lines[i].stroke_weight = int(split[4]);
    lines[i].stroke_color = color(float(split[5]), float(split[6]), float(split[7]), float(split[8]));
  }
  currIndex+= num_lines;
  
  num_arcs = int(data[currIndex].substring(1,2));//arcs
  arcs = new Arc[num_arcs];
  currIndex++;
  for(int i = 0; i < num_arcs; i++){
    String[] split = split(data[currIndex+i], ',');
    arcs[i] = new Arc(float(split[0]),float(split[1]),float(split[2]),float(split[3]),float(split[4]));
    arcs[i].stroke_weight = int(split[5]);
    arcs[i].stroke_color = color(float(split[6]), float(split[7]), float(split[8]),float(split[9]));
  }
  currIndex+= num_arcs;
  
  currIndex++;
  //launcher
  String[] split = split(data[currIndex], ',');
  launcher = new Launcher(float(split[0]),float(split[1]));
  launcher.fill_color = color(float(split[2]), float(split[3]), float(split[4]), float(split[5]));
  currIndex++;
  currIndex++;
  //hole
  split = split(data[currIndex], ',');
  hole = new Hole(float(split[0]),float(split[1]),float(split[2]),float(split[3]));
  hole.fill_color = color(float(split[4]), float(split[5]), float(split[6]), float(split[7]));
 
  
  
}

void draw(){
  //reset background
  background(0, 0, 0);
  int m = millis();
  frameNum+=1;
  if(frameNum == frameRate) frameNum = 0;
  
  
  
  if(state == 0) { //start
    //change background color slightly
    background(0, 0, 10);
    
    //Center screen on mouse
    translate(mouseX, mouseY);
    
    
    
    //play bg music - https://www.youtube.com/watch?v=UbbG7v-4sew
    if(!space_silence.isPlaying()){
      space_silence.play(1, 0, 0.5); 
    }
    
    if(!space_ambience.isPlaying()){
      space_ambience.play(1, 0, 0.5); 
    }
    //display stars and planet
    for(int i = 0; i < stars.length; i++){
      stars[i].update();
      stars[i].show();
    }
    
    planet.update();
    planet.show();
    
    //label for planet
    fill(255);
    textFont(font1);
    text("PINBALLIA", planet.pos.x-planet.r+80, planet.pos.y+planet.r);
    
    //display message text
    textFont(font2);
    fill(0, 255, 0);
    String displayMessage = "";
    if(frameNum%typingSpeed == 0) messageLength+=1;
    
    if(messageLength < 22 && !messageDone) {
      if(!typing.isPlaying()){
        typing.cue(0.5);
        typing.play(1, 0, 0.5); 
      } 
       displayMessage = "Approaching Pinballia".substring(0, messageLength%22) + "_"; 
    } else if(!messageDone){
      messageDone = true;
      messageLength = 1;
    } else {
      if(typing.isPlaying()){
        typing.pause();
      }
      
      typingSpeed = 20;
      if(messageLength >= 4) {
        messageLength = 0;
      }
      displayMessage = "Approaching Pinballia"+ "...".substring(0, messageLength%4);
    }  
    text(displayMessage, -mouseX+20, -mouseY+height-20);
    
    
    pushMatrix();
    rotateY(radians(-20));
    fill(255);
    textFont(font1, 40);
    
    
    text("LEFT: Left Flipper\nRIGHT: Right Flipper\nUP: Launch Ball\nSPACE: Pause\nYou have 2 lives. Good luck.", 500, -100);
    stroke(255);
    strokeWeight(3);
    
    endShape();
    popMatrix();
    
    pushMatrix();
    rotateY(radians(20));
    fill(255);
    textFont(font1, 40);
    text("Game By\nDevansh Mishra &\nCarl Winge", -700, 0);
    stroke(255);
    strokeWeight(3);
    endShape();
    popMatrix();
    
    
  } else if (state == 1) { //loading
    //lock into where the click happened
    translate(staticX, staticY);
    if(typing.isPlaying()){
      typing.pause();
    }
    
    
    
    if(space_ambience.isPlaying()){
      space_ambience.pause();
    }
    if(!warpspeed.isPlaying()){
      warpspeed.cue(3);
      warpspeed.play(1, 0, 0.5); 
    }
    if(m >= timerEnd){
      state+=1;
      space_silence.pause();
      warpspeed.pause();
    }
    
    //update planet and stars to increase speed and size
    for(int i = 0; i < stars.length; i++){
      stars[i].speed = 10;
      stars[i].update();
      stars[i].show();
    }
    planet.r += 10;
    planet.update();
    planet.show();
    
    //fade to black
    float a = map(m, timerEnd - loadingLength*1000, timerEnd, 0, 255);
    fill(0, 0, 0, a);
    rect(-width, -height, width*2, height*2);
    
    
  } else if (state == 2){ //load save
  
    image(img, 0, 0, width, height);
    noStroke();
    fill(0, 0, 0);
    rect(0, height/2+50, width, height/2);
    
    if(!music.isPlaying()){
      music.play(1, 0, 0.5);
    }
    
    bg.update();
    bg.show();
    hint(DISABLE_DEPTH_TEST);
    //
    if (FRAME) {
        update(1.0 / frameRate);
        // FRAME = false; // uncomment to only update once per keypress
    }

    // draw the boxes
    for (int i = 0; i < num_boxes; i++) {
        boxes[i].draw();
    }

    // draw the launcher
    launcher.draw();

    // draw the hole
    hole.draw();

    // draw the flippers
    for (int i = 0; i < num_flippers; i++) {
        flippers[i].draw();
    }

    // draw the balls
    for (int i = 0; i < num_balls; i++) {
        balls[i].draw();
    }

    // draw the circles
    for (int i = 0; i < num_circles; i++) {
        circles[i].draw();
    }

    // draw the lines
    for (int i = 0; i < num_lines; i++) {
        lines[i].draw();
    }

    // draw the arcs
    for (int i = 0; i < num_arcs; i++) {
        arcs[i].draw();
    }
    
    
    
    for(CircleEffect c : circleEffects){
      c.draw();
    }
      
    // draw the score
    pushMatrix();
    fill(0, 0, 0, 80);
    stroke(255, 255, 255);
    strokeWeight(3);
    
    rect(80, 120, 190, 200, 10);
    
    textAlign(CENTER);
    textFont(font1);
    textSize(70);
    fill(255, 255, 255);
    text("SCORE", 175, 200);
    text(""+score, 175, 300);
    textAlign(LEFT);
    popMatrix();
    
    //Draw Balls Left
    pushMatrix();
    fill(0, 0, 0, 80);
    stroke(255, 255, 255);
    strokeWeight(3);
    
    rect(880, 120, 290, 200, 10);
    
    textAlign(CENTER);
    textFont(font1);
    textSize(70);
    fill(255, 255, 255);
    text("BALLS LEFT", 1025, 200);
    if(extraball){
      text((3-balls_lost) +"/3" , 1025, 300);
    } else {
      text((2-balls_lost) +"/2" , 1025, 300);
    }
    textAlign(LEFT);
    popMatrix();
    
    // if balls lost is 2, game over
    
    if (balls_lost == 2 && !extraball) {
      music.pause(); 
      state++;
    } else if(extraball && balls_lost == 3){
      music.pause();
      state++;
    }
    
  } else if (state == 3){
    textAlign(CENTER);
    textFont(font1);
    textSize(300);
    fill(255, 255, 255);
    text("GAME OVER", width/2, height/2);
    if(!gameover.isPlaying()){
      gameover.play(1, 0, 1); 
    }
  }
  
  
}


void update(float dt) {
  
     for(int i = 0; i < circleEffects.size(); i++){
        circleEffects.get(i).update(dt);
        if(circleEffects.get(i).dead){
          circleEffects.remove(i);
          i--;
         }
    }
    
    // update the balls
    for (int i = 0; i < num_balls; i++) {
        balls[i].update(dt);
    }
    
    
    // update the flippers
    for (int i = 0; i < num_flippers; i++) {
        flippers[i].update(dt);
    }
    
    // check for collisions
    // ball to hole is special case
    for (int i = 0; i < num_balls; i++) {
        if (check_ball_hole(balls[i], hole)) {
            balls[i].pos = LAUNCH_POS;
            balls[i].vel = new Vec2(0, 0);
            balls_lost++;
            //play_noise
            if(!holehit.isPlaying()){
              holehit.cue(0.3);
              holehit.play(1, 0, 0.5); 
            }
        }
    }
    
    // ball to main box is special case
    // create lines from box
    Box b = boxes[0];
    Line[] b_lines = new Line[4];
    b_lines[0] = new Line(b.x0, b.y0, b.x0 + b.w, b.y0);
    b_lines[1] = new Line(b.x0 + b.w, b.y0, b.x0 + b.w, b.y0 + b.h);
    b_lines[2] = new Line(b.x0 + b.w, b.y0 + b.h, b.x0, b.y0 + b.h);
    b_lines[3] = new Line(b.x0, b.y0 + b.h, b.x0, b.y0);
    for (int i = 0; i < num_balls; i++) {
        for (int j = 0; j < 4; j++) {
            if (check_ball_line(balls[i], b_lines[j])) {
                    balls[i].bounce(b_lines[j]);
            }
        }
    }
    
    
    
    // check for ball to circle collisions
    for (int i = 0; i < num_balls; i++) {
        for (int j = 0; j < num_circles; j++) {
            if (check_ball_circle(balls[i], circles[j])) {
                balls[i].bounce(circles[j]);
                //play noise
                if(!circlehit.isPlaying()){
                  circlehit.cue(0.1);
                  circlehit.playFor(0.1);
                  circlehit.play(1, 0, 0.5); 
                }
                circleEffects.add(new CircleEffect(circles[j].pos.x, circles[j].pos.y, circles[j].r*2, 2, 0.5));
                score += circles[j].score;
            }
        }
    }
    
    // check for ball to flipper collisions
    for (int i = 0; i < num_balls; i++) {
        for (int j = 0; j < num_flippers; j++) {
            if (check_ball_line(balls[i], flippers[j].line)) {
                balls[i].bounce(flippers[j]);
                flippers[j].light = true;
                flippers[j].timer = 0;
            }
        }
    }
    
    // check for ball to line collisions
    for (int i = 0; i < num_balls; i++) {
        for (int j = 0; j < num_lines; j++) {
            if (check_ball_line(balls[i], lines[j])) {
                balls[i].bounce(lines[j]);
                
                
                
            }
        }
    }
    
    // update the launcher
    launcher.update(dt, balls);
    
    // check for ball to arc collisions
    for (int i = 0; i < num_balls; i++) {
        for (int j = 0; j < num_arcs; j++) {
            if (check_ball_arc(balls[i], arcs[j])) {
                balls[i].bounce(arcs[j]);
            }
        }
    }
    
    // check for ball to ball collisions
    for (int i = 0; i < num_balls; i++) {
        for (int j = i+1; j < num_balls; j++) {
            if (check_ball_ball(balls[i], balls[j])) {
                balls[i].bounce(balls[j]);
                extraball = true;
                if(!ballhit.isPlaying()){
                  ballhit.playFor(0.1, 0);
                  ballhit.play(1, 0, 0.5); 
                }
            }
        }
    }
    
    
    
    

}

void mousePressed() {
  if(state == 0){
    timerEnd = millis() + loadingLength*1000;
    state+=1;
    staticX = mouseX; 
    staticY = mouseY;
  } 
  if(state == 3) {
    //state = 0;
    //reset
  }
}

void keyPressed()
{
   if (key == ' ') {
     if(paused) loop();
     if(!paused) { 
       pushMatrix();
       
       
       textFont(font1);
       textSize(300); 
       //fill(251,28,228,255);
       fill(150,0,120,255);
       text("PAUSED", 230, 550);
       
       //fill(124,228,252,255);
       fill(251,28,228,255);
       text("PAUSED", 215, 550);
       
       popMatrix();
       
       music.pause();
       noLoop();
     }
     paused = !paused;
   }
   
   if(state == 2){
       if (keyCode == LEFT) {
          flippers[0].state = 1;
      }
      // j for right flipper
      if (keyCode == RIGHT) {
          flippers[1].state = 1;
      }
      // space for launch
      if (keyCode == UP) {
          launcher.launch(balls);
      }
   }
}

void keyReleased(){
  if(state == 2){
       if (keyCode == LEFT) {
          flippers[0].state = -1;
      }
      // j for right flipper
      if (keyCode == RIGHT) {
          flippers[1].state = -1;
      }
      // space for launch
      if (keyCode == UP) {
          launcher.launch(balls);
          if(!launch.isPlaying()){
              
              launch.play(1, 0, 0.5); 
            }
      }
   }
}
