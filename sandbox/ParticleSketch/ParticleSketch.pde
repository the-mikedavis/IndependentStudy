import java.util.Iterator;
ConfettiSystem ps;

void setup() {
    size(640,360,P3D);
    ps = new ConfettiSystem(new PVector(width / 2, height/4));
}

void draw() {
    background(255);
    ps.addConfetto();
    ps.run();
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
        lifespan = 355;
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
        if (location.y > 3*height/4)
            velocity.mult(0.1);
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