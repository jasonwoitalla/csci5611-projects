public class Sphere {

    public PVector pos;
    public float radius;

    public Sphere(PVector pos, float radius) {
        this.pos = pos;
        this.radius = radius;
    }

    public void draw() {
        fill(50, 200, 50);
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        sphere(radius);
        popMatrix();
    }
}