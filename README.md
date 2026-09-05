# Fist-Grip Swim Paddle

A 3D-printable swim paddle held by a bar inside a closed fist, instead of strapped flat to an open palm.

It was designed for swimmers with hemiplegia. Spasticity holds the affected hand closed, and a closed fist presents almost no surface to the water — which is why "fist gloves" are sold to able-bodied swimmers as a drill to *remove* feel. An ordinary hand paddle assumes an open palm and a working grip, so it is not an option. This paddle gives the closed fist back roughly the pushing surface an open hand would have had, without requiring the hand to open or to grip.

Everything is parametric. The point of this repository is not the STLs — it is the `.scad` file, so you can fit it to a specific person.

---

## Safety first

This is an unregulated, home-made device used in water. Read this part.

- **Get a physiotherapist or occupational therapist involved.** Not as a formality. They can position the arm to measure the wrist angle the design depends on, and they can judge whether adding drag to the affected arm is safe. Shoulder subluxation is common on the hemiplegic side.
- **Check the skin after every one of the first several sessions**, especially where the palm sits on the bar's flat and where the fingertips press against the plate. Reduced sensation on the affected side is normal, which means a pressure mark can develop without being felt.
- **Never use a closed loop the hand cannot be pulled out of.** If you fit a wrist tether, use elastic shock cord so it stretches off under load. Webbing that cinches is the wrong choice here.
- **Supervised water only**, at least until the swimmer and whoever helps them are confident in donning and removing it quickly.
- This is not a flotation aid and does nothing to keep anyone afloat.
- Start with short sets. Paddles are a well-known route into shoulder trouble even for unimpaired swimmers.

---

## How it works

The non-obvious part is which side of the fist the plate goes on, and it follows from tracing the load.

The plate sits on the palm side, past the fingertips. During the pull, water pushes the plate *toward* the hand. That force travels up the struts into the bar, and the bar presses into the palm. The arm resists it directly.

**No grip strength is used for propulsion.** The fingers only matter during the recovery, when the arm is out of the water and forces are small — and spastic flexor tone tends to close the fingers around the bar on its own, which for once works in our favour.

If you flipped it and put the plate on the back-of-hand side, every newton of propulsion would try to rip the paddle out of the hand and grip strength would be the only thing holding it. That version does not work for anyone, and especially not here.

The design is symmetric, so the same files serve a left or a right hand.

---

## What you print

| Part | File | Time | Notes |
|---|---|---|---|
| Fit gauge | `grip_fit_gauge.stl` | ~1 h | A 44 mm slice of the grip. **Print this first.** |
| Grip module | `grip_module.stl` | ~3 h | The fitted part. Supports needed under the bar. |
| Plate | `plate_120mm.stl` … `plate_165mm.stl` | ~1.5 h | Bolts on, swappable. Start small. |

Plus **4 × M5 × 16 A4 stainless countersunk bolts and M5 A4 nyloc nuts**. Bolt heads sit flush on the water face; nuts drop into hex pockets, so it assembles with a screwdriver alone. File flush any thread poking above a nut.

### Print settings

- **PETG or ABS.** Not PLA — it softens in a warm pool and creeps under sustained load.
- Grip module: flanges down on the bed, **supports under the bar only**. Slicers like to fill the hex nut pockets with support too; paint supports manually or raise the overhang threshold.
- Plate: flat on the bed, no supports.
- 4 perimeters minimum. The struts carry everything.
- 25 % infill is plenty. Grip module ≈ 74 g, plates 22–41 g.

---

## Fitting it — the actual workflow

**1. Print the fit gauge.** It has the real bar, real span, real palm flat, real standoff, at a fraction of the print time.

**2. Try it on a table.** Set it flat, open the fist with the other hand, lower it on. You are checking three things:

- the fist fits the span, with the thumb wherever it naturally falls
- the palm settles onto the flat rather than rolling off it
- the fingertips clear the plate strip with a little room

Adjust, reprint the gauge, repeat. This loop costs an hour.

**3. Find the wrist angle.** This is the parameter most likely to need a second attempt and the one you cannot judge from a table top. Have the therapist hold the arm in the catch position with the gauge on the hand, and look at where the plate faces. It should be roughly square to the direction of the pull. A spastic wrist usually sits flexed and pronated, so the answer is rarely zero. Photograph it from the side and measure off the photo if that helps.

**4. Print the grip module** with `grip_angle` set, and one plate.

**5. Swim, then increase plate size** only if the stroke rate holds and the shoulder stays quiet.

---

## Parameter reference

Open `fist_paddle.scad`. Everything above the `[Hidden]` marker is meant to be edited. Press **F5** to preview, **F6** for the real render, then **File → Export → Export as STL**. Always F6 before exporting or you can get a broken mesh.

Set `part` to `gripcheck`, `grip`, `plate`, or `full` to choose what gets built.

### The ones that decide fit

| Parameter | What it is | How to find your number |
|---|---|---|
| `clear_span` | Clear width between the struts | Widest point across the closed fist, including the thumb where it lies, plus 8–10 mm |
| `grip_z` / `grip_y` | Bar oval, toward the plate / fore-aft | The natural aperture inside the resting fist. Too large and the hand will not go on |
| `palm_flat` | Width of the flat the palm seats on | 20 mm suits most hands. Larger keys the angle harder; 0 removes it |
| `standoff` | Plate face to bar axis | Bar axis to the outermost point of the curled fingers, plus 8–12 mm |
| `grip_angle` | Hand tilt relative to the plate | Measured on the swimmer in the catch position. Positive raises the wrist end |

### The ones that decide how it swims

| Parameter | Effect |
|---|---|
| `plate_dia` | Pushing area. Below 135 mm the strut feet overhang the rim — usable, just file the corners |
| `hole_dia`, `hole_pitch` | More or bigger holes soften the catch and reduce load |
| `plate_thk` | Stiffness and mass. The arm lifts this clear of the water every stroke |
| `wrist_trim_f` | How much of the wrist edge is cut away, as a fraction of diameter |

### Do not hand-tune the disc offset

`plate_shift` is solved, not set. Trimming the wrist edge pulls the plate's area centroid toward the fingertips, and at the angles a paddle actually works at, the centre of pressure sits near that centroid. If it does not line up with the bar axis, water spends the whole stroke twisting the paddle in the hand — a nuisance for any swimmer and unmanageable without grip. The file bisects for the offset that puts the centroid on the axis, and re-solves whenever you change a dimension. Change `plate_dia` or `wrist_trim_f` freely; the balance follows.

---

## Comfort and pressure

Sleeve the bar in silicone tube or adhesive neoprene. It spreads pressure over skin that may not report a problem, and it stops printed layer lines abrading. **If you do, subtract twice the sleeve thickness from `grip_z` and `grip_y` before printing.**

Thread a bungee wrist loop through the two holes at the wrist edge of the plate. Elastic, not webbing. It is a backup for the recovery phase, not part of the load path.

---

## Troubleshooting

| Symptom | Try |
|---|---|
| Paddle twists in the hand during the pull | Increase `palm_flat`; check `grip_angle` is right |
| Hand will not go onto the bar | Reduce `grip_z` / `grip_y`; increase `clear_span` |
| Fingertips sore or marked | Increase `standoff` |
| Plate contacts the forearm at the catch | Increase `wrist_trim_f` |
| Pushes water at the wrong angle | Adjust `grip_angle` and reprint the grip module |
| Too much load on the shoulder | Smaller plate, or larger `hole_dia` |
| Red marks across the palm | Sleeve the bar; reduce `palm_flat` |
| Hand slides side to side | Reduce `clear_span` |

---

## Contributing

The most useful contributions are fitting reports: hand dimensions, the parameter values that worked, and what you had to change. That is the data this design lacks. Photographs of the device in use, with consent, help more than renders.

If you are a clinician and something here is wrong, please open an issue. This was engineered from first principles, not from clinical practice, and it has been tested by very few people.

## License

<!-- Suggested: CERN-OHL-S or CC BY-SA 4.0 for hardware. Pick one and replace this line. -->
