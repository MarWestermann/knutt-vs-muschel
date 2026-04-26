// hardware-v2: Parametrisches Spielfeld 200x200 mm
// - 6x6 Mulden (quadratisch, gerundete Ecken)
// - Zahlen 1..6 oben und links (graviert)
// Einheit: mm

$fn = 64;

// --- Grundmaße ---
board_size = 200;
board_thickness = 18;
gap = 1.2;
header_ratio = 0.55;
playfield_shift_x = -2.0; // negativ = nach links, positiv = nach rechts
playfield_shift_y = 2.0;  // positiv = nach oben, negativ = nach unten

// Layout: h + 6*c + 6*gap = board_size, h = header_ratio*c
cell = (board_size - 6 * gap) / (6 + header_ratio);
header = header_ratio * cell;

// --- Mulde ---
mulde_side = 29.0;
mulde_corner_r = 4.8;
mulde_depth = 3.5;
mulde_layers = 14;      // mehr = glatter
mulde_profile_exp = 1.8; // >1: flacher Rand, steilere Mitte

// --- Gravur ---
num_depth = 0.35;
num_size = min(header, cell) * 0.62;
num_font = "Liberation Sans:style=Bold";

eps = 0.02;

module rounded_square_2d(side, r) {
    rr = max(0, min(r, side / 2));
    if (rr <= 0.001) {
        square([side, side], center = true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx * (side / 2 - rr), sy * (side / 2 - rr)])
                    circle(r = rr);
            }
        }
    }
}

function play_cell_left(ix) = header + gap + ix * (cell + gap) + playfield_shift_x;
function play_row_bottom(iy) = iy * (cell + gap); // iy=0 ist unterste Spielreihe
function play_center_x(ix) = play_cell_left(ix) + cell / 2;
function play_center_y_from_bottom(iy) = play_row_bottom(iy) + cell / 2 + playfield_shift_y;

function top_header_y() = board_size - header / 2 + playfield_shift_y;
function left_header_x() = header / 2;

module lake_mulde(center_x, center_y) {
    // Schüsselform per geschichteter Hüllflächen
    translate([center_x, center_y, board_thickness - mulde_depth]) {
        union() {
            for (i = [0 : mulde_layers - 1]) {
                t0 = i / mulde_layers;
                t1 = (i + 1) / mulde_layers;

                // Inset ist oben klein (große Öffnung) und wächst zur Tiefe
                max_inset = mulde_side * 0.46;
                inset0 = max_inset * pow(1 - t0, mulde_profile_exp);
                inset1 = max_inset * pow(1 - t1, mulde_profile_exp);

                side0 = max(0.6, mulde_side - 2 * inset0);
                side1 = max(0.6, mulde_side - 2 * inset1);
                r0 = min(max(0, mulde_corner_r - inset0), side0 / 2);
                r1 = min(max(0, mulde_corner_r - inset1), side1 / 2);

                z0 = mulde_depth * t0;
                z1 = mulde_depth * t1;

                hull() {
                    translate([0, 0, z0])
                        linear_extrude(height = eps)
                            rounded_square_2d(side0, r0);
                    translate([0, 0, z1])
                        linear_extrude(height = eps)
                            rounded_square_2d(side1, r1);
                }
            }
        }
    }
}

module all_mulden() {
    for (iy = [0 : 5]) {
        for (ix = [0 : 5]) {
            x = play_center_x(ix);
            y = play_center_y_from_bottom(iy);
            lake_mulde(x, y);
        }
    }
}

module all_numbers() {
    // Oben: 1..6
    for (ix = [0 : 5]) {
        x = play_center_x(ix);
        y = top_header_y();
        translate([x, y, board_thickness - num_depth])
            linear_extrude(height = num_depth + eps)
                text(str(ix + 1), size = num_size, font = num_font, halign = "center", valign = "center");
    }

    // Links: 1..6 von oben nach unten
    for (rowTop = [1 : 6]) {
        x = left_header_x();
        y = board_size - header - gap - (rowTop - 0.5) * cell - (rowTop - 1) * gap + playfield_shift_y;
        translate([x, y, board_thickness - num_depth])
            linear_extrude(height = num_depth + eps)
                text(str(rowTop), size = num_size, font = num_font, halign = "center", valign = "center");
    }
}

difference() {
    cube([board_size, board_size, board_thickness], center = false);
    all_mulden();
    all_numbers();
}

