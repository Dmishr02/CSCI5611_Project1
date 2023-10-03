public class Background {
  public int scl  = 20;
  public int h = 1500;
  public int w = 3000;
  public int cols, rows;
  float[][] terrain;
  public int radiusOffset = 30; 
  float flying = 0;
  
  public Background(){
    cols = w/scl;
    rows = h/scl;
    
    terrain = new float[cols][rows];
    float yoff = 0;
    for(int y = 0; y < rows; y++){
      float xoff = 0;
      for(int x = 0; x < cols; x++){
        terrain[x][y] = map(noise(xoff, yoff), 0, 1, -50, 50);
        xoff+=0.1;
      }
      yoff+=0.1;
    }
  }
  
  public void update(){
    radiusOffset +=1;
    if(radiusOffset >= 200){
      radiusOffset = 30;
    }
    flying -= 0.1;
    float yoff = flying;
    for(int y = 0; y < rows; y++) {
      float xoff = 0;
      for(int x = 0; x < cols; x++) {
        terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100);
        xoff+=0.2;
      }
      yoff+=0.1;
    }
  }
  
  public void show(){
    noStroke();
    blendMode(BLEND);
    fill(220, 100, 250);
    ellipse(width/2, 100, 400, 400);
    
    blendMode(ADD);
    
    fill(220, 100, 250, 100-map(radiusOffset, 30, 200, 0, 100));
    ellipse(width/2, 100, 400+radiusOffset, 400+radiusOffset);
    
    
    fill(220, 100, 250, 100-map(radiusOffset, 30, 200, 0, 100));
    ellipse(width/2, 100, 400+radiusOffset-60, 400+radiusOffset-60);
    
    fill(157, 68, 192);
    ellipse(width/2, 100, 400, 400);
    
    pushMatrix();
    
    
    
    translate(width/2, height/2);
    rotateX(PI/2 - 0.1);
    translate(0, 0, -100);
    translate(-w/2, -h/2);
    
    for(int y = 0; y < rows-1; y++) {
      beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < cols; x++) {
        
        //stroke(157, 68, 192, map(y, 0, rows, 0, 255));
        //fill(77, 45, 183, map(y, 0, rows, 0 ,255));
        stroke(100, 18, 132, map(y, 0, rows, 0, 255));
        fill(36, 0, 120, map(y, 0, rows, 0 ,255));
        vertex(x*scl, y*scl, terrain[x][y]);
        vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      }
      endShape();
      
    }
    popMatrix();
    blendMode(BLEND);
  
  }
  
}
  
