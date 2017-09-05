import processing.sound.*;

FFT fft;
AudioIn in;
Spline threshSpline, totalSpline, triggerSpline, baseLine;
int bands = 32;
float scale = 2000.0, smoothing = 0.001;
float total, average, thresh;

void setup() {
    size(640,360);
    in = new AudioIn(this, 0);
    in.start();
    fft = new FFT(this, bands);
    fft.input(in);
    thresh = 0.0;
    int splineCount = 100;
    baseLine = new Spline(splineCount, color(0));
    threshSpline = new Spline(splineCount, color(0, 0, 255));
    totalSpline = new Spline(splineCount, color(255, 0, 0));
    triggerSpline = new Spline(splineCount, color(0, 255, 0));
}

void draw() {
    background(255);
    fft.analyze();
    total = 0;
    for (int i = 0; i < bands; i++)
        total += fft.spectrum[i] * scale;
    average = total / bands;
    thresh += (average - thresh) * smoothing;
    
    int tot = 3 * height / 4 - (int) average,
        thr = 3 * height / 4 - (int) thresh,
        tri = 3 * height / 4 - (int) (15.0 * thresh);
        
    baseLine.addPoint(3 * height / 4);
    totalSpline.addPoint(tot);
    threshSpline.addPoint(thr);
    triggerSpline.addPoint(tri);

    baseLine.render();
    totalSpline.render();
    threshSpline.render();
    triggerSpline.render();
}

class Spline {    //combination of path generator & linked list (queue style)
    
    Node root, tail;
    int count = 0, limit;
    color col;
    
    Spline(int limit, color c) {
        this.limit = limit;
        this.col = c;
    }
    
    void addPoint(int c) {
        Node e = new Node(c, null);
        if (root == null)
            root = tail = e;
        else
            tail = tail.next = e;
        
        if (count == this.limit)
            root = root.next;
        else
            count++;
    }
    
    void render() {
        noFill();
        stroke(this.col);
        beginShape();
        int i = 0;
        for (Node e = root; e != null; e = e.next) {
            int x = i * width / this.limit;
            if (e.equals(root) || e.next == null) //draw the first and last point twice.
                e.draw(x);
            e.draw(x);
            i++;
        }
        endShape();
    }
    
    class Node {
        
        int c;
        Node next;
        
        Node(int magnitude, Node next) {
            this.c = magnitude;
            this.next = next;
        }
        
        void draw (int x) {
            curveVertex(x, this.c);
        }
        
        boolean equals(Node that) {
            if (this.next == null && that.next == null)
                return this.c == that.c;
            return this.c == that.c &&
                (this.next != null && that.next != null) &&
                (this.next.equals(that.next));
        }
    }
}