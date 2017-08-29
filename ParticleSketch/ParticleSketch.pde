import java.util.Iterator;
ParticleSystem ps;

void setup() {
    size(640,360);
    ps = new ParticleSystem(new PVector(width / 2, 30));
}

void draw() {
    background(255);
    ps.addParticle();
    ps.run();
}

class ParticleSystem {
    ArrayList<Particle> particles;
    PVector origin;

    ParticleSystem(PVector location) {
        origin = location.get();
        particles = new ArrayList<Particles>();
    }

    void addParticle() {
        particles.add(new Particle(origin));
    }

    void run() {
        Iterator<Particle> it = particles.iterator();
        while (it.hasNext()) {
            Particle p = it.next();
            p.run();
            if (p.isDead())
                it.remove();
        }
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
