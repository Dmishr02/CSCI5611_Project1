float d_squared(Vec2 a, Vec2 b) {
    // returns the distance squared between two points
    return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y);
}

Vec2 closest_point_on_line(Vec2 p, Vec2 a, Vec2 b) {
    // returns the closest point on the line segment ab to point p
    Vec2 ap = new Vec2(p.x - a.x, p.y - a.y);
    Vec2 ab = new Vec2(b.x - a.x, b.y - a.y);
    float ab2 = ab.x*ab.x + ab.y*ab.y;
    float ap_ab = ap.x*ab.x + ap.y*ab.y;
    float t = ap_ab / ab2;
    if (t < 0.0) t = 0.0;
    else if (t > 1.0) t = 1.0;
    return new Vec2(a.x + ab.x*t, a.y + ab.y*t);
}

boolean check_ball_line(Circle c, Line l) {
    // find the closest point on the line segment to the circle
    Vec2 closest = closest_point_on_line(c.pos, l.start, l.end);
    // plug in t to parametric equation of line
    float d = d_squared(c.pos, closest);
    return d <= c.r*c.r;
}




boolean check_ball_circle(Ball c1, Circle c2) {
    return d_squared(c1.pos, c2.pos) <= (c1.r + c2.r)*(c1.r + c2.r);
}

boolean check_ball_arc(Ball c, Arc a) {
    // find the distance from the center of the circle to the center of the arc
    float d = d_squared(c.pos, a.pos);
    // distance has to be between arc radius minus ball radius and arc radius plus ball radius
    if (d < (a.r - c.r)*(a.r - c.r)) return false;
    if (d > (a.r + c.r)*(a.r + c.r)) return false;
    // find the angle of the ball relative to the arc
    float angle = atan2(c.pos.y - a.pos.y, c.pos.x - a.pos.x);
    // if the angle is negative, add 2pi to make it positive
    if (angle < 0) angle += 2*PI;
    // print angle
    // println(angle);
    // compare to the angle limits of the arc
    return angle >= a.start && angle <= a.end;
}

boolean check_ball_hole(Ball c, Hole h) {
    // create line from bottom line of hole
    Line l = new Line(h.x0, h.y0 + h.h, h.x0 + h.w, h.y0 + h.h);
    // check for collision with line
    return check_ball_line(c, l);
}

boolean check_ball_ball(Ball c1, Ball c2) {
    return d_squared(c1.pos, c2.pos) <= (c1.r + c2.r)*(c1.r + c2.r);
}
