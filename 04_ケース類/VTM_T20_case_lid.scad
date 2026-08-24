// --- 3Dプリント用 VTM-T20ケース 蓋 ---

// [表示設定] 内部構造を確認するために断面図を表示します
show_cross_section = false;   // ★ 実際に3D プリントする際は false にしてください ★

// [ケース側の寸法（変更しないでください）]
slot_width = 41.0;
slot_depth = 41.0;
slot_count = 5;
wall_thickness = 3.0;

// [自動計算パラメータ（ケース本体の外寸）]
total_inner_width = (slot_width * slot_count) + (wall_thickness * (slot_count - 1));
case_outer_width = total_inner_width + (wall_thickness * 2);
case_outer_depth = slot_depth + (wall_thickness * 2);

// [フタ（Lid）の設定]
clearance_top = 0.6;      // ★入り口の隙間（広め）
clearance_bottom = -0.1;  // ★奥の隙間（マイナスにして摩擦で食い込ませる）

lid_wall_thickness = 3.0; // 押し込む力に耐えるため肉厚（3mm）に
lid_top_thickness = 2.0;  // フタの天井の肉厚
lid_skirt_height = 20.0;  // フタがケースに被さる深さ

// [固定用ペグ（棒）の設定]
peg_diameter = 9.6;       // 10mm穴にスムーズに入るサイズ

// [フタの寸法計算]
lid_inner_width = case_outer_width + (clearance_top * 2);
lid_inner_depth = case_outer_depth + (clearance_top * 2);
lid_outer_width = lid_inner_width + (lid_wall_thickness * 2);
lid_outer_depth = lid_inner_depth + (lid_wall_thickness * 2);
lid_total_height = lid_skirt_height + lid_top_thickness;

$fn = 60; // 曲面の滑らかさ

// --- モジュール定義 ---

module case_lid_friction_fit() {
    union() {
        difference() {
            // --- 外側の形状 ---
            cube([lid_outer_width, lid_outer_depth, lid_total_height], center = false);

            // --- 内側のくり抜き（★テーパー状に絞る★） ---
            // hull() を使って、奥（狭い）と手前（広い）を滑らかに繋ぎます
            translate([lid_outer_width / 2, lid_outer_depth / 2, lid_top_thickness]) {
                hull() {
                    // 1. 奥側（フタの天井付近）：マイナスクリアランスで絞る
                    translate([0, 0, 0.05])
                        cube([case_outer_width + (clearance_bottom * 2), 
                              case_outer_depth + (clearance_bottom * 2), 
                              0.1], center = true);
                    
                    // 2. 入り口側：プラスクリアランスでスポッと入る
                    translate([0, 0, lid_skirt_height + 1.0])
                        cube([case_outer_width + (clearance_top * 2), 
                              case_outer_depth + (clearance_top * 2), 
                              0.1], center = true);
                }
            }
        }

        // --- 固定用の棒（ペグ）を追加 ---
        for (i = [0 : slot_count - 1]) {
            // ケース基準でのスロット中心座標を計算
            case_x_center = wall_thickness + (i * (slot_width + wall_thickness)) + (slot_width / 2);
            case_y_center = wall_thickness + (slot_depth / 2);
            
            // フタ基準の座標に変換
            lid_x_center = case_x_center + lid_wall_thickness + clearance_top;
            lid_y_center = case_y_center + lid_wall_thickness + clearance_top;

            // 天井（Z=0）から下に向かって生やす
            translate([lid_x_center, lid_y_center, 0])
                cylinder(h = lid_total_height, d = peg_diameter, center = false);
        }
    }
}

// --- 描画処理 ---
if (show_cross_section) {
    difference() {
        case_lid_friction_fit();
        // 断面を見せるために手前半分をカット
        translate([lid_outer_width / 2, -50, -10]) cube([lid_outer_width, 200, 300]);
    }
} else {
    case_lid_friction_fit();
}