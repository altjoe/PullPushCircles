import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PullPushCircles extends PApplet {

Push push;
Pull pull;


ArrayList<RainLine> lines = new ArrayList<RainLine>();
boolean raining = true;
public void setup() {
    
    background(255);
    for (int i = 0; i < 100; i++){
        float x = (width*1.3f*i)/100 - width/5;
        RainLine line = new RainLine(x, -50);
        lines.add(line);
    }
    
    pull = new Pull(width/2, height/2);
    push = new Push(width/2, height/2);
    
}

int waves = 1;
public void draw() {
    background(255);
    for (RainLine line : lines){
        line.doAll();
    }
    
    // if (frameCount < 500 * waves && waves < 5){
    //     if (frameCount % 50 == 0){
    //     raining = !raining;
    //     } else if (frameCount % 20 == 0 && !raining){
    //         raining = true;
    //     }
    // } else {
    //     waves += 1;
    // }
    if (!hardrain){
        rainperc -= rainsub;
    } else{
        hardraincount += 1;
        if (hardraincount > 60){
            hardrain = false;
        }
    }
    
    if (rainperc < 100){
        rainsub *= -1;
        hardrain = true;
    } else if (rainperc > 500){
        rainsub *= -1;
    }
    push.display();
}
int hardraincount = 0;
boolean hardrain = false;
int rainsub = 1;
int rainperc = 500;
class RainLine{
    ArrayList<Point> drops = new ArrayList<Point>();
    PVector loc;
    int disttillnext = 5;
    public RainLine(float x, float y){
        loc = new PVector(x, y);
        if (PApplet.parseInt(random(0,rainperc)) == 0){
            newDrop();
        }
        
    }

    public void newDrop(){
        if (drops.size() > 0){
            Point prevdrop = drops.get(drops.size()-1);
            PVector lastDisplay = prevdrop.stack.pts.get(prevdrop.stack.pts.size()-1);
            float dist = PVector.sub(lastDisplay, loc).mag();
            if (dist > disttillnext){
                shootone();
                disttillnext = PApplet.parseInt(random(10, 30));
            }
        } else{
            shootone();
        }
    }

    public void shootone(){
        if (PApplet.parseInt(random(0, rainperc)) == 0 && raining){
            Point pt = new Point(loc.x, loc.y);
            drops.add(pt);
        }
        
    }



    public void doAll(){
        for (int i = drops.size()-1; i >= 0; i--){
            Point pt = drops.get(i);
            pt.move();
            pt.curr = push.moveOut(pt);
            pt = pull.moveIn(pt);
            pt.addStack();
            pt.display();
        }
        newDrop();
    }
}


class Push {
    float radius = 100;
    PVector loc;

    public Push(float x, float y){
        loc = new PVector(x, y);
    }

    public PVector moveOut(Point pt){
        PVector dir = PVector.sub(pt.curr, loc);
        
        
        if (dir.mag() < radius+1){
            PVector newCurr = pt.curr.copy();
            PVector norm = PVector.sub(newCurr, loc);
            norm.normalize().setMag(0.01f);
            
            
            float dist = PVector.sub(newCurr, loc).mag();
            while(dist < radius+1){
                newCurr = PVector.add(newCurr, norm);
                dist = PVector.sub(newCurr, loc).mag();
            }

            if (pt.firstbounce){
                norm.normalize().setMag(pt.bounce);
                newCurr = PVector.add(newCurr, norm);
                pt.firstbounce = false;
            } 

            return newCurr;
        }
        return pt.curr;
    }

    public void display(){
        fill(0);
        ellipse(loc.x, loc.y, radius*2, radius*2);
    }
}

class Pull {
    PVector loc;
    float radius = 110;
    public Pull(float x, float y){
        loc = new PVector(x, y);
    }

    public Point moveIn(Point pt){
        float dist = PVector.sub(pt.curr, loc).mag();
        if (dist < radius){
            PVector dir = PVector.sub(pt.curr, loc);
            dir.normalize().setMag(pt.waterTension);
            pt.curr = PVector.sub(pt.curr, dir);
        }
        return pt;
    }
}

class Point {
    PVector curr;
    PVector prev;
    float speed = 1;
    float gravity = 0.01f;
    float wind = 0.005f;
    boolean firstbounce = true;
    float waterTension = random(0.02f, 0.03f);
    float bounce;
    Stack stack;

    public Point(float x, float y){
        curr = new PVector(x, y);
        prev = new PVector(x, y - speed);
        stack = new Stack(PApplet.parseInt(random(2, 20)));
        bounce = random(0.7f, 2);
    }

    public void move(){
        PVector diff = PVector.sub(curr, prev);
        prev = curr.copy();
        curr = PVector.add(curr, diff);
        curr.y += gravity;
        curr.x += wind * random(0, 1);
    }

    public void display(){
        // fill(0);
        // ellipse(curr.x, curr.y, 3, 3);
        noFill();
        strokeWeight(3);
        for (int i = 1; i < stack.pts.size(); i++){
            PVector pt1 = stack.pts.get(i -1);
            PVector pt2 = stack.pts.get(i);
            
            line(pt1.x, pt1.y, pt2.x, pt2.y);
        }
    }

    public void addStack(){
        stack.push(curr);
    }
}

class Stack {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    int s;
    public Stack(int s){
        this.s = s;
    }
    public void push(PVector pt){
        pts.add(0, pt);
        if (pts.size() > s){
            pts.remove(pts.size()-1);
        }
    }
}
  public void settings() {  size(512, 512); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PullPushCircles" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
