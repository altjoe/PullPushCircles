Push push;
Pull pull;

Recording record;
ArrayList<RainLine> lines = new ArrayList<RainLine>();
boolean raining = true;
void setup() {
    size(1080, 1080);
    background(255);
    for (int i = 0; i < 100; i++){
        float x = (width*1.3*i)/100 - width/5;
        RainLine line = new RainLine(x, -50);
        lines.add(line);
    }
    
    pull = new Pull(width/2, height/2);
    push = new Push(width/2, height/2);
    record = new Recording();
    record.start();
}

int waves = 1;
void draw() {
    background(255);
    for (RainLine line : lines){
        line.doAll();
    }
    
    if (!hardrain || frameCount >= 4000){
        rainperc += rainsub;
    } else{
        hardraincount += 1;
        if (hardraincount > 200){
            hardrain = false;
            hardraincount = 0;
            rainperc = 50;
        }
    }
    
    if (rainperc < 50 && !hardrain){
        rainsub = 1;
        hardrain = true;
    } else if (rainperc > 500 && !hardrain && frameCount < 4000){
        rainsub = -1;
    }
    push.display();

    record.control();
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
        if (int(random(0,rainperc)) == 0){
            newDrop();
        }
        
    }

    void newDrop(){
        if (drops.size() > 0){
            Point prevdrop = drops.get(drops.size()-1);
            PVector lastDisplay = prevdrop.stack.pts.get(prevdrop.stack.pts.size()-1);
            float dist = PVector.sub(lastDisplay, loc).mag();
            if (dist > disttillnext){
                shootone();
                disttillnext = int(random(10, 30));
            }
        } else{
            shootone();
        }
    }

    void shootone(){
        if (int(random(0, rainperc)) == 0 && raining && frameCount < 5000){
            Point pt = new Point(loc.x, loc.y);
            drops.add(pt);
        }
        
    }

    void removefinished(){
        for (int i = drops.size(); i >= 0; i--){
            Point drop = drops.get(i);
            if (drop.finished){
                drops.remove(i);
            }
        }
    }

    void doAll(){
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
    float radius = 100*2;
    PVector loc;

    public Push(float x, float y){
        loc = new PVector(x, y);
    }

    PVector moveOut(Point pt){
        PVector dir = PVector.sub(pt.curr, loc);
        
        
        if (dir.mag() < radius+1){
            PVector newCurr = pt.curr.copy();
            PVector norm = PVector.sub(newCurr, loc);
            norm.normalize().setMag(0.01);
            
            
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

    void display(){
        fill(0);
        ellipse(loc.x, loc.y, radius*2, radius*2);
    }
}

class Pull {
    PVector loc;
    float radius = 110*2;
    public Pull(float x, float y){
        loc = new PVector(x, y);
    }

    Point moveIn(Point pt){
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
    float gravity = 0.01;
    float wind = 0.005;
    boolean firstbounce = true;
    float waterTension = random(0.02, 0.03);
    float bounce;
    Stack stack;
    boolean finished = false;
    public Point(float x, float y){
        curr = new PVector(x, y);
        prev = new PVector(x, y - speed);
        stack = new Stack(int(random(2, 20)));
        bounce = random(0.7, 2);
    }

    void move(){
        PVector diff = PVector.sub(curr, prev);
        prev = curr.copy();
        curr = PVector.add(curr, diff);
        curr.y += gravity;
        curr.x += wind * random(0, 1);
    }

    void display(){
        // fill(0);
        // ellipse(curr.x, curr.y, 3, 3);
        noFill();
        strokeWeight(6);
        for (int i = 1; i < stack.pts.size(); i++){
            PVector pt1 = stack.pts.get(i -1);
            PVector pt2 = stack.pts.get(i);
            
            line(pt1.x, pt1.y, pt2.x, pt2.y);
        }

        PVector lastpt = stack.pts.get(stack.pts.size()-1);
        if (lastpt.y > height){
            finished = true;
        }
    }



    void addStack(){
        stack.push(curr);
    }
}

class Stack {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    int s;
    public Stack(int s){
        this.s = s;
    }
    void push(PVector pt){
        pts.add(0, pt);
        if (pts.size() > s){
            pts.remove(pts.size()-1);
        }
    }
}

class Recording {
    boolean recording = false;
    boolean stopped = false;
    int start_frame;
    int stop_frame;
    int frame_rate = 30;
    int recording_time = 200;

    public Recording() {
        
    }

    void start(){
        if (recording == false && stopped == false) {
                recording = true;
                start_frame = frameCount;
                stop_frame = start_frame + (frame_rate * recording_time);
        }
    }

    void control(){
        if (recording) {
            saveFrame("output/img-####.png");
            if (stop_frame < frameCount) {
                stopped = true;
                recording = false;
            }
            print(stop_frame, frameCount, '\n');
            if (stopped) {
                println("Finished.");
                System.exit(0);
            }
        }
    }
}