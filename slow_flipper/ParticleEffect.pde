
public class Particle{
  public Vec2 pos;
  public Vec2 dir;
  public float s;
  public color c;
  public float opacity;
  public float deviation;
  public float speed;
  public float angle;
  
  public Particle(float x, float y, float vx, float vy, float speed, float size, color c, float opacity, float deviation){
    pos = new Vec2(x, y);
    dir = (new Vec2(vx, vy)).normalize();
    angle = random(-deviation, deviation);
    
    //dir = rotate_point(dir, dir, angle);
    s = size;
    this.speed = speed;
    this.c = c;
    this.opacity = opacity;
    this.deviation = deviation;
  }
  
  public void update(){
    pos.add(dir.mul_new(speed));
  
  }
  
  public void draw(){
    pushMatrix();
    noStroke();
    fill(c, opacity);
    ellipse(pos.x, pos.y, s, s);
    popMatrix();
  }

}

public class ParticleEffect{

  public Particle[] particles; 
  public int particleNum= 30;
  public float range = 30;
  public float timer = 0;
  public boolean done = false;
  public float duration;
  public ParticleEffect(float x, float y, float vx, float vy, float duration){
    particles = new Particle[particleNum];
    //color c = color(255 ,40, 180);
    this.duration = duration;
    for(int i = 0; i < particleNum; i++){
      particles[i] = new Particle(x, y, vx, vy, 2, 4, color(255, 40, random(0, 255)), 180, 45);
    }
  }
  
  public void update(float dt){
    timer +=dt;
    if(timer >= duration){
      timer = 0;
      particles = null;
      done = true;
      
    }
    if(particles == null) return;
    for(int i = 0; i < particleNum; i++){
      particles[i].update();
    }
  
  }
  
  public void draw(){
    if(particles == null) return;
    for(int i = 0; i < particleNum; i++){
      particles[i].draw();
    }
  }
}
