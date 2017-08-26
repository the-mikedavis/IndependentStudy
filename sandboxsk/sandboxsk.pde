void setup() {
    size(400, 400);
}

void draw() {
    fill(mousePressed ? 0 : 255);
    ellipse(mouseX, mouseY, 80, 80);
}