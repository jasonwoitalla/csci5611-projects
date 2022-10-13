// CSCI 5611 - Project 2 PDE Simulation
// Author: Jason Woitalla

String title = "Project 2 PDE Simulation - Jason Woitalla";
boolean paused = true;
Camera camera;

// Parameters
static PVector gravity = new PVector(0, 75, 0);
float airDensity = 0.01;
static int maxNodes = 100;
float floor = 500;

ArrayList<Rope> ropes;
ArrayList<Sphere> spheres;
Cloth cloth; 

void setup() {
    size(1024, 782, P3D);
    surface.setTitle(title);
    camera = new Camera();

    ropes = new ArrayList<Rope>();
    spheres = new ArrayList<Sphere>();
    spheres.add(new Sphere(new PVector(350, 200, 50), 100.0));
    spheres.add(new Sphere(new PVector(350, 400, 210), 100.0));

    PImage clothTex = loadImage("images/awesomeface.jpg");
    cloth = new Cloth(new PVector(250, 50), 12.0, 1000.0, 75.0, 
            20, 20, clothTex);
}

void update(float dt) {
    for(int i = 0; i < ropes.size(); i++) {
        ropes.get(i).update(dt);
    }

    cloth.update(dt, spheres);
}

// Pass in the vectors by reference and integrate them using
// the integration technique. 
void integrate(PVector pos, PVector vel, PVector acc, float dt) {
    vel.add(PVector.mult(acc, dt));
    pos.add(PVector.mult(vel, dt));
}

void draw() {
    background(255,255,255);
    fill(0, 0, 0);

    for(int i = 0; i < ropes.size(); i++) {
        ropes.get(i).draw();
    }

    for(int i = 0; i < spheres.size(); i++) {
        spheres.get(i).draw();
    }

    cloth.draw();

    fill(200, 200, 50);
    beginShape();
    vertex(-500, 800, -500);
    vertex(2000, 800, -500);
    vertex(2000, 800, 2000);
    vertex(-500, 800, 2000);
    endShape(CLOSE);

    camera.Update(1.0/frameRate);

    if(!paused) {
        for(int i = 0; i < 10; i++) {
            update(1.0/(5.0*frameRate));
        }
        surface.setTitle(title + " " + nf(frameRate,0,2) + "FPS");
    } else {
        surface.setTitle(title + " [PAUSED]");
    }
}

void keyPressed() {
    camera.HandleKeyPressed();

    if (key == ' ') {
        paused = !paused;
    } else if(key == 't') {
        cloth.reset();
    }
}

void keyReleased() {
    camera.HandleKeyReleased();
}
