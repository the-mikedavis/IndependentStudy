import processing.sound.*;

FFT fft;
AudioIn in;
int bands = 32;
float scale = 1000.0;
float total, average, thresh;
float smoothing = 0.001;

void setup() {
    System.out.println("Threshold testing...");
    size(640, 360);
    in = new AudioIn(this, 0);
    in.start();
    fft = new FFT(this, bands);
    fft.input(in);
    thresh = 0;
}

void draw() {
    background(204);
    fill(0, 0, 255);
    noStroke();
    
    fft.analyze();
    
    total = 0;
    for (int i = 0; i < bands; i++)
        total += fft.spectrum[i] * scale;
    average = total / bands;
    
    thresh += (average - thresh) * smoothing;

    if (frameCount % 60 == 0)
        System.out.println("Threshold: " + thresh);
    
    if (average - thresh > 20.0 * thresh)
        System.out.println("triggered");

    rect(0, height, width, -(thresh * 100));
}