import processing.sound.*;

// Declare the processing sound variables 
SoundFile sample;
FFT fft;
AudioDevice device;
AudioIn in;

// Declare a scaling factor
int scale = 10;

// Define how many FFT bands we want
int bands = 16;

// declare a drawing variable for calculating rect width
float r_width;

// Create a smoothing vector
float[] sum = new float[bands];

float total, average;

// Create a smoothing factor
float smooth_factor = 0.2;

void setup() {
    System.out.println("----------");
  size(640, 360);
  background(255);

  in = new AudioIn(this, 0);
  // Calculate the width of the rects depending on how many bands we have
  r_width = width/float(bands);

  in.start();
  // Create and patch the FFT analyzer
  fft = new FFT(this, bands);
  fft.input(in);
}      

void draw() {
  // Set background color, noStroke and fill color
  background(204);
  fill(0, 0, 255);
  noStroke();

  fft.analyze();
    total = 0;  
  for (int i = 0; i < bands; i++) {
      total += fft.spectrum[i];
    // Smooth the FFT data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    // Draw the rects with a scale factor
    rect( i*r_width, height, r_width, -sum[i]*height*scale );
  }
  total *= 1000.0;
  average = total / bands;

  //System.out.println("Total: " + total + ". Average: " + average);
    if (total > 10.0)
        System.out.println("triggered");
}