Ball ball;

void setup() {
    size(540,960);
    ball = new Ball(new PVector(width/2, 7*height/8));
}

void draw() {
    background(255);
    ball.run();
}

void keyPressed() {
    ball.shoot(new PVector(0, -18));
}

class Ball {

    PVector location, velocity, acceleration;
    
    Ball (PVector location) {
        this.location = location;
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
    }
    
    void run () {
        update();
        stroke(0);
        fill(175);
        ellipse(location.x, location.y, 8, 8);
        if (location.y > 7*height/8)
            ball.reset();
    }
    
    void reset() {
        location = new PVector(width/2, 7*height/8);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0,0);
    }
    
    void update() {
        velocity.add(acceleration);
        location.add(velocity);
    }
    
    void applyGravity(PVector gravity) {
        acceleration = gravity;   
    }
    
    void shoot(PVector upshot) {
        velocity = upshot;
        applyGravity(new PVector(0, 0.3));
    }
}