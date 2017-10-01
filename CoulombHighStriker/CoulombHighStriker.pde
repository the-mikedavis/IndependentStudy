import java.util.ArrayList;
import processing.sound.*;

FDGraph system;
Body center;

FFT fft;
AudioIn in;
Spline threshSpline, totalSpline, triggerSpline, baseLine;
int bands = 32;
float scale = 2000.0, smoothing = 0.001;
float total, average, thresh;
boolean render = false;
float limit = 15.0;
float launchConstant = 4.0;
int root;

Puck puck;

void setup () {
    size(540, 960);
    system = new FDGraph(50);   
    center = new Body(10f, 10f, new PVector(width / 2, height / 4));
    
    puck = new Puck(0f, 0f, new PVector(width / 2, 7 * height / 8));
    
    in = new AudioIn(this, 0);
    in.start();
    fft = new FFT(this, bands);
    fft.input(in);
    
    thresh = 10.0;
    
    int splineCount = 100;
    baseLine = new Spline(splineCount, color(0));
    threshSpline = new Spline(splineCount, color(0, 0, 255));
    totalSpline = new Spline(splineCount, color(255, 0, 0));
    triggerSpline = new Spline(splineCount, color(0, 255, 0));
    root = 7 * height / 8;
    
    launchConstant = (float) height / 240;
}

void draw () {
    background(255);
    system.run();
    
    fft.analyze();
    total = 0;
    for (int i = 0; i < bands; i++)
        total += fft.spectrum[i] * scale;
    average = total / bands;
    thresh += (average - thresh) * smoothing;
    
    int tot = root - (int) average,
        thr = root - (int) thresh,
        tri = root - (int) (limit * thresh);
        
    baseLine.addPoint(root);
    totalSpline.addPoint(tot);
    threshSpline.addPoint(thr);
    triggerSpline.addPoint(tri);

    if (render) {
        baseLine.render();
        totalSpline.render();
        threshSpline.render();
        triggerSpline.render();
    }
    
    // Trigger statement
    if (average > limit * thresh)
        puck.shoot(average - thresh * limit);
        
    puck.render();
}

void keyPressed() {
    if (key == ' ')
        render = !render;
    else if (key == 'i' || key == 'I')
        thresh++;
    else if (key == 'd' || key == 'D')
        thresh--;
    else
        System.out.println(thresh * limit);
}

class FDGraph {
    
    ArrayList<Body> system;

    FDGraph (int count) {
        system = new ArrayList<Body>(count);
        for (int i = 0; i < count; i++)
            add();
    }

    boolean add () {
        return system.add(new Body(2f, 5f));
    }

    Body remove () {
        return system.remove((int) Math.random() * system.size());
    }

    Body remove (int index) {
        return system.remove(index);
    }

    void update () {
        for (Body a : system) {
            for (Body b : system)
                if (!a.equals(b))
                    a.applyForceFrom(b);
            a.update();
            a.applyForceFrom(puck);
        }
    }

    void run () {
        update();
        stroke(1);
        fill(255, 0, 0);
        for (Body b : system)
            b.render();
    }
}

class Puck extends Body {
    
    PVector ground;
    boolean shot = false;

    Puck (float mass, float charge, PVector location) {
        super(mass, charge, location);
        ground = location.copy();
    }
    
    void render () {
        update();
        stroke(0);
        strokeWeight(1);
        fill(175);
        ellipse(location.x, location.y, 20, 20);
        if (location.y > ground.y)
            reset();
        if (location.y < height / 8) {
            reflect();
        }
    }
    
    void reflect() {
        velocity.mult(-1);
    }
    
    void reset() {
        location = ground.copy();
        shot = false;
        velocity = new PVector(0,0);
        acceleration = new PVector(0,0);
    }
    
    @Override
    void update () {
        charge = map(location.y, 7*height/8, height/8, 0, 40);
        velocity.add(acceleration);
        location.add(velocity);
    }
    
    @Override
    void applyGravity () {
        acceleration = new PVector(0, 0.3);
    }
    
    void shoot(float force) {
        if (shot)
            return;
        velocity = new PVector(0, 
            (float) (-launchConstant * Math.log(force)));
        applyGravity();
        shot = true;
    }

}

class Body {

    int radius;
    PVector location, velocity, acceleration;
    float mass, charge;

    Body (float mass, float charge) {
        this.radius = 50;
        location = new PVector(random(width), random(height));
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        this.mass = mass;
        this.charge = charge;
    }
    
    Body (float mass, float charge, PVector location) {
        this.radius = (int) mass * 25;
        this.mass = mass;
        this.charge = charge;
        this.location = location;
        velocity = new PVector(0,0);
        acceleration = new PVector(0,0);
    }

    void render () {
        ellipse(location.x, location.y, radius, radius);
    }

    void update () {
        this.applyFriction();
        this.applyGravity();
        this.applyCharge(center);
        velocity.add(acceleration);
        location.add(velocity);
        acceleration.mult(0);
    }

    void applyForceFrom (Body o) {
        this.applyCharge(o);
        //this.applySpring(o);
    }

    //  Repelling force
    void applyCharge (Body o) {
        float C = 2f;
        PVector force = PVector.sub(this.location, o.location);
        float dist = force.mag();
        //  always repel when they have the same signs
        float m = (C * this.charge * o.charge) / (dist * dist);
        force.normalize();
        force.mult(m);
        this.applyForce(force);
    }

    void applyFriction () {
        float c = 0.01;
        PVector force = velocity.copy();
        force.mult(-1);
        force.normalize();
        force.mult(c);
        this.applyForce(force);
    }

    //  Suck into the center of the pane
    void applyGravity () {
        float G = 0.1;
        //PVector center = new PVector(width / 2, height / 2);
        PVector force = PVector.sub(this.location, center.location);
        float dist = force.mag();
        //  negative because it's an attractive force.
        float m = - (G * this.mass * center.mass) / (float)Math.cbrt(dist * dist);
        //System.out.println(m);
        force.normalize();
        force.mult(m);
        this.applyForce(force);
    }

    //  Nature of code
    void applyForce (PVector force) {
        PVector f = force.copy();
        f.div(mass);
        acceleration.add(f);
    }

}

class Spline {    //combination of path generator & linked list (queue style)
    
    Node root, tail;
    int count = 0, limit;
    color col;
    
    Spline(int limit, color c) {
        this.limit = limit;
        this.col = c;
    }
    
    void addPoint(int c) {
        Node e = new Node(c, null);
        if (root == null)
            root = tail = e;
        else
            tail = tail.next = e;
        
        if (count == this.limit)
            root = root.next;
        else
            count++;
    }
    
    void render() {
        noFill();
        stroke(this.col);
        strokeWeight(1);
        beginShape();
        int i = 0;
        for (Node e = root; e != null; e = e.next) {
            int x = i * width / this.limit;
            if (e.equals(root) || e.next == null) //draw the first and last point twice.
                e.draw(x);
            e.draw(x);
            i++;
        }
        endShape();
    }
    
    class Node {
        
        int c;
        Node next;
        
        Node(int magnitude, Node next) {
            this.c = magnitude;
            this.next = next;
        }
        
        void draw (int x) {
            curveVertex(x, this.c);
        }
        
        boolean equals(Node that) {
            if (this.next == null && that.next == null)
                return this.c == that.c;
            return this.c == that.c &&
                (this.next != null && that.next != null) &&
                (this.next.equals(that.next));
        }
    }
}