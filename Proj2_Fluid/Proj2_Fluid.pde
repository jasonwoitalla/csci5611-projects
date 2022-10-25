// CSCI 5611 - Project 2 SWE Fluid Simulation
// Author: Jason Woitalla

String title = "Project 2 SWE Fluid Simulation - Jason Woitalla";
boolean paused = true;
Camera camera;

// Physical Settings
float gravity = 2.0;

// Fluid Settings
int n = 15;
float sim_width = 550.0;
float sim_height = 550.0;
float dx = sim_width / n;
float dy = sim_height / n;
float damp = 0.9;
float left = 0;

float[][] h = new float[n][n]; // Height
float[][] dhdt = new float[n][n]; // Height derivative

float[][] hu = new float[n][n]; // Momentum in the x direction
float[][] dhudt = new float[n][n]; // Momentum derivative in terms of x

float[][] hv = new float[n][n]; // Momentum in the y direction
float[][] dhvdt = new float[n][n]; // Momentum derivative in terms of y

float my_scale = 15.0;

void setup() {
    size(1024, 782, P3D);
    surface.setTitle(title);
    camera = new Camera();
    reset();
}

void reset() {
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            h[i][j] = (2.0*float(i)/n) + (2.0*float(j)/n) + 1;
            hu[i][j] = 0;
            hv[i][j] = 0;
        }
    }
}

void update(float dt) {
    // Midpoint + Midpoint derivative arrays
    float[][] hx_mid = new float[n][n]; // Height x midpoint
    float[][] hy_mid = new float[n][n]; // Height y midpoint
    float[][] hu_mid = new float[n][n]; // Momentum midpoint in terms of x
    float[][] hv_mid = new float[n][n]; // Momentum midpoint in terms of y

    float[][] dhxdt_mid = new float[n][n]; // Height midpoint derivative
    float[][] dhydt_mid = new float[n][n]; // Height midpoint derivative
    float[][] dhudt_mid = new float[n][n]; // Momentum midpoint derivative in terms of x
    float[][] dhvdt_mid = new float[n][n]; // Momentum midpoint derivative in terms of y

    // Compute midpoints
    for(int i = 0; i < n-1; i++) {
        for(int j = 0; j < n-1; j++) {
            hx_mid[i][j] = ((h[i][j+1] + h[i][j]) / 2.0);
            hy_mid[i][j] = ((h[i+1][j] + h[i][j]) / 2.0);
            hu_mid[i][j] = (hu[i][j+1] + hu[i][j]) / 2.0; // momentum in the x direction
            hv_mid[i][j] = (hv[i+1][j] + hv[i][j]) / 2.0; // momentum in the y direction
        }
    }

    for(int i = 0; i < n-1; i++) {
        for(int j = 0; j < n-1; j++) {
            // Update dh/dt midpoint
            float dhudx_mid = (hu[i][j+1] - hu[i][j]) / dx;
            float dhvdy_mid = (hv[i+1][j] - hv[i][j]) / dy;
            dhxdt_mid[i][j] = -(dhudx_mid);
            dhydt_mid[i][j] = -(dhvdy_mid);

            // Update midpoints in terms of x
            float dhu2dx_mid = ((sq(hu[i][j+1]) / h[i][j+1]) - (sq(hu[i][j]) / h[i][j])) / dx;
            float dgh2dx_mid = gravity * (sq(h[i][j+1]) - sq(h[i][j])) / dx;
            float dhuvdy_mid = ((hu[i+1][j] * hv[i+1][j] / h[i+1][j]) - (hu[i][j] * hv[i][j] / h[i][j])) / dy;
            dhudt_mid[i][j] = -(dhu2dx_mid + 0.5*dgh2dx_mid + dhuvdy_mid);

            // Update midpoints in terms of y
            float dhv2dy_mid = ((sq(hv[i+1][j]) / h[i+1][j]) - (sq(hv[i][j]) / h[i][j])) / dy;
            float dgh2dy_mid = gravity * (sq(h[i+1][j]) - sq(h[i][j])) / dy;
            float dhuvdx_mid = ((hu[i][j+1] * hv[i][j+1] / h[i][j+1]) - (hu[i][j] * hv[i][j] / h[i][j])) / dx;
            dhvdt_mid[i][j] = -(dhv2dy_mid + 0.5*dgh2dy_mid + dhuvdx_mid);
        }
    }

    // Integrate midpoints
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            hx_mid[i][j] += dhxdt_mid[i][j] * dt / 2.0;
            hy_mid[i][j] += dhydt_mid[i][j] * dt / 2.0;
            hu_mid[i][j] += dhudt_mid[i][j] * dt / 2.0;
            hv_mid[i][j] += dhvdt_mid[i][j] * dt / 2.0;
        }
    }

    // Update values
    for(int i = 1; i < n - 1; i++) {
        for(int j = 1; j < n -1; j++) {
            float dhudx = (hu_mid[i][j] - hu_mid[i][j-1]) / dx;
            float dhvdy = (hv_mid[i][j] - hv_mid[i-1][j]) / dy;
            dhdt[i][j] = -(dhudx + dhvdy);

            float dhu2dx = (sq(hu_mid[i][j])/hx_mid[i][j] - sq(hu_mid[i][j-1])/hx_mid[i][j-1]) / dx;
            float dgh2dx = gravity * (sq(hx_mid[i][j]) - sq(hx_mid[i][j-1])) / dx;
            float dhuvdy = ((hu_mid[i][j] * hv_mid[i][j] / hy_mid[i][j]) - (hu_mid[i-1][j] * hv_mid[i-1][j] / hy_mid[i-1][j])) / dy;
            dhudt[i][j] = -(dhu2dx + 0.5*dgh2dx + dhuvdy);

            float dhv2dy = (sq(hv_mid[i][j])/hy_mid[i][j] - sq(hv_mid[i-1][j])/hy_mid[i-1][j]) / dy;
            float dgh2dy = gravity * (sq(hy_mid[i][j]) - sq(hy_mid[i-1][j])) / dy;
            float dhuvdx = ((hu_mid[i][j] * hv_mid[i][j] / hx_mid[i][j]) - (hu_mid[i][j-1] * hv_mid[i][j-1] / hx_mid[i][j-1])) / dx;
            dhvdt[i][j] = -(dhv2dy + 0.5*dgh2dy + dhuvdx);
        }
    }


    // Integrate values
    for(int i = 1; i < n-1; i++) {
        for(int j = 1; j < n-1; j++) {
            h[i][j] += damp * dhdt[i][j] * dt;
            hu[i][j] += damp * dhudt[i][j] * dt;
            hv[i][j] += damp * dhvdt[i][j] * dt;
        }
    }

    // Boundary Condition
    for(int j = 0; j < n; j++) {
        h[0][j] = h[1][j];
        h[n-1][j] = h[n-2][j];

        hu[0][j] = hu[0][j];
        hu[n-1][j] = hu[n-2][j];

        hv[0][j] = -hv[0][j];
        hv[n-1][j] = -hv[n-2][j];
    }

    for(int i = 0; i < n; i++) {
        h[i][0] = h[i][1];
        h[i][n-1] = h[i][n-2];

        hu[i][0] = -hu[i][1];
        hu[i][n-1] = -hu[i][n-2];

        hv[i][0] = hv[i][1];
        hv[i][n-1] = hv[i][n-2];
    }

}

boolean printed = false;

void draw() {
    background(255, 255, 255);
    camera.Update(1.0/frameRate);
    //fill(0, 0, 0);
    fill(140, 200, 255, 200);
    lights();

    translate(200, 100, 200);
    noStroke();
    float spacing = dx;
    for(int j = 0; j < n-1; j++) {
        beginShape(QUAD_STRIP);
        for(int i = 0; i < n; i++) {
            vertex(spacing * i, h[i][j]*my_scale, spacing * j);
            vertex(spacing * i, h[i][j+1]*my_scale, spacing * (j+1));
        }
        endShape();
    }

    stroke(128, 128, 200);
    beginShape(QUAD_STRIP);
    for(int i = 0; i < n; i++) {
        vertex(0, h[1][i]*my_scale, spacing * i);
        vertex(0, 200, spacing * i);
    }
    endShape();

    beginShape(QUAD_STRIP);
    for(int i = 0; i < n; i++) {
        vertex(spacing*(n-1), h[n-2][i]*my_scale, spacing * i);
        vertex(spacing*(n-1), 200, spacing * i);
    }
    endShape();

    beginShape(QUAD_STRIP);
    for(int i = 0; i < n; i++) {
        vertex(spacing*i, h[i][1]*my_scale, 0);
        vertex(spacing*i, 200, 0);
    }
    endShape();

    beginShape(QUAD_STRIP);
    for(int i = 0; i < n; i++) {
        vertex(spacing*i, h[i][n-2]*my_scale, spacing*(n-1));
        vertex(spacing*i, 200, spacing*(n-1));
    }
    endShape();

    if(!printed) {
        printed = true;
    }

    if(!paused) {
        float dt = 0.001;
        //float sim_dt = 0.000001;
        for(int i = 0; i < 500; i++) {
            update(dt);
        }

        surface.setTitle(title + " " + nf(frameRate, 0, 2) + "FPS");
    } else {
        surface.setTitle(title + " [PAUSED]");
    }
}

void keyPressed() {
    camera.HandleKeyPressed();

    if(key == ' ') {
        paused = !paused;
    } else if(key == 't') {
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                //h[i][j] = sin(3 * PI * i / n) + 1;
                h[i][j] = (2.0*float(i)/n) + (2.0*float(j)/n) + 1;
                hu[i][j] = 0;
                hv[i][j] = 0;
            }
        }
    } else if(key == 'y') {
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                // h[i][j] = sin(6 * PI * j / n) + 2;
                h[i][j] = (2.0*float(i)/n) + 1;
                println("Height: " + h[i][j]);
                hu[i][j] = 0;
                hv[i][j] = 0;
            }
        }
    } else if(key == 'u') {
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                h[i][j] = (sin(4 * PI * i / n) + sin(4 * PI * j / n) + 2) / 2;
                println("Height: " + h[i][j]);
                hu[i][j] = 0;
                hv[i][j] = 0;
            }
        }
    }
}

void keyReleased() {
    camera.HandleKeyReleased();
}