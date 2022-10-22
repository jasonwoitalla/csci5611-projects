public class Rope {

    PVector pos[] = new PVector[maxNodes];
    PVector vel[] = new PVector[maxNodes];
    PVector acc[] = new PVector[maxNodes];

    int numNodes = 10;
    float radius = 5.0;
    float restLen = 10;
    float mass = 1.0;
    float k = 200;
    float kv = 30;

    public Rope(PVector stringTop, float radius, float restLen, float mass, float k, float kv, int numNodes) {
        this.radius = radius;
        this.restLen = restLen;
        this.mass = mass;
        this.k = k;
        this.kv = kv;
        this.numNodes = numNodes;

        for(int i = 0; i < numNodes; i++) {
            pos[i] = new PVector(0, 0);
            pos[i].x = stringTop.x + radius*i;
            pos[i].y = stringTop.y + (radius * 1.5) * i;
            vel[i] = new PVector(0, 0);
        }
    }

    public Rope(PVector top, int numNodes) {
        this(top, 5.0, 10.0, 1.0, 200.0, 30.0, numNodes);
    }

    void update(float dt) {

        // Acceleartion
        for(int i = 0; i < numNodes; i++) {
            acc[i] = new PVector(0, 0);
            acc[i].add(gravity);
        }

        // Hooke's law
        for(int i = 0; i < numNodes-1; i++) {
            PVector diff = PVector.sub(pos[i+1], pos[i]);
            float stringF = -k * (diff.mag() - restLen);

            PVector stringDir = diff.copy().normalize();
            float projVelBottom = vel[i].dot(stringDir);
            float projVelTop = vel[i+1].dot(stringDir);
            float dampF = -kv * (projVelTop - projVelBottom);

            PVector force = PVector.mult(stringDir, stringF+dampF);
            acc[i].add(PVector.mult(force, (-1.0/mass)));
            acc[i+1].add(PVector.mult(force, (1.0/mass)));
        }

        for(int i = 1; i < numNodes; i++) {
            integrate(pos[i], vel[i], acc[i], dt);
        }

        for(int i = 0; i < numNodes; i++) { // Collision
            if(pos[i].y+radius > floor) {
                vel[i].y *= -0.9;
                pos[i].y = floor - radius;
            }
        }
    }

    void draw() {
        for(int i = 0; i < numNodes-1; i++) {
            pushMatrix();
            line(pos[i].x, pos[i].y, pos[i+1].x, pos[i+1].y);
            translate(pos[i+1].x, pos[i+1].y);
            sphere(radius);
            popMatrix();
        }
    }
}
