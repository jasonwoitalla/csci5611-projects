// CSCI 5611 - Project 2 SWE Fluid Simulation
// Author: Jason Woitalla

String title = "Project 2 SWE Fluid Simulation - Jason Woitalla";
boolean paused = true;

// Physical Settings
float gravity = 1.0;

// Fluid Settings
int n = 40;
float width = 60.0;
float dx = width / n;
float damp = 0.9;
float left = 0;
float[][] h = new float[n][n];
float[][] hux = new float[n][n];
float[][] huy = new float[n][n];
float dhdt[][] = new float[n][n];
float dhudt[][] = new float[n][n];

float scale = 10.0;

void setup() {
    size(1024, 782, P3D);
    surface.setTitle(title);
}

void reset() {
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            h[i][j] = 2*sin(6 * i / n) + 2;
            hux[i][j] = 0;
            huy[i][j] = 0;
        }
    }
}

void update(float dt) {
    // Midpoint + Midpoint derivative arrays

    //float[][] h_mid = new float[n][n];
    //float[][] hu_mid = new float[n][n];
    //float[][] dhdt_mid = new float[n][n];
    //float[][] dhudt_mid = new float[n][n];

    // Compute midpoints
    for(int i = 0; i < n-1; i++) {
        for(int j = 0; j < n-1; j++) {
            h_mid[i][j] = (h[i+1][j+1] + h[i][j]) / 2.0;
            hu_mid[i][j] = (hu[i+1][j+1] + hu[i][j]) / 2.0;
        }
    }

    /*// Update midpoints
    for(int i = 0; i < n-1; i++) {
        float dhudx_mid = (hu[i+1] - hu[i]) / dx;
        dhdt_mid[i] = -dhudx_mid;

        float dhu2dx_mid = ((sq(hu[i+1]) / h[i+1]) - (sq(hu[i]) / h[i])) / dx;
        float dgh2dx_mid = gravity * (sq(h[i+1]) - sq(h[i])) / dx;
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
    }*/

    // Reflect
    //h[0] = h[1];
    //h[n-1] = h[n-2];
    //hu[0] = hu[1];
    //hu[n-1] = hu[n-2];
}

void updateDX(float[][] h_mid, float[][] hu_mid, float[][] dhdt_mid, float[][] dhudt_mid) {
    
}

void updateDY(float[][] h_mid, float[][] hu_mid, float[][] dhdt_mid, float[][] dhudt_mid) {

}

void updateH() {
    for(int i = 1; i < n-1; i++) {
        for(int j = 1; j < n-1; j++) {

        }
    }
}

boolean printed = false;

void draw() {
    background(255, 255, 255);
    fill(0, 0, 0);
    translate(200, 200);
    fill(25, 25, 200);
    float w = 5*scale;
    for(int i = 0; i < n-1; i++) {
        float x1 = (left + (i * dx)) * scale;
        float x2 = (left + ((i+1) * dx)) * scale;
        PVector v1 = new PVector(x2 - x1, h[i+1]-h[i], 0);
        PVector v2 = new PVector(0, 0, -1);
        PVector normalVec = v1.cross(v2);
        beginShape(QUADS);
        normal(normalVec.x, normalVec.y, normalVec.z);
        vertex(x1, h[i]*scale, 0);
        vertex(x2, h[i+1]*scale, 0);
        vertex(x2, h[i+1]*scale, -w);
        vertex(x1, h[i]*scale, -w);
        endShape();
    }

    if(!printed) {
        printed = true;
    }

    if(!paused) {
        float dt = 0.01;
        float sim_dt = 0.001;
        for(int i = 0; i < int(dt/sim_dt); i++) {
            update(dt);
        }

        surface.setTitle(title + " " + nf(frameRate, 0, 2) + "FPS");
    } else {
        surface.setTitle(title + " [PAUSED]");
    }
}

void keyPressed() {
    if(key == ' ') {
        paused = !paused;
    } else if(key == 't') {
        reset();
    }
}