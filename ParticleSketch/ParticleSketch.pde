import java.util.Iterator;
ArrayList<Particle> particles;

void setup() {
    size(640,360);
    particles = new ArrayList<Particle>();
}

void draw() {
    background(255);

    particles.add(new Particle(new PVector(width/2, 50)));
    
    Iterator<Particle> iter = particles.iterator();
    while(iter.hasNext()) {
        Particle p = iter.next();
        p.run();
        if (p.isDead())
            iter.remove();
    }
}

class Particle {
    PVector location;
    PVector velocity;
    PVector acceleration;
    float lifespan;
    color c;
    
    Particle(PVector l) {
        location = l.get();
        velocity = new PVector(random(-1, 1), random(-2, 0));
        acceleration = new PVector(0, 0.05);
        lifespan = 255;
        c = color(round(random(255)), round(random(255)), round(random(255)));
    }
    
    void update() {
        velocity.add(acceleration);
        location.add(velocity);
        lifespan -= 2.0;
    }
    
    void display() {
        stroke(0, lifespan);
        fill(c, lifespan);
        rect(location.x, location.y, 10, 10);
    }
    
    void run() {
        update();
        display();
    }
    
    boolean isDead() {
        return lifespan < 0.0;   
    }
}