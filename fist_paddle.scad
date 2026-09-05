// Fist-grip swim paddle - v2, modular
//
// An adaptive paddle for a hemiplegic swimmer whose hand rests closed.
// The fist is laid onto a bar rather than gripping one, so propulsion needs
// no grip strength: water pushes the plate toward the hand, the bar bears on
// the palm, and the load goes into the arm through the fist, not the fingers.
//
// Two printed parts bolted together:
//   "grip"  - the bar, struts and mounting flanges. Fitted once to the hand.
//   "plate" - the pushing surface. Print several diameters and swap them.
// Joined by 4 x M5 A4 stainless countersunk bolts, heads flush on the water
// face, nyloc nuts in hex pockets on top.
//
// Axes:  X = along the grip bar
//        Y = +distal (fingertips) / -proximal (wrist)
//        Z = 0 is the water face; +Z toward the hand
// The XY origin sits under the grip bar axis.
//
// Donning, one-handed: set the paddle plate-down on the deck, open the fist
// with the good hand, lower it onto the bar. Flexor tone closes the fingers.
// The tether is a backup for the recovery, not part of the load path.

/* [What to build] */
// full      - both parts assembled, for looking at
// plate     - the pushing surface, printable
// grip      - the bar and struts, printable
// gripcheck - a 44 mm slice of the grip. Under an hour to print, and it tells
//             you whether the span, the oval and the standoff suit the hand.
part          = "full";  // [full, plate, grip, gripcheck]

/* [Paddle plate] */
plate_dia     = 135;   // minimum is set by clear_span, see the check below
plate_thk     = 3.5;
wrist_trim_f  = 0.40;  // wrist edge trim, as a fraction of plate_dia
edge_round    = 1.2;
tether_holes  = true;  // anchors for a bungee wrist loop

/* [Grip] */
standoff      = 45;    // plate top face to the bar axis
grip_z        = 32;    // bar oval, measured toward the plate
grip_y        = 26;    // bar oval, measured fore-aft
palm_flat     = 20;    // width of the flat the palm seats on. 0 for none.
clear_span    = 100;   // clear width for the fist - MEASURE THIS ONE
grip_angle    = 0;     // degrees. Positive pitches the fingertip edge of the
                       // plate down relative to the hand. A spastic wrist
                       // usually sits flexed, so this will not stay at zero.

// If you sleeve the bar in silicone or neoprene for pressure relief, subtract
// twice the sleeve thickness from grip_z and grip_y before printing.

/* [Struts] */
strut_thk     = 6;
strut_wall    = 4;     // material wrapped around the bar ends
strut_foot    = 64;    // fore-aft length of the mounting flange
flange_w      = 20;
flange_thk    = 7;

/* [Perforation] */
hole_dia      = 13;
hole_pitch    = 24;
hole_margin   = 7;

/* [Fasteners] */
bolt_d        = 5.4;   // M5 clearance
bolt_head_d   = 9.6;   // countersunk head
nut_af        = 9.2;   // M5 nyloc across flats
nut_deep      = 4.5;
bolt_x        = 42;
bolt_y        = 22;

/* [Hidden] */
$fa = 2;
$fs = 0.5;
plate_r    = plate_dia / 2;
wrist_trim = plate_dia * wrist_trim_f;
strut_x    = clear_span / 2 + strut_thk / 2;
flange_x   = strut_x - 9;
bar_z      = flange_thk + standoff;
bar_len    = clear_span + 2 * strut_thk;
eps        = 0.01;

// ---------------------------------------------------------------- balance
// Trimming the wrist edge pulls the plate's area centroid toward the
// fingertips. At the high angles of attack a paddle works at, the centre of
// pressure sits near that centroid, so if it does not line up with the bar
// axis the water spends the whole stroke twisting the paddle in the hand.
// That is a problem for any swimmer and an unmanageable one without grip.
// These functions slide the disc back until the centroid lands on the axis,
// and they re-solve whenever a dimension above changes.

function _th(s)   = 2 * acos((s + wrist_trim) / plate_r);
function _thr(s)  = _th(s) * PI / 180;
function _capA(s) = plate_r * plate_r * (_thr(s) - sin(_th(s))) / 2;
function _capC(s) = s - (4 * plate_r * pow(sin(_th(s) / 2), 3))
                        / (3 * (_thr(s) - sin(_th(s))));
function _cent(s) = (PI * plate_r * plate_r * s - _capA(s) * _capC(s))
                    / (PI * plate_r * plate_r - _capA(s));
function _solve(lo, hi, n) =
    n <= 0 ? (lo + hi) / 2
           : let (m = (lo + hi) / 2)
             _cent(m) > 0 ? _solve(lo, m, n - 1) : _solve(m, hi, n - 1);

plate_shift = wrist_trim >= plate_r
    ? 0
    : _solve(-wrist_trim + 1, plate_r - wrist_trim, 44);

bolt_reach  = sqrt(pow(bolt_x, 2) + pow(bolt_y - plate_shift, 2));
foot_reach  = sqrt(pow(flange_x + flange_w / 2, 2)
                   + pow(strut_foot / 2 - plate_shift, 2));

echo(str("plate ", plate_dia, " mm, disc offset ", plate_shift, " mm"));
echo(str("bolt circle reaches ", bolt_reach, " of ", plate_r, " mm available"));
echo(str("strut feet reach ", foot_reach, " mm"));
if (bolt_reach > plate_r - 9)
    echo("WARNING: plate too small for the bolt pattern, raise plate_dia");
if (foot_reach > plate_r)
    echo("WARNING: strut feet overhang the plate rim, raise plate_dia");

// ---------------------------------------------------------------- plate

module plate_outline() {
    intersection() {
        translate([0, plate_shift]) circle(r = plate_r, $fn = 220);
        translate([-plate_dia, -wrist_trim]) square([2 * plate_dia, 2 * plate_dia]);
    }
}

module plate_blank() {
    hull() {
        linear_extrude(eps) offset(r = -edge_round) plate_outline();
        translate([0, 0, edge_round])
            linear_extrude(plate_thk - 2 * edge_round) plate_outline();
        translate([0, 0, plate_thk - eps])
            linear_extrude(eps) offset(r = -edge_round) plate_outline();
    }
}

function hole_fits(px, py) =
    (sqrt(pow(px, 2) + pow(py - plate_shift, 2)) <= plate_r - hole_dia / 2 - hole_margin)
    && (py >= -wrist_trim + hole_dia / 2 + hole_margin)
    && !(abs(px) + hole_dia / 2 + 3 > flange_x - flange_w / 2
         && abs(px) - hole_dia / 2 - 3 < flange_x + flange_w / 2
         && abs(py) < strut_foot / 2 + hole_dia / 2 + 3);

module hole_cut() {
    cylinder(d = hole_dia, h = plate_thk + 4, center = true, $fn = 60);
    translate([0, 0, plate_thk / 2 - 1.2])
        cylinder(d1 = hole_dia, d2 = hole_dia + 2.4, h = 1.2, $fn = 60);
    translate([0, 0, -plate_thk / 2])
        cylinder(d1 = hole_dia + 2.4, d2 = hole_dia, h = 1.2, $fn = 60);
}

module perforation() {
    rows = ceil((plate_dia + wrist_trim) / (hole_pitch * 0.866)) + 1;
    cols = ceil(plate_dia / hole_pitch) + 1;
    for (j = [-rows : rows], i = [-cols : cols]) {
        px = i * hole_pitch + (j % 2 == 0 ? 0 : hole_pitch / 2);
        py = j * hole_pitch * 0.866;
        if (hole_fits(px, py))
            translate([px, py, plate_thk / 2]) hole_cut();
    }
}

module countersunk_bolt() {
    translate([0, 0, -1]) cylinder(d = bolt_d, h = plate_thk + 2, $fn = 40);
    translate([0, 0, -eps])
        cylinder(d1 = bolt_head_d, d2 = bolt_d, h = (bolt_head_d - bolt_d) / 2, $fn = 40);
}

module plate_part() {
    difference() {
        plate_blank();
        perforation();
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * bolt_x, sy * bolt_y, 0]) countersunk_bolt();
        if (tether_holes)
            for (sx = [-1, 1])
                translate([sx * 38, -wrist_trim + 11, -1])
                    cylinder(d = 6, h = plate_thk + 2, $fn = 30);
    }
}

// ---------------------------------------------------------------- grip
// Profile is drawn in local XY, which maps to global (Z, Y). Rotating the
// bar placement about the local origin tilts the hand relative to the plate
// while leaving the mounting flange flat, so the bolts stay perpendicular.

// The oval alone is a weak angular key. A flat on the side the palm rests
// against gives the hand a definite seat, which matters a great deal when
// there is no voluntary grip to resist the water twisting the paddle.
// Corners are opened out so no edge presses into skin that cannot feel it.

function flat_x(a, b) = palm_flat <= 0 || palm_flat / 2 >= b
    ? a * 2
    : a * sqrt(1 - pow(palm_flat / 2 / b, 2));

module bar_section_2d(grow = 0) {
    a = grip_z / 2 + grow;
    b = grip_y / 2 + grow;
    translate([bar_z, 0])
        rotate(grip_angle)
            offset(r = 2) offset(r = -2)
                intersection() {
                    resize([2 * a, 2 * b]) circle(d = grip_z, $fn = 96);
                    translate([flat_x(a, b) - 100, 0])
                        square([200, 200], center = true);
                }
}

module strut_profile() {
    hull() {
        bar_section_2d(strut_wall);
        translate([flange_thk / 2, 0]) square([flange_thk, strut_foot], center = true);
    }
}

module strut(xp) {
    translate([xp, 0, 0])
        rotate([0, -90, 0])
            linear_extrude(height = strut_thk, center = true) strut_profile();
}

module flange(xp) {
    translate([xp, 0, flange_thk / 2])
        minkowski() {
            cube([flange_w - 4, strut_foot - 4, flange_thk - 2], center = true);
            cylinder(r = 2, h = 1, center = true, $fn = 24);
        }
}

module grip_bar() {
    rotate([0, -90, 0])
        linear_extrude(height = bar_len, center = true)
            bar_section_2d(0);
}

module grip_part() {
    difference() {
        union() {
            flange(flange_x);
            flange(-flange_x);
            strut(strut_x);
            strut(-strut_x);
            grip_bar();
        }
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * bolt_x, sy * bolt_y, 0]) {
                translate([0, 0, -1]) cylinder(d = bolt_d, h = flange_thk + 2, $fn = 40);
                translate([0, 0, flange_thk - nut_deep])
                    cylinder(d = nut_af / cos(30), h = nut_deep + 1, $fn = 6);
            }
    }
}

module gripcheck_part() {
    intersection() {
        grip_part();
        translate([0, 0, bar_z / 2])
            cube([3 * clear_span, 44, bar_z * 2 + 40], center = true);
    }
}

// ---------------------------------------------------------------- output

if (part == "plate")          plate_part();
else if (part == "grip")      grip_part();
else if (part == "gripcheck") gripcheck_part();
else {
    plate_part();
    translate([0, 0, plate_thk]) grip_part();
}
