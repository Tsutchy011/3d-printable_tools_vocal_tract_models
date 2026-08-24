// --- 3Dプリント用 リード式音源 本体部分 ---

// ★出力するパーツを選んでください★
// "10MM" : 10mm声道模型用（ストレートプラグ）
// "20MM" : 20mmアクリル音響管用（テーパー付きプラグ）
// "ALL"  : 両方並べて表示（一気に印刷用）
render_target = "ALL"; 

// [表示設定] 
show_cross_section = false;   // 断面を見たい時は true に変更

// [リード式音源の共通設定]
reed_chamber_length = 40.0;
reed_insert_dia_top = 12.8;
reed_insert_dia_bottom = 12.0;
capsule_outer_diameter = 18.0;
taper_height = 10.0;

$fn = 240; // 滑らかさ（出力用高精度）

// ==========================================
// モジュール1: 10mm声道模型用
// ==========================================
module reed_capsule_10mm() {
    plug_outer_diameter = 9.7;
    plug_inner_diameter = 7.0; 
    plug_length = 12.0;
    flange_diameter = 38.0;
    flange_thickness = 2.0;

    difference() {
        union() {
            cylinder(h = plug_length, d = plug_outer_diameter, center = false);
            translate([0, 0, plug_length]) cylinder(h = flange_thickness, d = flange_diameter, center = false);
            translate([0, 0, plug_length + flange_thickness]) cylinder(h = taper_height, d1 = flange_diameter, d2 = capsule_outer_diameter, center = false);
            translate([0, 0, plug_length + flange_thickness + taper_height]) cylinder(h = reed_chamber_length, d = capsule_outer_diameter, center = false);
        }
        // 音の直結ルート（貫通穴）
        translate([0, 0, -1]) cylinder(h = plug_length + flange_thickness + taper_height + 1, d = plug_inner_diameter, center = false);
        // リード室
        translate([0, 0, plug_length + flange_thickness + taper_height])
            cylinder(h = reed_chamber_length + 1, d1 = reed_insert_dia_bottom, d2 = reed_insert_dia_top, center = false);
    }
}

// ==========================================
// モジュール2: 20mmアクリル管用（テーパー付きオス型）
// ==========================================
module reed_capsule_20mm() {
    plug_tip_diameter = 19.5;
    plug_root_diameter = 19.9;
    plug_inner_diameter = 7.0;
    plug_length = 15.0;
    flange_diameter = 30.0;
    flange_thickness = 2.0;

    difference() {
        union() {
            cylinder(h = plug_length, d1 = plug_tip_diameter, d2 = plug_root_diameter, center = false);
            translate([0, 0, plug_length]) cylinder(h = flange_thickness, d = flange_diameter, center = false);
            translate([0, 0, plug_length + flange_thickness]) cylinder(h = taper_height, d1 = flange_diameter, d2 = capsule_outer_diameter, center = false);
            translate([0, 0, plug_length + flange_thickness + taper_height]) cylinder(h = reed_chamber_length, d = capsule_outer_diameter, center = false);
        }

        translate([0, 0, -1]) cylinder(h = plug_length + flange_thickness + taper_height + 1, d = plug_inner_diameter, center = false);
        
        // リード室
        translate([0, 0, plug_length + flange_thickness + taper_height])
            cylinder(h = reed_chamber_length + 1, d1 = reed_insert_dia_bottom, d2 = reed_insert_dia_top, center = false);
    }
}

// ==========================================
// 描画・配置の統合管理モジュール
// ==========================================
module render_all_parts() {
    // それぞれの高さを計算（ひっくり返してZ=0に揃えるため）
    z_offset_10mm = 12.0 + 2.0 + 10.0 + 40.0; // plug + flange + taper + chamber
    z_offset_20mm = 15.0 + 2.0 + 10.0 + 40.0; 

    if (render_target == "10MM") {
        translate([0, 0, z_offset_10mm]) rotate([180, 0, 0]) reed_capsule_10mm();
    } else if (render_target == "20MM") {
        translate([0, 0, z_offset_20mm]) rotate([180, 0, 0]) reed_capsule_20mm();
    } else if (render_target == "ALL") {
        // ぶつからないように左右にズラして配置
        translate([-25, 0, z_offset_10mm]) rotate([180, 0, 0]) reed_capsule_10mm();
        translate([ 25, 0, z_offset_20mm]) rotate([180, 0, 0]) reed_capsule_20mm();
    }
}

// --- 最終実行部（断面表示機能） ---
if (show_cross_section) {
    difference() {
        render_all_parts();
        translate([-50, -100, -10]) cube([100, 100, 100]); // 手前半分をカット
    }
} else {
    render_all_parts(); // 通常の出力
}