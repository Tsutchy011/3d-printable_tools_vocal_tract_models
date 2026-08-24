// --- 3Dプリント用 スライド式3音響管のパーツ ---

// [寸法設定]
body_length = 30.0;
body_outer_dia = 19.6;      // 20mm管用のスライダー外径
hole_dia = 8.0;             // 狭めの内径は8mm
rod_offset = 6.9;           // 8mm穴と外壁の「真ん中」にロッドが来るように
rod_dia = 4.0;              // 棒の太さ
inner_rod_length = 145.0;   // 内側の棒の長さ
outer_rod_length = 100.0;   // 外側の棒（持ち手）の長さ
tube_outer_dia = 26.0;      // 音響管の外径
outer_offset = (tube_outer_dia / 2) + (rod_dia / 2) + 2.0; 

$fn = 60; // 滑らかさ

// --- 1. スライダー本体（立ててプリント） ---
translate([0, 20, 0]) {
    difference() {
        cylinder(h = body_length, d = body_outer_dia, center = false);
        
        // 狭めの内径: 8mm
        translate([0, 0, -1]) cylinder(h = body_length + 2, d = hole_dia, center = false);
        
        // ロッドを差し込むための穴（深さ10mm）
        translate([rod_offset, 0, body_length - 10]) 
            cylinder(h = 11, d = rod_dia + 0.3, center = false);
    }
}

// --- 2. トロンボーンロッド（寝かせてプリント） ---
translate([0, -10, rod_dia/2]) {
    union() {
        // 本体に差し込むための10mmを余分に長くしています
        translate([-10, 0, 0])
            rotate([0, 90, 0]) cylinder(h = inner_rod_length + 10, d = rod_dia);
        
        // 折り返し（Uターン）部分
        hull() {
            translate([inner_rod_length, 0, 0]) sphere(d = rod_dia);
            translate([inner_rod_length, -(outer_offset - rod_offset), 0]) sphere(d = rod_dia);
        }
        
        // 外側のロッド（持ち手）
        translate([inner_rod_length - outer_rod_length, -(outer_offset - rod_offset), 0])
            rotate([0, 90, 0]) cylinder(h = outer_rod_length, d = rod_dia);
            
        // グリップ（指掛け）
        translate([inner_rod_length - outer_rod_length, -(outer_offset - rod_offset), 0])
            hull() {
                sphere(d = rod_dia + 4);
                translate([-3, 0, 0]) sphere(d = rod_dia);
            }
    }
}