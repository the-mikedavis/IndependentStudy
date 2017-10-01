import java.util.ArrayList;

FDGraph system;
Body center;

void setup () {
    size(540, 540);
    system = new FDGraph(1);   
    center = new Body(10f, 15f, new PVector(width / 2, height / 2));
}

void draw () {
    background(255);
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

    void applyForceTo (Body o) {
        this.applyCharge(o);
        this.applySpring(o);
    }

    //  Repelling force
    void applyCharge (Body o) {
        float C = 1f;
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
        float m = - (G * this.mass * center.mass) / (dist);
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
