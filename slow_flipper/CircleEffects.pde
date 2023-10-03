public class CircleEffect {
  public Vec2 pos;
  public float r;
  public float duration;
  public float timer = 0;
  public float growthRate;
  public boolean dead = false;
  
  public CircleEffect(float x, float y, float r , float growthRate, float duration){
    pos = new Vec2(x, y);
    this.r = r;
    this.duration = duration;
    this.growthRate = growthRate;
    
    
  }
  
  public void update(float dt){
    timer += dt;
    if(timer  >= duration){
      dead = true;
    } else {
      r += growthRate;
    }
    
  }
  
  public void draw(){
    pushMatrix();
    noFill();
    strokeWeight(5);
    stroke(255, 255, 255, map(timer, 0 , duration, 255, 0));
    ellipse(pos.x, pos.y, r, r);
    popMatrix();
  }
  
}
