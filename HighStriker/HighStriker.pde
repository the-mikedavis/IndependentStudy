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
ConfettiSystem conf;
//BirdSystem birds;
int particleCount = 0;

SoundFile ring;

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
    //birds = new BirdSystem(2);
    ring = new SoundFile(this, "ring.mp3");
}

void draw() {
    background(255);
    
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
        ball.shoot(average - thresh * limit);
    
    if (particleCount > 0) {
        conf.addConfetto();
        particleCount--;
    }
    
    conf.run();
    ball.run();
    //birds.run();
    bell.draw();
}

void keyPressed() {
    if (key == ' ')
        render = !render;
    else if (key == '\n')
        conf.fire();
    else if (key == 'i' || key == 'I')
        thresh++;
    else if (key == 'd' || key == 'D')
        thresh--;
    else
        System.out.println(thresh * limit);
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

class Ball {

    PVector location, velocity, acceleration, ground;
    boolean shot = false;
    
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
        location = ground.copy();
        velocity = new PVector(0, 0);
        acceleration = new PVector(0,0);
    }

    void reflect() {
        velocity = new PVector(0, -velocity.y);
    }
    
    void update() {
        velocity.add(acceleration);
        location.add(velocity);
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
        particleCount += 150;
        System.out.println("Ring!");
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
        if (location.y > 7*height/8) {
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

class Bird {
    PVector location, velocity;
    int offset;
    
    Bird(PVector start, PVector velocity) {
        this.location = start;
        this.velocity = velocity;
        offset = (int) (Math.random() * 30);
    }
    
    void run () {
        float frame = (float) Math.abs(60 - (frameCount + offset) % 120);
        float angle = map(frame, 0.0, 60.0, (float)(5*Math.PI/6), (float)(4*Math.PI/3));
        float x = 12 * (float) Math.cos(angle),
            y = 12 * (float) Math.sin(angle);
        
        this.location.add(this.velocity);
        strokeWeight(1);
        fill(20);
        ellipse(location.x, location.y, 5, 5);
        strokeWeight(3);
        line(location.x, location.y, location.x - 8, location.y - 5);
        line(location.x, location.y, location.x + 8, location.y - 5);
        strokeWeight(2);
        line(location.x - 8, location.y - 5, location.x - 8 + x, location.y - 5 + y);
        line(location.x + 8, location.y - 5, location.x + 8 - x, location.y - 5 + y);
    }
    
    boolean isDead() {
        return location.x < 0 || location.x > width;
    }
}

class BirdSystem {
    ArrayList<Bird> birds;
    float speed = 1.5;
    
    BirdSystem (int count) {
        birds = new ArrayList<Bird>(count);
        for (int i = 0; i < count; i++)
            this.addBird();
    }
    
    void run () {
        Iterator<Bird> it = birds.iterator();
        while (it.hasNext()) {
            Bird b = it.next();
            b.run();
            if (b.isDead()) {
                it.remove();
                addBird();
                break;
            }
        }
    }
    
    void addBird() {
        //give it random height and starting side
        int x = Math.round(Math.random()) == 0L ? 0 : width,
            y = (int)(Math.random()*(height / 8)) + height / 4;
        Bird newBird = new Bird(new PVector(x, y),
            new PVector((x == width ? -speed : speed) + (float)Math.random(), 0));
        birds.add(newBird);
    }
}