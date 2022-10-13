//CSCI 5611 - Stephen J. Guy <sjguy@umn.edu>
//Unit: PDEs and Integration
//Triple Spring (damped) [Lecture Starter Code]

//Follow along with the lecture:
//  -Add a second ball, second string, and render it

/*void setup() {
  size(400, 500, P3D);
  surface.setTitle("Balls on springs (3-link Chain)");
}*/

float floor = 500;
float gravity = 10;
float radius = 10;
float stringTop = 50;
float restLen = 40;
float mass = 30; //How does changing mass affect resting length?
float k = 20; //How does changing k affect resting length?
float kv = 10;

float ballY1 = 200;
float velY1 = 0;
float ballY2 = 250;
float velY2 = 0;
float ballY3 = 300;
float velY3 = 0;

void update(float dt){
  float stringF1 = -k*((ballY1 - stringTop) - restLen);
  float dampF1 = -kv*(velY1 - 0);
  float forceY1 = stringF1 + dampF1;
 
  float accY1 = gravity + forceY1/mass; 
  velY1 += accY1*dt;
  ballY1 += velY1*dt;
  
  if (ballY1+radius > floor){
    velY1 *= -.9;
    ballY1 = floor - radius;
  }
  
  println("l1:",ballY1 - stringTop, " l2:",ballY2 - ballY1, " l3:",ballY3-ballY2);
}


void draw() {
  background(255,255,255);
  update(.1); //TODO: A fixed update doesn't port well to different machines
  fill(0,0,0);
  
  line(200,stringTop,200,ballY1);
  translate(200,ballY1);
  sphere(radius);
}
