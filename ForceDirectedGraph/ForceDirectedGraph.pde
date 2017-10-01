import java.util.ArrayList;

FDGraph system;

void setup () {
    size(540, 540);
    system = new FDGraph(50);    
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
        return system.add(new Body(50));
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
                    a.applyForce(b);
            a.applyGravity();
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

    int x, y, radius;
    PVector location, velocity, acceleration;

    Body (int radius) {
        this.radius = radius;
        this.x = (int) (Math.random() * width);
        this.y = (int) (Math.random() * height);
    }

    void render () {
        ellipse(x, y, radius, radius);
    }

    void applyForce (Body o) {
        this.applyCharge(o);
        this.applySpring(o);
    }

    void applyCharge (Body o) {
        double charge = 0.01;
    }

    void applySpring (Body o) {
        double spring = 0.02;
    }

    //  Suck into the center of the pane
    void applyGravity () {
        double gravity = 0.03;
        int x = width / 2,
            y = height / 2;
    }

}
