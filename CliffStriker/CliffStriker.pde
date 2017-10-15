import processing.sound.*;
import java.util.Iterator;

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

Ball ball;
Bell bell;
Character ch;
ConfettiSystem conf;
WindSystem wind;
int particleCount = 0;

SoundFile ring;
SoundFile pop;

void setup() {
    size(540, 960, P3D);
    
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
    
    ball = new Ball(new PVector(width / 2, 7 * height / 8));
    bell = new Bell();
    conf = new ConfettiSystem(new PVector(width / 2, height / 8));
    ring = new SoundFile(this, "ring.mp3");
    pop = new SoundFile(this, "pop.mp3");
    ch = new Character(new PVector(width / 2, 5 * height / 8 - 10));
    wind = new WindSystem();
}

void draw() {
    background(255);
    drawbackground();
    
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
        ch.drop(average - thresh * limit);
    
    if (particleCount > 0) {
        conf.addConfetto();
        particleCount--;
    }
    
    conf.run();
    ball.run();
    ch.run();
    bell.draw();
    wind.update();
}

void keyPressed() {
    if (key == ' ')
        render = !render;
    else if (key == '\n')
        conf.fire();
    else if (key == '0')
        ball.react(0);
    else if (key == '1')
        ball.react(1);
    else if (key == '2')
        ball.react(2);
    else if (key == '3')
        ball.react(3);
    else if (key == 'i' || key == 'I')
        thresh++;
    else if (key == 'd' || key == 'D')
        thresh--;
    else
        System.out.println(thresh * limit);
}

void drawbackground() {
    noFill();
    stroke(204, 102, 0);
    rect(0, 5*height/8, 3*width/8, 3*height/8);
    rect(5*width/8, 5*height/8, 3*width/8, 3*height/8);
    stroke(0);
    line(3*width/8, 5*height/8, 5*width/8, 5*height/8);

    pushMatrix();
    translate(width / 2, 15 * height / 16);
    rotateX(PI / 2.2);
    ellipse(0, 0, width / 5, width / 5);
    ellipse(0, 0, width / 7, width / 7);
    ellipse(0, 0, width / 11, width / 11);
    popMatrix();

    wind.draw();
}

void arrow(float x1, float y1, float x2, float y2) {
    float a = 2 * dist(x1, y1, x2, y2) / 50;
    pushMatrix();
    translate(x2, y2);
    rotate(atan2(y2 - y1, x2 - x1));
    triangle(- a * 2 , - a, 0, 0, - a * 2, a);
    popMatrix();
    line(x1, y1, x2, y2);  
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
        Node e = root;
        int x  = 0;
        e.draw(0);
        for (e = root; e.next != null; e = e.next) {
            x = i * width / this.limit;
            e.draw(x);
            i++;
        }
        e.draw(x);
        e.draw(x);
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

class Ball {

    PVector location, velocity, acceleration, ground;
    boolean shot = false,
        topped = false;
    
    Ball (PVector location) {
        this.location = location;
        this.ground = location.copy();
        velocity = new PVector(0, 0);    
        acceleration = new PVector(0, 0);
    }
    
    void run () {
        update();
        stroke(0);
        strokeWeight(1);
        fill(175);
        ellipse(location.x, location.y, 20, 20);
        if (location.y > ground.y)
            reset();
        if (location.y < height / 8) {
            reflect();
            bell.ring();
        }
    }
    
    void reset() {
        shot = false;
        topped = false;
        location = ground.copy();
        velocity = new PVector(0, 0);
        acceleration = new PVector(0,0);
        ch.reset();
    }

    void reflect() {
        velocity = new PVector(0, -velocity.y);
    }
    
    void update() {
        velocity.add(acceleration);
        location.add(velocity);
        //    event that the ball has reached the top of its firing arc without
        //    actually hitting the bell
        if (round(velocity.y) == 0 && location.y < 7 * height / 8 && !topped)
            react(location.y);
    }
    
    void react(float y) {
        topped = true;
        int nostages = 4;
        System.out.println("Topped out");
        System.out.println(y);
        
        //    create some effects without branching (which decreases perf.)
        int stage = floor(((7 * height / 8) - y) / (3 * height / 4) * nostages);
        react(stage);
        //TODO: find party sounds and boom sounds (fireworks), put them
        //into an array, and play at the index marked by stage.
    }
    
    void react(int stage) {
        conf.fire(2 * stage * 10 + 5);
        //pop.play(); 
        //play sound here
    }
    
    void applyGravity(PVector gravity) {
        acceleration = gravity;
    }
    
    void shoot(float force) {
        if (shot)
            return;
        velocity = new PVector(0, (float) (-launchConstant * Math.log(force)));
        applyGravity(new PVector(0, 0.3));
        shot = true;
    }
}

class Bell {
    
    Bell () {}

    void ring () {
        ring.play();
        //pop.play();
        conf.fire(100);
        particleCount += 150;
    }
    
    void draw() {
        stroke(0);
        fill(200);
        strokeWeight(1);
        ellipse(width/2, height/8, 30, 30);
    }
}

class ConfettiSystem {
    ArrayList<Confetto> particles;
    PVector origin;
    color[] colors = new color[]{color(255,80,80), color(255,255,0), color(51,204,255)};

    ConfettiSystem(PVector location) {
        origin = location.copy();
        particles = new ArrayList<Confetto>();
    }

    void addConfetto() {
        particles.add(new Confetto(origin));
        //particles.add(new Confetto(origin, colors[(int) random(0,3)]));
    }

    void fire () {
        for (int i = 0; i < 50; i++)
            this.addConfetto();
    }
    
    void fire (int count) {
        for (int i = 0; i < count; i++)
            this.addConfetto();
    }
    
    void run() {
        noStroke();
        Iterator<Confetto> it = particles.iterator();
        while (it.hasNext()) {
            Confetto p = it.next();
            p.run();
            if (p.isDead())
                it.remove();
        }
    }
}

class Confetto {
    PVector location;
    PVector velocity;
    PVector acceleration;
    float lifespan;
    color c;
    int z;
    float xangle, zangle;
    
    Confetto(PVector l) {
        z = (int) random(-50,50);
        xangle = random(0, 2 * PI);
        zangle = random(0, 2 * PI);
        location = l.copy();
        velocity = new PVector(random(-1, 1), random(-2, 0));
        acceleration = new PVector(0, 0.05);
        lifespan = (int) random(300, 400);
        c = color(round(random(50,255)), round(random(50,255)), round(random(50,255)));
    }
    
    Confetto(PVector l, color c) {
        this(l);
        this.c = c;
    }
    
    void update() {
        velocity.add(acceleration);
        location.add(velocity);
        lifespan -= 0.5;
        if (location.y > 15*height/16) {
            acceleration = new PVector(0, 0);
            velocity.mult(0.1);
        }
    }
    
    void display() {
        pushMatrix();
        translate(location.x, location.y, z);
        rotateX(xangle);
        rotateZ(zangle);
        fill(c);
        rect(0, 0, 10, 10);
        popMatrix();
    }
    
    void run() {
        update();
        display();
    }
    
    boolean isDead() {
        return lifespan < 0.0;   
    }
}

class Character extends Ball {

    boolean dropping, anim;
    float mag;
    PVector flr;

    Character (PVector location) {
        super(location);
        dropping = false;
        anim = false;
        flr = new PVector(width / 2, 15 * height / 16);
    }

    void run () {
        update();
        stroke(0);
        strokeWeight(1);
        fill(225);
        ellipse(location.x, location.y, 20, 20);
    }

    void drop(float mag) {
        if (dropping || anim)
            return;
        println("dropping");
        this.mag = mag;
        dropping = true;
        applyGravity(new PVector(0, 0.3));
    }

    void update() {
        if (dropping)
            wind.gust(velocity, mag);
        velocity.add(acceleration);
        location.add(velocity);

        if (location.y > flr.y) {
            velocity.mult(0);
            acceleration.mult(0);
            dropping = false;
            location.y = flr.y;
            anim = true;
            this.react();
        }
    }

    void react () {
        println("shooting");
        ball.shoot(this.mag);
    }

    void reset () {
        location = ground.copy();
        dropping = false;
        anim = false;
        velocity.mult(0);
        acceleration.mult(0);
    }

}

class WindSystem {

    int frames;
    float wind;
    
    WindSystem() {
        frames = 0;
        wind = 0.01;
    }

    void update() {
        if (--frames <= 0) {
            frames = (int) random(60, 360);
            wind = (float) Math.random();
            if (Math.random() < 0.5)
                wind = -wind;
        }
    }

    void gust (PVector o) {
        o.x += wind;
    }

    void gust (PVector o, float dampening) {
        o.x += wind / dampening;
    }

    void draw () {
        stroke(0);
        line(width / 4, 5 * height / 8, width / 4, height / 2);
        if (wind < 0)
            arrow(width / 8, height / 2, 3 * width / 8, height / 2);
        else
            arrow(3 * width / 8, height / 2, width / 8, height / 2);
    }

}
