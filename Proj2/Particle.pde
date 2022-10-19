public class Particle {
    
    public PVector pos;
    public PVector vel;
    public PVector acc;
    public PVector newAcc;

    float mu = 0.4;

    public Particle(PVector pos) {
        this.pos = pos;
        this.vel = new PVector(0, 0);
        this.acc = new PVector(0, 0);
    }

    public void setPos(float x, float y, float z) {
        this.pos = new PVector(x, y, z);
    }

    public void applyGravity() {
        newAcc = new PVector(0, 0, 0);
        newAcc.add(gravity);
    }

    // Verlet integration
    // Algorithm found from: https://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
    public void integrate(float dt) {
        PVector accTerm = PVector.mult(acc, dt*dt*0.5);
        PVector velTerm = PVector.mult(vel, dt);
        pos.add(PVector.add(velTerm, accTerm));
        vel.add(PVector.mult(PVector.add(acc, newAcc), dt*0.5));
    }
}