
public class Circle {
    // position
    public Vec2 pos = new Vec2(0, 0);
    public float r;
    // stroke color
    color stroke_color = color(0, 0, 0);
    // fill color
    color fill_color = color(255, 255, 255);
    // stroke weight
    int stroke_weight = 0;
    int score = 10;

    public Circle() {
        pos.x = 0;
        pos.y = 0;
        r = 0;
    }

    public Circle(float x, float y, float r) {
        pos.x = x;
        pos.y = y;
        this.r = r;
    }

    public void draw(){
      pushMatrix();
        noStroke();
        
        float o = 100;
        fill(255,200, 255, o);
        ellipse(pos.x, pos.y, r*2, r*2);
        blendMode(ADD);
        colorMode(HSB, 360, 100, 100, 100);
        
        for (int i=0; i<5; i++) {
          
          
          
          //rotate(TWO_PI * noise(sx, sy));
          fill(300, 100, 100, o);
          ellipse(pos.x, pos.y, r*2+i*1, r*2+i*1);
          fill(300, 100, 50, o);
          ellipse(pos.x, pos.y, r*2+i*5, r*2+i*5);
          fill(300, 100, 10, o);
          ellipse(pos.x, pos.y, r*2+i*10, r*2+i*10);
          
          
        }
    
    
        colorMode(RGB, 255, 255, 255);
        blendMode(BLEND);
        popMatrix();
    }
    
    public String encode(){
      return pos.x+","+pos.y+","+r+"\n"; //no color
    }
    
}

public class Line {
    public Vec2 start = new Vec2(0, 0);
    public Vec2 end = new Vec2(0, 0);
    // stroke weight
    int stroke_weight = 1;
    // stroke color
    color stroke_color = color(0, 0, 0);

    public Line() {
        start.x = 0;
        start.y = 0;
        end.x = 0;
        end.y = 0;
    }

    public Line(float x1, float y1, float x2, float y2) {
        start.x = x1;
        start.y = y1;
        end.x = x2;
        end.y = y2;
    }
    
    public void draw() {
        strokeWeight(stroke_weight);
        stroke(stroke_color);
        line(start.x, start.y, end.x, end.y);
    }
    
    public String encode(){
      return start.x+","+start.y+","+end.x+","+end.y+","+stroke_weight+","+red(stroke_color)+","+green(stroke_color)+","+blue(stroke_color)+","+alpha(stroke_color)+"\n"; //uses color
    }
}

public class Box {
    // x0, y0 is top left corner
    public float x0, y0, w, h;
    // x, y is center
    public float x, y;
    // stroke color rgb
    color stroke_color = color(0, 0, 0);
    // fill color rgb
    color fill_color = color(255, 255, 255);
    // stroke weight
    int stroke_weight = 1;

    public Box(float x0, float y0, float w, float h) {
        this.x0 = x0;
        this.y0 = y0;
        this.w = w;
        this.h = h;
        x = x0 + w / 2;
        y = y0 + h / 2;
    }

    public Box() {
        x0 = 0;
        y0 = 0;
        w = 0;
        h = 0;
        x = 0;
        y = 0;
    }
    public Box(String decode){
    
    }

    public void draw() {
        
        strokeWeight(stroke_weight);
        stroke(stroke_color);
        fill(fill_color);
        rect(x0, y0, w, h);
        
    }
    
    public String encode(){
      return x0+","+y0+","+w+","+h+","+stroke_weight+","+red(stroke_color)+","+green(stroke_color)+","+blue(stroke_color)+","+alpha(stroke_color)+","+red(fill_color)+","+green(fill_color)+","+blue(fill_color)+ "," + alpha(fill_color)+"\n"; 
      //uses color
    }

}

// ball is special case of circle
public class Ball extends Circle {
    // mass
    private float mass = 1.0;
    // velocity
    Vec2 vel = new Vec2(0, 0);
    int trailSize = 10;
    Vec2[] prev_pos = new Vec2[trailSize];
    int firstIndex = 0;
    int lastIndex = 0;
    Ball() {
        super();
    }

    Ball(Vec2 pos, float r) {
        super(pos.x, pos.y, r);
        // random initial velocity
        // vel.x = random(-1, 1);
        // vel.y = random(-5, 5);
        for(int i = 0; i < trailSize; i++){
          prev_pos[i] = new Vec2(0, 0);
        }
    }

    // update position
    public void update(float dt) {
        // apply gravity
        vel.y += GRAVITY * dt;
        // update position
        
        pos.add(vel);
    }

    // bounce off line
    public void bounce(Line l) {
        // find the closest point on the line
        Vec2 closest = closest_point_on_line(pos, l.start, l.end);
        // find the vector from the closest point to the ball
        Vec2 n = pos.subtract_new(closest);
        // normalize the vector
        n.normalize();
        // TODO move the ball 1 radius away from the line plus the distance it was past the line
        pos = closest.add_new(n.mul_new(r));

        // find the velocity in the normal direction
        Vec2 v_n = projAB(vel, n);
        // subtract the velocity in the normal direction
        vel.subtract(v_n.mul_new(1 + COR));
    }
    
    // bounce off circle
    public void bounce(Circle c) {
        // vector between two centers
        Vec2 n = pos.subtract_new(c.pos);
        // normalize the vector
        n.normalize();
        // TODO move the ball 1 radius away from the circle plus the distance it was past the circle
        pos = c.pos.add_new(n.mul_new(c.r + r));
        // find the velocity in the normal direction
        Vec2 v_n = projAB(vel, n);
        // subtract the velocity in the normal direction
        vel.subtract(v_n.mul_new(1 + COR));
    }

    // bounce off flipper
    public void bounce(Flipper f) {
        // find the closest point on the line
        Vec2 closest = closest_point_on_line(pos, f.line.start, f.line.end);
        // find the vector from the closest point to the ball
        Vec2 n = pos.subtract_new(closest);
        // normalize the vector
        n.normalize();
        // if n.y is positive, flip the normal vector
        if (n.y > 0) n.mul(-1);
        pos = closest.add_new(n.mul_new(r+2));

        // check bounce type
        if (f.ang_vel > 0) {
            // return if time delay has not passed
            if (f.bounce_time < f.bounce_delay) return;
            f.bounce_time = 0;

            // find the linear velocity of the point on the flipper
            Vec2 radius = closest.subtract_new(f.verts0[0]);
            // scale the radius to avoid extreme speed
            radius.mul(1.0 / 70.0);
            Vec2 flip_v = new Vec2(-radius.y, radius.x).mul_new(f.ang_vel);
            if (f.negative) flip_v.mul(-1);
            // calculate new velocity using conservation of momentum
            float v_ball = dot(vel, n);
            float v_flip = dot(flip_v, n);
            float m1 = mass;
            float m2 = f.mass;
            float v_new = (COR*m2*(v_flip-v_ball) + m1*v_ball + m2*v_flip) / (m1+m2);
            vel.add(n.mul_new(v_new - v_ball));
        } else {
            // find the velocity in the normal direction
            Vec2 v_n = projAB(vel, n);
            // subtract the velocity in the normal direction
            vel.subtract(v_n.mul_new(1 + COR));
        }
    }

    // bounce off arc
    public void bounce(Arc a) {
        // vector between two centers
        Vec2 n = pos.subtract_new(a.pos);
        // normalize the vector
        n.normalize();
        // check if ball is inside or outside the arc
        float d = d_squared(pos, a.pos);
        if (d < a.r*a.r) {
            // inside the arc
            // move the ball 1 radius away from the arc interior
            pos = a.pos.add_new(n.mul_new(a.r - r));
            // find the velocity in the normal direction
            Vec2 v_n = projAB(vel, n);
            // subtract the velocity in the normal direction
            vel.subtract(v_n.mul_new(1 + COR));
            return;
        }
        // outside the arc
        // move the ball 1 radius away from the arc exterior
        pos = a.pos.add_new(n.mul_new(a.r + r));
        // find the velocity in the normal direction
        Vec2 v_n = projAB(vel, n);
        // subtract the velocity in the normal direction
        vel.subtract(v_n.mul_new(1 + COR));
    }

    // bouce off ball
    public void bounce(Ball b) {
        // vector between two centers
        Vec2 n = pos.subtract_new(b.pos);
        // find halfway point between two centers
        Vec2 halfway = b.pos.add_new(n.mul_new(0.5f));
        // normalize the vector
        n.normalize();
        // move both balls 1 radius away from halfway point
        pos = halfway.add_new(n.mul_new(r));
        b.pos = halfway.add_new(n.mul_new(-r));

        float v1 = dot(vel, n);
        float v2 = dot(b.vel, n);
        float m1 = mass;
        float m2 = b.mass;

        float new_v1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * COR) / (m1 + m2);
        float new_v2 = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * COR) / (m1 + m2);
        vel = vel.add_new(n.mul_new(new_v1 - v1));
        b.vel = b.vel.add_new(n.mul_new(new_v2 - v2));
    }
    
     public void draw(){
       prev_pos[lastIndex].x = pos.x;
        prev_pos[lastIndex].y = pos.y;
        lastIndex++;
        if(lastIndex >= trailSize) {
          lastIndex = 0;
        }
        if(lastIndex == firstIndex){
          firstIndex++;
          if(firstIndex >= trailSize){
            firstIndex = 0;
          }
        }
      pushMatrix();
        noStroke();
        
        float o = 100;
        fill(255, o);
        ellipse(pos.x, pos.y, r*2, r*2);
        blendMode(ADD);
        colorMode(HSB, 360, 100, 100, 100);
        
        for (int i=0; i<5; i++) {
          
          
          
          //rotate(TWO_PI * noise(sx, sy));
          fill(0, 90, 5, o);
          ellipse(pos.x, pos.y, r*2+i*3, r*2+i*3);
          fill(120, 90, 5, o);
          ellipse(pos.x, pos.y, r*2+i*4, r*2+i*4);
          fill(240, 90, 5, o);
          ellipse(pos.x, pos.y, r*2+i*5, r*2+i*5);
          
          
        }
    
    
        colorMode(RGB, 255, 255, 255);
        blendMode(BLEND);
        popMatrix();
      int i  = firstIndex;
      int traversed = 0;
      while(i != lastIndex){
        traversed++;
        fill(255, 255, 255);
        ellipse(prev_pos[i].x, prev_pos[i].y, map(traversed, 0, trailSize, 0, r*2), map(traversed, 0, trailSize, 0, r*2));
        i++;
        if(i >= trailSize){
          i=0;
        }
      }  
      
      
  }
  public String encode(){
      return pos.x+","+pos.y+","+r+"\n"; 
      //no color
  }
    
    
}

public class Flipper {
    // bounce time delay for single collision behavior
    public float bounce_time = 0;
    public float bounce_delay = 0.2f;
    // vertices default, index 0 is fixed point
    public Vec2[] verts0 = new Vec2[3];
    // vertices current
    public Vec2[] verts = new Vec2[3];
    // collision line
    public Line line = new Line();

    // angle
    public float angle = 0;
    public float min_angle = 0;
    public float max_angle = radians(45);
    // angular velocity
    public float ang_vel_max = 7;
    public float ang_vel = 0;
    private boolean negative = true;
    public boolean light = false;
    public float timer = 0;
    public float duration = 2;

    public int state = 0; // 0 still, 1 going up, -1 going down
    public float mass = 10.0;

    Flipper() {
        verts0[0] = new Vec2(0, 0);
        verts0[1] = new Vec2(0, 0);
        verts0[2] = new Vec2(0, 0);
        verts[0] = new Vec2(0, 0);
        verts[1] = new Vec2(0, 0);
        verts[2] = new Vec2(0, 0);
    }

    Flipper(Vec2 v0, Vec2 v1, Vec2 v2) {
        verts0[0] = v0;
        verts0[1] = v1;
        verts0[2] = v2;
        verts[0] = v0;
        verts[1] = v1;
        verts[2] = v2;
        line.start = v0;
        line.end = v1;
    }
    
    
    
    public void draw(){
      
      if(!light){
        pushMatrix();
        noStroke();
        
        float o = 100;
        fill(255,200, 255, o);
        triangle(verts[0].x, verts[0].y, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
        blendMode(ADD);
        colorMode(HSB, 360, 100, 100, 100);
        if(negative){
          fill(300, 100, 100, o);
          triangle(verts[0].x-10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
        } else {
          fill(300, 100, 100, o);
          triangle(verts[0].x+10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
        }
        colorMode(RGB, 255, 255, 255);
        blendMode(BLEND);
        popMatrix();
      } else {
        pushMatrix();
        noStroke();
        
        float o = 100;
        fill(255, map(timer, 0, duration, 255, 200), 255, o);
        triangle(verts[0].x, verts[0].y, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
        blendMode(ADD);
        colorMode(HSB, 360, 100, 100, 100);
        
        
          
          
          
          //rotate(TWO_PI * noise(sx, sy));
        fill(map(timer, 0, duration, 0, 300), map(timer, 0, duration, 90, 100), map(timer, 0, duration, 10, 100), o);
        if(negative){
        triangle(verts[0].x-10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      } else {
        triangle(verts[0].x+10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      }
        fill(map(timer, 0, duration, 120, 300), map(timer, 0, duration, 90, 100), map(timer, 0, duration, 10, 100), o);
        if(negative){
        triangle(verts[0].x-10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      } else {
        triangle(verts[0].x+10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      }
        fill(map(timer, 0, duration, 240, 300), map(timer, 0, duration, 90, 100), map(timer, 0, duration, 10, 100), o);
        if(negative){
        triangle(verts[0].x-10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      } else {
        triangle(verts[0].x+10, verts[0].y-10, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
      }
          
          
        
        
          
          
          
        
    
    
        colorMode(RGB, 255, 255, 255);
        blendMode(BLEND);
        popMatrix();
      }
    }

    /**public void draw() {
        strokeWeight(0);
        stroke(0);
        fill(RED);
        triangle(verts[0].x, verts[0].y, verts[1].x, verts[1].y, verts[2].x, verts[2].y);
    }**/

    public void update(float dt) {
      
        if(light) {
          timer += dt;
          if(timer >= duration){
            light = false;
            timer = 0;
          }
        }
        // update bounce time
        bounce_time += dt;
        // update angle
        if (state == 1) {
            ang_vel = ang_vel_max;
            angle += ang_vel * dt;
            if (angle >= max_angle) {
                angle = max_angle;
                state = 0;
            }
        } else if (state == -1) {
            ang_vel = -ang_vel_max;
            angle += ang_vel * dt;
            if (angle <= 0) {
                angle = 0;
                state = 0;
            }
        } else {
            ang_vel = 0;
            state = 0;
        }
        // update vertices
        float a = angle;
        if (negative) a = -angle;
        verts[1] = rotate_point(verts0[0], verts0[1], a);
        verts[2] = rotate_point(verts0[0], verts0[2], a);
        // update line
        line.end = verts[1];
    }
    
    public String encode(){
      return verts0[0].x+","+verts0[0].y+","+verts0[1].x+","+verts0[1].y+","+verts0[2].x+","+verts0[2].y+","+negative+"\n";
      //no color
    }

}

public class Launcher {
    public float vel_max = 20;
    public float vel = 0;
    private int state = 0; // 0 invisible, 1 increasing, 2 decreasing
    public color fill_color = LIME;
    // bottom left corner of rectangle
    public Vec2 pos = new Vec2(0, 0);
    private boolean ball_in_area = false;

    Launcher() {

    }

    Launcher(float x, float y) {
        pos.x = x;
        pos.y = y;
    }

    public void launch(Ball[] balls) {
        // check if ball is in launch area
        Ball b = null;
        for (Ball ball : balls) {
            if (ball.pos.x >= pos.x && ball.pos.x <= pos.x + 40 && ball.pos.y >= pos.y - 100) {
                b = ball;
            }
        }
        if (b == null) return;

        if (state == 0) {
            state = 1;
            vel = 0;
        } else {
            b.vel.x = 0;
            b.vel.y = -vel;
            state = 0;
            vel = 0;
        }
    }

    public void update(float dt, Ball[] balls) {
        // check if a ball is in launch area
        ball_in_area = false;
        for (Ball b : balls) {
            if (b.pos.x >= pos.x && b.pos.x <= pos.x + 40 && b.pos.y >= pos.y - 100) {
                ball_in_area = true;
            }
        }
        if (!ball_in_area) {
            vel = 0;
            state = 0;
        }
        // update velocity
        if (state == 1) {
            vel += vel_max * dt;
            if (vel >= vel_max) {
                vel = vel_max;
                state = 2;
            }
        } else if (state == 2) {
            vel -= vel_max * dt;
            if (vel <= 0) {
                vel = 0;
                state = 1;
            }
        }
    }

    public void draw() {
        strokeWeight(0);
        stroke(0);
        fill(fill_color);
        // height of rectangle is vel scaled to 100
        float h = vel/vel_max * 100;
        // y is shifted by height
        rect(pos.x, pos.y-h, 40, h);
    }
    
    public String encode(){
      return pos.x+","+pos.y+","+red(fill_color)+","+green(fill_color)+","+blue(fill_color)+ "," + alpha(fill_color)+"\n"; 
      //uses color
    }
}

public class Arc {
    public float x, y, r, start, end;
    public Vec2 pos = new Vec2(0, 0);
    public int stroke_weight = 1;
    public color stroke_color = color(0, 0, 0);

    Arc() {
        pos.x = 0;
        pos.y = 0;
        r = 0;
        start = 0;
        end = 0;
    }

    Arc(float x, float y, float r, float start, float end) {
        this.pos.x = x;
        this.pos.y = y;
        this.r = r;
        this.start = start;
        this.end = end;
    }

    public void draw() {
        strokeWeight(stroke_weight);
        stroke(stroke_color);
        noFill();
        arc(pos.x, pos.y, r*2, r*2, start, end);
    }
    public String encode(){
      return pos.x+","+pos.y+","+r+","+start+","+end+","+stroke_weight+","+red(stroke_color)+","+green(stroke_color)+","+blue(stroke_color)+","+alpha(stroke_color)+"\n"; 
      //uses color
    }
}

// hole is special case of box
public class Hole extends Box {
    Hole() {
        super();
    }

    Hole(float x0, float y0, float w, float h) {
        super(x0, y0, w, h);
        stroke_weight = 0;
        fill_color = RED;
    }
    
    public void draw() {
      noStroke();
      fill(fill_color);
      rect(x0, y0, w, h);
    }
    public String encode(){
      return x0+","+y0+","+w+","+h+","+red(fill_color)+","+green(fill_color)+","+blue(fill_color)+ "," + alpha(fill_color)+"\n"; 
      //uses color
    }
}
