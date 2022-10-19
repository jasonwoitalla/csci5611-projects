public class Cloth {

    Particle particles[][] = new Particle[maxNodes][maxNodes];
    ArrayList<Spring> springs = new ArrayList<Spring>();

    PVector stringTop;
    PImage texture;
    int numX = 10;
    int numY = 10;
    float restLen = 10;
    float ks = 200;
    float kd = 30;
    float dragCoeff = 0.02;

    boolean dragOn = true;
    float floor = 795;

    public Cloth(PVector stringTop, float restLen, float ks, float kd, int numX, int numY, PImage texture) {
        this.stringTop = stringTop;
        this.restLen = restLen;
        this.ks = ks;
        this.kd = kd;
        this.numX = numX;
        this.numY = numY;
        this.texture = texture;

        reset();
    }

    public Cloth(PVector top, int numX, int numY, PImage texture) {
        this(top, 25.0, 150.0, 20.0, numX, numY, texture);
    }

    public void reset() {
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                particles[i][j] = new Particle(new PVector(stringTop.x + restLen * i, stringTop.y, stringTop.z + restLen * j));
            }
        }

        //for(int i = 0; i < numX; i++) {
            //particles[i][0].setPos(stringTop.x + restLen * i, stringTop.y, 
                        //stringTop.z + restLen * i);
        //}

        // Add Springs
        for(int i = 0; i < numX-1; i++) {
            for(int j = 0; j < numY-1; j++) {
                springs.add(new Spring(ks, kd, restLen, particles[i][j], particles[i+1][j]));
                springs.add(new Spring(ks, kd, restLen, particles[i][j], particles[i][j+1]));
            }
        }

        for(int i = 0; i < numX - 1; i++) {
            springs.add(new Spring(ks, kd, restLen, particles[i][numY-1], particles[i+1][numY-1]));
        }

        for(int j = 0; j < numY - 1; j++) {
            springs.add(new Spring(ks, kd, restLen, particles[numX-1][j], particles[numX-1][j+1]));
        }

        // 2nd order springs
        float newKs = 1700.0;
        float newKd = 100.0;
        float newRest = sqrt(2) * (restLen * 2);

        for(int i = 0; i < numX - 2; i+=2) {
            for(int j = 0; j < numY - 2; j+=2) {
                springs.add(new Spring(newKs, newKd, newRest, particles[i][j], particles[i+2][j+2]));
            }
        }

        for(int i = numX - 2; i > 1; i-=2) {
            for(int j = numY - 2; j > 1; j-=2) {
                springs.add(new Spring(newKs, newKd, newRest, particles[i][j], particles[i-2][j-2]));
            }
        }
    }

    void update(float dt, ArrayList<Sphere> spheres) {

        //eulerianIntegration(dt);
        //verletIntegration(dt);

        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                particles[i][j].applyGravity();
            }
        }

        for(Spring s : springs) {
            s.applyForce();
        }

        // Fix Top Row
        //for(int i = 0; i < numX; i++) {
            //particles[i][0].newAcc = new PVector(0, 0, 0);
        //}

        // Drag force of the left triangle
        /*for(int i = 0; i < numX - 1; i++) {
            for(int j = 0; j < numY - 1; j++) {
                dragForce(particles[i][j], particles[i+1][j], particles[i][j+1]);
            }
        }

        // Drag force of the right triangle
        for(int i = numX - 1; i > 0; i--) {
            for(int j = numY - 1; j > 0; j--) {
                dragForce(particles[i][j], particles[i-1][j], particles[i][j-1]);
            }
        }*/

        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                particles[i][j].integrate(dt);
            }
        }

        // Collision
        for(Sphere s : spheres) {
            collideSphere(s);
        }

        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                if(particles[i][j].pos.y > floor) {
                    particles[i][j].pos.y = floor;
                    particles[i][j].vel.mult(-0.8);
                }
            }
        }
    }

    void dragForce(Particle p1, Particle p2, Particle p3) {
        PVector vAvg = PVector.div(PVector.add(PVector.add(p2.vel, p3.vel), p1.vel), 3);

        PVector normal = PVector.sub(p2.pos, p1.pos).cross(PVector.sub(p3.pos, p1.pos));
        float coeff = (vAvg.mag() * vAvg.dot(normal)) / (2 * normal.mag());
        PVector aeroF = PVector.mult(normal, -0.5 * airDensity * dragCoeff * coeff);
        aeroF.div(3);

        p1.newAcc.add(aeroF);
        p2.newAcc.add(aeroF);
        p3.newAcc.add(aeroF);
    }


    void collideSphere(Sphere sphere) {
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                float dist = sphere.pos.dist(particles[i][j].pos);
                if(dist < sphere.radius + 2.0) {
                    PVector normal = PVector.mult(PVector.sub(sphere.pos, particles[i][j].pos), -1);
                    normal.normalize();
                    float dot = particles[i][j].vel.dot(normal);
                    PVector bounce = PVector.mult(normal, dot);
                    particles[i][j].vel.sub(PVector.mult(bounce, 1.5));
                    particles[i][j].pos.add(PVector.mult(normal, 3.0 + sphere.radius - dist));
                }
            }
        }
    }

    void draw() {
        noFill();
        textureMode(NORMAL);
        for(int j = 0; j < numY - 1; j++) {
            beginShape(TRIANGLE_STRIP);
            texture(texture);
            for(int i = 0; i < numX; i++) {
                float u = i / (numX - 1.0);
                float v1 = j / (numY - 1.0);
                float v2 = (j+1) / (numY - 1.0);
                vertex(particles[i][j].pos.x, particles[i][j].pos.y, particles[i][j].pos.z, u, v1);
                vertex(particles[i][j+1].pos.x, particles[i][j+1].pos.y, particles[i][j+1].pos.z, u, v2);
            }
            endShape();
        }
    }
}