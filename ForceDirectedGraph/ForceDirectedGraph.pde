import java.util.ArrayList;

FDGraph system;
Body center;

void setup () {
    size(540, 540);
    system = new FDGraph(50);   
    center = new Body(10f, -10f);
}

void draw () {
    //background(255);
    system.run();
}

class FDGraph {
    
    ArrayList<Body> system;

    FDGraph (int count) {
        system = new ArrayList<Body>(count);
        for (int i = 0; i < count; i++)
            add();
    }

    boolean add () {
        return system.add(new Body(2f, 2f));
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
                    a.applyForceTo(b);
            a.update();
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

    void render () {
        ellipse(location.x, location.y, radius, radius);
    }

    void update () {
        this.applyGravity();
        velocity.add(acceleration);
        location.add(velocity);
        acceleration.mult(0);
    }

    void applyForceTo (Body o) {
        this.applyCharge(o);
        this.applySpring(o);
    }

    //  Repelling force
    void applyCharge (Body o) {
        
    }

    void applySpring (Body o) {
        double spring = 0.02;
    }

    //  Suck into the center of the pane
    void applyGravity () {
        float G = 100f;
        PVector center = new PVector(width / 2, height / 2);
        PVector force = PVector.sub(this.location, center);
        float dist = force.mag();
        float m = - (G * this.mass * this.mass) / (dist * dist);
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