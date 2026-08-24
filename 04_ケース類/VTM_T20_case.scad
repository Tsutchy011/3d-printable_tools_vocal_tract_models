// --- 3Dプリント用 VTM-T20のケース ---

// [表示設定] 
show_cross_section = false;   // ★実際に3Dプリントする際は false にしてください★

// [声道模型の収納空間の設定] 
// 余裕を見て1mmずつ広めに設定しています
slot_width = 41.0;   // 4x4cm -> 4.1cm
slot_depth = 41.0;   
slot_length = 182.0; // 18cm -> 18.2cm

// [ケース全体の設定]
slot_count = 5;      // 5つの声道模型を入れる
wall_thickness = 3.0; // 外壁と仕切り板の肉厚

// [自動計算パラメータ]
total_inner_width = (slot_width * slot_count) + (wall_thickness * (slot_count - 1));
total_outer_width = total_inner_width + (wall_thickness * 2);
total_outer_depth = slot_depth + (wall_thickness * 2);

total_outer_length = slot_length + wall_thickness; 

$fn = 60; // 曲面の滑らかさ

// --- モジュール定義 ---

module vocal_tract_case() {
    difference() {
        // --- 外側の形状（実体） ---
        cube([total_outer_width, total_outer_depth, total_outer_length], center = false);

        // --- 内側のくり抜き ---
        for (i = [0 : slot_count - 1]) {
            // X軸方向の移動距離を計算
            x_offset = wall_thickness + (i * (slot_width + wall_thickness));
            
            // 1. 収納空間（上へ突き抜けて完全に開放する）
            translate([x_offset, wall_thickness, wall_thickness]) 
                cube([slot_width, slot_depth, slot_length + 1.0], center = false);
            
            // 2. 通気穴（底面に大きな穴を開ける）
            // 縦置きプリントなら、底面に穴があってもサポート材は一切不要で綺麗に抜けます
            translate([x_offset + (slot_width / 2), wall_thickness + (slot_depth / 2), -1])
                cylinder(h = wall_thickness + 2.0, d = 15.0, center = false);
        }
    }
}

// --- 描画処理 ---
if (show_cross_section) {
    difference() {
        vocal_tract_case();
        // 断面を見せるために手前半分をカット
        translate([total_outer_width / 2, -50, -10]) cube([total_outer_width, 100, 300]);
    }
} else {
    vocal_tract_case(); 
}