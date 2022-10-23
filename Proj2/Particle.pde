public class Particle {
    
    public PVector pos;
    public PVector vel;
    public PVector acc;
    public PVector newAcc;

    public PVector goalPos;
    boolean hasGoalForce = false;
    float forceSpeed = 100.0;

    float kGoal = 5.0;
    float mu = 0.4;

    public Particle(PVector pos) {
        this.pos = pos;
        this.vel = new PVector(0, 0);
        this.acc = new PVector(0, 0);
    }

    public void setPos(float x, float y, float z) {
        this.pos = new PVector(x, y, z);
    }

    public void setGoalForce(PVector goalPos) {
        this.goalPos = goalPos;
        hasGoalForce = true;
    }

    public void clearGoalForce() {
        hasGoalForce = false;
    }

    public void applyForce() {
        if(!hasGoalForce) {
            newAcc = new PVector(0, 0, 0);
            newAcc.add(gravity);
        } else {
            newAcc = new PVector(0, 0, 0);
            PVector goalVel = PVector.sub(goalPos, pos);
            if(goalVel.mag() > forceSpeed) goalVel.limit(forceSpeed);
            
            PVector goalForce = new PVector(0, 0, 0);
            goalForce = PVector.sub(goalVel, vel).mult(kGoal);

            newAcc.add(goalForce);
        }
    }

    public void addAcc(PVector force) {
        if(hasGoalForce)
            return;
        newAcc.add(force);
    }

    public void subAcc(PVector force) {
        if(hasGoalForce)
            return;
        newAcc.sub(force);
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