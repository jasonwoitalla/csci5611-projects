public class Cloth {

    PVector pos[][] = new PVector[maxNodes][maxNodes];
    PVector vel[][] = new PVector[maxNodes][maxNodes];
    PVector acc[][] = new PVector[maxNodes][maxNodes];

    PVector stringTop;
    PImage texture;
    int numX = 10;
    int numY = 10;
    float restLen = 10;
    float ks = 200;
    float kd = 30;
    float dragCoeff = 0.2;

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
                pos[i][j] = new PVector(0, 0, 0);
                pos[i][j].x = stringTop.x + restLen * i;
                pos[i][j].y = stringTop.y;
                pos[i][j].z = restLen * j;
                //pos[i][j].z = stringTop.z + restLen * i;
                vel[i][j] = new PVector(0, 0, 0);
                acc[i][j] = new PVector(0, 0, 0);
            }
        }

        for(int i = 0; i < numX; i++) {
            pos[i][0] = new PVector(0, 0);
            pos[i][0].x = stringTop.x + restLen * i;
            pos[i][0].y = stringTop.y;
        }
    }

    void update(float dt, ArrayList<Sphere> spheres) {

        //eulerianIntegration(dt);
        verletIntegration(dt);

        // Collision
        for(Sphere s : spheres) {
            collideSphere(s);
        }

        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                if(pos[i][j].y > floor) {
                    vel[i][j].y *= -0.9;
                    pos[i][j].y = floor;
                }
            }
        }
    }

    void applyForces(PVector[][] newAcc) {
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                newAcc[i][j] = new PVector(0, 0);
                newAcc[i][j].add(gravity);
            }
        }

        // Horizontal Springs
        for(int i = 0; i < numX-1; i++) {
            for(int j = 0; j < numY; j++) {
                PVector diff = PVector.sub(pos[i+1][j], pos[i][j]);
                float len = diff.mag();
                diff.normalize();

                float v1 = diff.dot(vel[i][j]);
                float v2 = diff.dot(vel[i+1][j]);
                float stringF = -ks * (restLen - len);
                float forceMag = stringF - kd*(v1-v2);
                PVector force = PVector.mult(diff, forceMag);
                newAcc[i][j].add(force);
                newAcc[i+1][j].sub(force);
            }
        }

        // Vertical Springs
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY-1; j++) {
                PVector diff = PVector.sub(pos[i][j+1], pos[i][j]);
                float len = diff.mag();
                diff.normalize();

                float v1 = diff.dot(vel[i][j]);
                float v2 = diff.dot(vel[i][j+1]);
                float stringF = -ks * (restLen - len);
                float forceMag = stringF - kd*(v1-v2);
                PVector force = PVector.mult(diff, forceMag);
                newAcc[i][j].add(force);
                newAcc[i][j+1].sub(force);
            }
        }

        //applyDrag();

        //for(int i = 0; i < numX; i++) {
            //newAcc[i][0] = new PVector(0, 0, 0);
        //}
    }

    void applyDrag() {
        // Drag force of left triangle
        for(int i = 0; i < numX - 1; i++) {
            for(int j = 0; j < numY - 1; j++) {
                airForceAt(i, j, i+1, j, i, j+1);
            }
        }

        // Drag force of the right triangle
        for(int i = numX - 1; i > 0; i--) {
            for(int j = numY - 1; j > 0; j--) {
                airForceAt(i, j, i-1, j, i, j-1);
            }
        }
    }

    void airForceAt(int pi1, int pj1, int pi2, int pj2, int pi3, int pj3) {
        PVector vAvg = PVector.div(PVector.add(PVector.add(vel[pi1][pj1], vel[pi2][pj2]), vel[pi3][pj3]), 3.0);
        PVector r1 = PVector.sub(pos[pi1][pj1], pos[pi2][pj2]);
        PVector r2 = PVector.sub(pos[pi1][pj1], pos[pi3][pj3]);
        PVector r3 = PVector.sub(pos[pi2][pj2], pos[pi3][pj3]);
        PVector normal = PVector.sub(r2, r1).cross(PVector.sub(r3, r1));
        float coeff = (vAvg.mag() * vAvg.dot(normal)) / (2 * normal.mag());
        PVector aeroF = PVector.mult(normal, -0.5 * airDensity * dragCoeff * coeff);
        aeroF.div(3);
        acc[pi1][pj1].add(aeroF);
        acc[pi2][pj2].add(aeroF);
        acc[pi3][pj3].add(aeroF);
    }

    void eulerianIntegration(float dt) {
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                vel[i][j].add(PVector.mult(acc[i][j], dt));
                pos[i][j].add(PVector.mult(vel[i][j], dt));
            }
        }
    }

    // Algorithm found from: https://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
    void verletIntegration(float dt) {
        PVector[][] newAcc = new PVector[maxNodes][maxNodes];
        applyForces(newAcc);

        // Integration
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                PVector accTerm = PVector.mult(acc[i][j], dt*dt*0.5);
                PVector velTerm = PVector.mult(vel[i][j], dt);
                pos[i][j].add(PVector.add(velTerm, accTerm));
                vel[i][j].add(PVector.mult(PVector.add(acc[i][j], newAcc[i][j]), dt*0.5));
            }
        }

        for(int i = 0; i < numX; i++) {
            acc[i] = newAcc[i].clone();
        }
    }

    void collideSphere(Sphere sphere) {
        for(int i = 0; i < numX; i++) {
            for(int j = 0; j < numY; j++) {
                float dist = sphere.pos.dist(pos[i][j]);
                if(dist < sphere.radius + 2.0) {
                    PVector normal = PVector.mult(PVector.sub(sphere.pos, pos[i][j]), -1);
                    normal.normalize();
                    float dot = vel[i][j].dot(normal);
                    PVector bounce = PVector.mult(normal, dot);
                    vel[i][j].sub(PVector.mult(bounce, 1.5));
                    pos[i][j].add(PVector.mult(normal, 3.0 + sphere.radius - dist));
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
                vertex(pos[i][j].x, pos[i][j].y, pos[i][j].z, u, v1);
                vertex(pos[i][j+1].x, pos[i][j+1].y, pos[i][j+1].z, u, v2);
            }
            endShape();
        }
    }
}