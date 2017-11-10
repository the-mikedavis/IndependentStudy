import java.util.ArrayList;
import processing.sound.*;

FDGraph system;
Body center;


FFT fft;
AudioIn in;
Spline threshSpline, totalSpline, triggerSpline, baseLine;
int bands = 32;
float scale = 2000.0, smoothing = 0.005;
float total, average, thresh;
boolean render = false;
float limit = 15.0;
float launchConstant = 4.0;
int root;
int ballScale;

Puck puck;
PImage[] balls;
SoundFile bounce;

void setup () {
    size(540, 960);

    bounce = new SoundFile(this, "ball_bounce.wav");
    bounce.play();
    bounce.rate(0.75);
    balls = new PImage[6];
    ballScale = width / 10;
    for (int i = 0; i < balls.length; i++) {
        balls[i] = loadImage("ball" + i + ".png");
        balls[i].resize(ballScale, ballScale);
    }

    system = new FDGraph(260);   
    center = new Body(10f, 10f, new PVector(width / 2, height / 4));

    puck = new Puck(0f, 0f, new PVector(width / 2, height / 2));

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
    background(22, 22, 22);
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
        println(thresh * limit);
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
        return system.remove((int) (Math.random() * system.size()));
    }

    Body remove (int index) {
        return system.remove(index);
    }

    void update () {
        boolean play = false;
        for (Body a : system) {
            for (Body b : system)
                if (!a.equals(b)) {
                    float force = a.applyForceTo(b);
                    if (force > 1.1)
                        play = true;
                }

            puck.deflect(a);
        }

        int frame = (int) random(5, 10);
        if (play && (frameCount % frame) == 0) {
            bounce.play();
        }

        for (Body a : system)
            a.update();
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

    boolean shot = false;
    float ground, ceiling;

    Puck (float mass, float charge, PVector location) {
        super(mass, charge, location);
        this.ground = width * 0.02;
        this.radius = (int) ground;
        ceiling = 3 * width / 5f;
    }

    void render () {
        update();
        if (radius > ceiling)
            reset();
    }

    void reset() {
        shot = false;
        velocity = new PVector(0,0);
        radius = (int) ground;
        ceiling = 3f * width / 5f;
    }

    @Override
        void update () {
            radius += velocity.mag();
        }

    @Override
        void applyGravity () {
            acceleration = new PVector(0, 0.3);
        }

    @Override
        float deflect (Body o) {
            float dx = o.location.x - location.x,
                  dy = o.location.y - location.y,
                  distance = sqrt(dx*dx + dy*dy),
                  min = (float) (o.radius + radius)/2,
                  spring = 0.1;

            if (distance < min) {
                float angle = atan2(dy, dx),
                      targetX = location.x + cos(angle) * min,
                      targetY = location.y + sin(angle) * min,
                      ax = (targetX - o.location.x) * spring,
                      ay = (targetY - o.location.y) * spring;
                o.velocity.x += ax;
                o.velocity.y += ay;
                return this.velocity.mag();
            }
            return 0f;
        }

    void shoot(float force) {
        if (shot)
            return;

        velocity = new PVector(0,
                (float) (-launchConstant * Math.log(30)));

        force = force > 150 ? 150 : force;
        ceiling *= (force / 150f);
        shot = true;
    }

}

class Body {

    int radius;
    PVector location, velocity, acceleration;
    float mass, charge;
    PImage img;

    Body (float mass, float charge) {
        this.radius = (int) (0.95 * ballScale);
        location = new PVector(random(width), random(height));
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        this.mass = mass;
        this.charge = charge;
        int i = (int) random(0, 6);
        this.img = balls[i];
    }

    Body (float mass, float charge, PVector location) {
        this.radius = (int) (0.95 * ballScale);
        this.mass = mass;
        this.charge = charge;
        this.location = location;
        velocity = new PVector(0,0);
        acceleration = new PVector(0,0);
        this.img = balls[(int) random(0,5)];
    }

    void render () {
        //ellipse(location.x, location.y, radius, radius);
        image(img, location.x - radius / 2, location.y - radius / 2);
    }

    void update () {
        this.applyFriction();
        //this.applyGravity();
        //this.applyCharge(center);

        if (location.x < 0 || location.x > width)
            velocity.x = -velocity.x;
        if (location.y < 0 || location.y > height)
            velocity.y = -velocity.y;

        velocity.add(acceleration);
        location.add(velocity);
        acceleration.mult(0.01);
    }

    float deflect (Body o) {
        float dx = o.location.x - location.x,
              dy = o.location.y - location.y,
              distance = sqrt(dx*dx + dy*dy),
              min = (float) (o.radius + radius)/2,
              spring = 0.01;
        if (distance < min) {
            float angle = atan2(dy, dx),
                  targetX = location.x + cos(angle) * min,
                  targetY = location.y + sin(angle) * min,
                  ax = (targetX - o.location.x) * spring,
                  ay = (targetY - o.location.y) * spring;
            velocity.x -= ax;
            velocity.y -= ay;
            o.velocity.x += ax;
            o.velocity.y += ay;
            //bounce.stop();
            //bounce.play();
            return this.velocity.mag();
        }
        return 0f;
    }

    float applyForceTo (Body o) {
        return this.deflect(o);
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
        float c = 0.045;
        float speed = velocity.mag();
        float dragMagnitude = c * speed * speed;
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
