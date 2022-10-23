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

PImage wood;

ArrayList<Rope> ropes;
ArrayList<Sphere> spheres;
Cloth cloth; 

boolean cameraControl = true;

void setup() {
    size(1024, 782, P3D);
    surface.setTitle(title);
    camera = new Camera();

    ropes = new ArrayList<Rope>();
    spheres = new ArrayList<Sphere>();
    spheres.add(new Sphere(new PVector(350, 200, 50), 100.0));
    spheres.add(new Sphere(new PVector(350, 400, 210), 100.0));

    PImage clothTex = loadImage("images/awesomeface.jpg");
    wood = loadImage("images/wood.jpg");

    cloth = new Cloth(new PVector(250, 50), 12.0, 1000.0, 75.0, 
            35, 35, clothTex);
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
    background(150, 230, 255);
    float ambientColor = 165;
    ambientLight(ambientColor, ambientColor, ambientColor);
    directionalLight(255, 255, 255, 0, 1, 0);

    for(int i = 0; i < ropes.size(); i++) {
        ropes.get(i).draw();
    }

    for(int i = 0; i < spheres.size(); i++) {
        spheres.get(i).draw();
    }
    fill(255, 255, 255);

    cloth.draw();

    textureMode(NORMAL);
    beginShape();
    texture(wood);
    vertex(-500, 800, -500, 0, 0);
    vertex(2000, 800, -500, 1, 0);
    vertex(2000, 800, 2000, 1, 1);
    vertex(-500, 800, 2000, 0, 1);
    endShape(CLOSE);

    drawWalls(wood);

    camera.Update(1.0/frameRate);

    //textSize(64);
    //text("Control Mode: ", 40, 120);

    float x = mouseX;
    float y = mouseY;
    float z = -100;
    
    // Draw "X" at z = -100
    stroke(255);
    line(x-10, y-10, z, x+10, y+10, z); 
    line(x+10, y-10, z, x-10, y+10, z); 
    
    // Draw gray line at z = 0 and same 
    // y value. Notice the parallax
    stroke(102);
    line(0, y, 0, width, y, 0);
    
    // Draw black line at z = 0 to match 
    // the y value element drawn at z = -100 
    stroke(0);
    float theY = screenY(x, y, z);
    line(0, theY, 0, width, theY, 0);

    if(!paused) {
        for(int i = 0; i < 40; i++) {
            update(1.0/(40.0*frameRate));
        }
        surface.setTitle(title + " " + nf(frameRate,0,2) + "FPS");
    } else {
        surface.setTitle(title + " [PAUSED]");
    }
}

void drawWalls(PImage wallTex) {
    float wallHeight = -500;

    beginShape();
    texture(wallTex);
    vertex(-500, wallHeight, -500, 0, 0);
    vertex(-500, wallHeight, 2000, 1, 0);
    vertex(-500, 800, 2000, 1, 1);
    vertex(-500, 800, -500, 0, 1);
    endShape(CLOSE);

    beginShape();
    texture(wallTex);
    vertex(-500, wallHeight, 2000, 0, 0);
    vertex(2000, wallHeight, 2000, 1, 0);
    vertex(2000, 800, 2000, 1, 1);
    vertex(-500, 800, 2000, 0, 1);
    endShape(CLOSE);

    beginShape();
    texture(wallTex);
    vertex(2000, wallHeight, 2000, 0, 0);
    vertex(2000, wallHeight, -500, 1, 0);
    vertex(2000, 800, -500, 1, 1);
    vertex(2000, 800, 2000, 0, 1);
    endShape(CLOSE);

    beginShape();
    texture(wallTex);
    vertex(2000, wallHeight, -500, 0, 0);
    vertex(-500, wallHeight, -500, 1, 0);
    vertex(-500, 800, -500, 1, 1);
    vertex(2000, 800, -500, 0, 1);
    endShape(CLOSE);
}

void keyPressed() {
    if(cameraControl)
        camera.HandleKeyPressed();

    if (key == ' ') {
        paused = !paused;
    } else if(key == 't') {
        cloth.reset();
    } else if(key == 'g') {
        cloth.setGrab(new PVector(10, 10), 5);
    }
}

void keyReleased() {
    if(cameraControl)
        camera.HandleKeyReleased();

    if(key == 'g') { // release grab
        cloth.clearGrab();
    }
}
