//inspired by https://www.youtube.com/watch?v=17WoOqgXsRM
public class Star {
  public Vec2 pos;
  public float offset;
  public float speed = 1;
  
  
  public Star(){
    pos = new Vec2(random(-width, width), random(-height, height));  
    offset = random(width);
    
  }
  
  public void update(){
    
    offset = offset - speed;
    if (offset < 1) {
      pos.x = random(-width, width);
      pos.y = random(-height, height);  
      offset = random(width);
     
    }
  }
  
  public void show(){
    
    pushMatrix();
    noStroke();
    float sx = map(pos.x/offset, 0, 1, 0, width);
    float sy = map(pos.y/offset, 0, 1, 0, height);
    float r = map(offset, 0, width, 16, 0);
    
    float o = map(r, 0, 16, 0, 255);
    fill(255, o);
    ellipse(sx, sy, r, r);
    blendMode(ADD);
    colorMode(HSB, 360, 100, 100, 100);
    
    for (int i=0; i<5; i++) {
      
      
      
      //rotate(TWO_PI * noise(sx, sy));
      fill(0, 90, 5, o);
      ellipse(sx, sy, r+i*1, r+i*1);
      fill(120, 90, 5, o);
      ellipse(sx, sy, r+i*2, r+i*2);
      fill(240, 90, 5, o);
      ellipse(sx, sy, r+i*3, r+i*3);
      
      
    }
    
    
    colorMode(RGB, 255, 255, 255);
    blendMode(BLEND);
    popMatrix();
    
  }
  
}

public class Planet {
  public Vec2 pos;
  private Vec2 init_pos;
  public float r;
  private float vy = 0.5;
  private float a = 0.001;
  public color fill_color;
  
  public Planet(Vec2 pos, float r){
    this.pos = pos;
    this.init_pos = pos;
    this.r = r;
    //this.fill_color = fill_color;
  }
  
  public Planet(float x, float y, float r){
    this.pos = new Vec2(x, y);
    this.init_pos = new Vec2(x, y);;
    this.r = r;
  }
  
  public void update(){
    //go up and down slowly
    //change y with acceleration adn velocity
    
    this.pos.y += vy;
    vy += (init_pos.y - pos.y)*a;
    
  }
  
  public void show(){
    fill(77, 45, 183);
    noStroke();
    
    ellipse(this.pos.x, this.pos.y, r, r);
  }
 
  
}
