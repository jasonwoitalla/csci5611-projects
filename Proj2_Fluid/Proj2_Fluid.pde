// CSCI 5611 - Project 2 SWE Fluid Simulation
// Author: Jason Woitalla

String title = "Project 2 SWE Fluid Simulation - Jason Woitalla";
boolean paused = true;

// Physical Settings
float gravity = 10.0;

// Fluid Settings
int n = 40;
float width = 500.0;
float dx = width / n;
float damp = 0.9;
float left = 0;
float[] h = new float[n];
float[] hu = new float[n];

// Mid points
float dhdt[] = new float[n];
float dhudt[] = new float[n];

void setup() {
    size(1024, 782, P3D);
    surface.setTitle(title);

    for(int i = 0; i < n; i++) {
        h[i] = dx * i / n + 1.0;
        hu[i] = 0;
    }
}

void update(float dt) {
    // Midpoint + Midpoint derivative arrays
    float[] h_mid = new float[n];
    float[] hu_mid = new float[n];
    float[] dhdt_mid = new float[n];
    float[] dhudt_mid = new float[n];

    for(int i = 0; i < n-1; i++) {
        h_mid[i] = (h[i+1] + h[i]) / 2.0;
        hu_mid[i] = (hu[i+1] + hu[i]) / 2.0;
    }

    // Update midpoints
    for(int i = 0; i < n-1; i++) {
        float dhudx_mid = (hu[i+1] - hu[i]) / dx;
        dhdt_mid[i] = -dhudx_mid;

        float dhu2dx_mid = ((sq(hu[i+1]) / h[i+1]) - (sq(hu[i]) / h[i])) / dx;
        float dgh2dx_mid = (gravity * sq(h[i+1]) - sq(h[i])) / dx;
        dhudt_mid[i] = -(dhu2dx_mid + 0.5*dgh2dx_mid);
    }

    // Integrate midpoints
    for(int i = 0; i < n; i++) {
        h_mid[i] += dhdt_mid[i] * dt / 2.0;
        hu_mid[i] += dhudt_mid[i] * dt / 2.0;
    }

    // Update values
    for(int i = 1; i < n - 1; i++) {
        float dhudx = (hu_mid[i] - hu_mid[i-1]) / dx;
        dhdt[i] = -dhudx;

        float dhu2dx = (sq(hu_mid[i])/h_mid[i] - sq(hu_mid[i-1])/h_mid[i-1]) / dx;
        float dgh2dx = gravity * (sq(h_mid[i]) - sq(h_mid[i-1])) / dx;
        dhudt[i] = -(dhu2dx + 0.5*dgh2dx);
    }

    // Integrate values
    for(int i = 0; i < n - 1; i++) {
        h[i] += damp * dhdt[i] * dt;
        hu[i] += damp * dhudt[i] * dt;
    }

    // Reflect
    h[0] = h[1];
    h[n-1] = h[n-2];
    hu[0] = hu[1];
    hu[n-1] = hu[n-2];
}

boolean printed = false;

void draw() {
    background(255, 255, 255);
    fill(0, 0, 0);
    translate(0, 200);
    fill(25, 25, 200);
    float w = 100;
    for(int i = 0; i < n-1; i++) {
        //float x1 = dx * i / (cells-1) * scale;
        //float x2 = dx * (i+1) / (cells-1) * scale;
        //float y1 = (heights[i]) * scale;
        //float y2 = (heights[i+1]) * scale;
        //if(!printed) {
            //println("x1: " + x1 + " x2: " + x2 + " y1: " + y1 + " y2: " + y2);
        //}
        //quad(x1, y1, x2, y2, x2, -1, x1, -1);
        //float x = 
        //rect(x1, y1, dx*scale, 0);
        float x1 = left + (i * dx);
        float x2 = left + ((i+1) * dx);
        PVector v1 = new PVector(x2 - x1, h[i+1]-h[i], 0);
        PVector v2 = new PVector(0, 0, -1);
        PVector normalVec = v1.cross(v2);
        beginShape(QUADS);
        normal(normalVec.x, normalVec.y, normalVec.z);
        vertex(x1, h[i], 0);
        vertex(x2, h[i+1], 0);
        vertex(x2, h[i+1], -w);
        vertex(x1, h[i], -w);
        endShape();
    }

    if(!printed) {
        printed = true;
    }

    if(!paused) {
        for(int i = 0; i < 500; i++) {
            update(1.0/(500.0*frameRate));
        }

        surface.setTitle(title + " " + nf(frameRate, 0, 2) + "FPS");
    } else {
        surface.setTitle(title + " [PAUSED]");
    }
}

void keyPressed() {
    if(key == ' ') {
        paused = !paused;
    }
}