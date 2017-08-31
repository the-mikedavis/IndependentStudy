import processing.sound.*;

FFT fft;
AudioIn in;
int bands = 32;
float scale = 1000.0, smoothing = 0.001;
float total, average, thresh;

Ball ball;

void setup() {
    size(540,960);
    in = new AudioIn(this, 0);
    in.start();
    fft = new FFT(this, bands);
    fft.input(in);
    thresh = 0.0;
    
    ball = new Ball(new PVector(width/2, 7*height/8));
}

void draw() {
    background(255);
    ball.run();
    
    fft.analyze();
    
    total = 0;
    for (int i = 0; i < bands; i++)
        total += fft.spectrum[i] * scale;
    average = total / bands;
    
    thresh += (average - thresh) * smoothing;
    
    if (average - thresh > 20.0 * thresh)
        ball.shoot();
}
//the point is to replace keyPressed with a clap
void keyPressed() {
    ball.shoot();
}

class Ball {

    PVector location, velocity, acceleration;
    boolean shot = false;
    
    Ball (PVector location) {
        this.location = location;
        velocity = new PVector(0, 0);    
        acceleration = new PVector(0, 0);
    }
    
    void run () {
        update();
        stroke(0);
        fill(175);
        ellipse(location.x, location.y, 20, 20);
        if (location.y > 7*height/8)
            ball.reset();
    }
    
    void reset() {
        shot = false;
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
    
    void shoot() {
        if (shot)
            return;
        velocity = new PVector(0, -18);
        applyGravity(new PVector(0, 0.3));
        shot = true;
    }
}