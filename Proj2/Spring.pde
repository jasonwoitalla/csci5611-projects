public class Spring {
    
    Particle p1, p2;

    float ks;
    float kd;
    float restLen;

    public Spring(float ks, float kd, float restLen, Particle p1, Particle p2) {
        this.ks = ks;
        this.kd = kd;
        this.restLen = restLen;
        this.p1 = p1;
        this.p2 = p2;
    }

    public void applyForce() {

        PVector diff = PVector.sub(p2.pos, p1.pos);
        float len = diff.mag();
        diff.normalize();

        float v1 = diff.dot(p1.vel);
        float v2 = diff.dot(p2.vel);

        float stringF = -ks * (restLen - len);
        float forceMag = stringF - kd * (v1 - v2);
        PVector force = PVector.mult(diff, forceMag);

        p1.addAcc(force);
        p2.subAcc(force);
    }
}