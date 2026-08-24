// --- 3Dプリント用 リード式音源 リード固定部分 ---

// ★出力するリードの厚みを選択してください（0.2 または 0.3）
reed_thickness = 0.2; 

// 出力の向き
//   true  : 印刷用の姿勢（縦置き・サポート材不要）★デフォルト★
//           ストッパー側の平らな面がベッドに接地し、そのまま印刷できます。
//   false : 寝かせた姿勢（内部構造やスリットをプレビューで確認したいとき）
print_ready_orientation = true;

// === 3Dプリント寸法・嵌合調整パラメーター ===
clearance = 0.25;       // カプセルにはまる時のクリアランス（きつい場合は増やす）

slot_vertical_clearance = 0.05; 

fixed_length = 10.0;    // リードを固定する「屋根」の長さ

// [受け側カプセルの設計値（ここからテーパー角を自動計算します）]
reed_chamber_length = 40.0;
reed_insert_dia_top = 12.8;
reed_insert_dia_bottom = 12.0;

// [台座の基本寸法]
cylinder_depth = 5.0;   
base_w = 12.0;          
base_l = 30.0;          
base_h = 6.5;           

// [音道穴・位置の計算]
hole_w = 6.0;           
hole_h = 4.0;           
hole_bottom_z = -2.0;   
base_top_z = hole_bottom_z + hole_h; // Z=2.0
base_bottom_z = base_top_z - base_h; // Z=-4.5

// 先端の厚み（2.0mm）
taper_end_h = 2.0;      
reed_w = 10.0;          

// === 物理特性に合わせたテーパー（円錐）の外径自動計算 ===
total_length = cylinder_depth + base_l; 
d1_final = reed_insert_dia_bottom - clearance; 
d2_final = (reed_insert_dia_bottom + (reed_insert_dia_top - reed_insert_dia_bottom) * total_length / reed_chamber_length) - clearance; 

// スリットの最終的な高さを計算
actual_slot_h = reed_thickness + slot_vertical_clearance;

$fn = 120; // 曲面の滑らかさ

// --- モジュール定義 ---
module reed_base_part() {
    intersection() {
        // 全体を包み込むテーパー円柱
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h=total_length + 2, d1=d1_final, d2=d2_final);

        difference() {
            union() {
                // 1. 円柱部分（ストッパー）
                translate([0, cylinder_depth, 0])
                    rotate([90, 0, 0])
                        cylinder(h=cylinder_depth, d=15.0); 
                
                // 2. 台座ブロック（屋根を含む）
                translate([-base_w/2, cylinder_depth, base_bottom_z])
                    cube([base_w, base_l, base_h + 5]);
            }
            
            // --- くり抜き・カット ---
            
            // A. 屋根の下の「完全なトンネル」
            translate([-hole_w/2, -0.1, hole_bottom_z])
                cube([hole_w, cylinder_depth + fixed_length + 0.1, hole_h]);
                
            // B. リード下の「U字溝」
            translate([-hole_w/2, cylinder_depth + fixed_length - 0.1, hole_bottom_z])
                cube([hole_w, base_l - fixed_length + 0.2, 10]);

            // C. リードを差し込む「スリット」
            translate([-(reed_w + 0.2)/2, cylinder_depth - 0.1, base_top_z])
                cube([reed_w + 0.2, fixed_length + 0.2, actual_slot_h]);

            // D. 先端のカーブカット（フェイシングカーブ）
            _L1 = cylinder_depth + fixed_length;
            _Z1 = base_top_z;
            _L2 = cylinder_depth + base_l;
            _Z2 = base_bottom_z + taper_end_h; 
            
            _R = (pow(_L2 - _L1, 2) + pow(_Z2 - _Z1, 2)) / (2 * (_Z1 - _Z2));
            _Cy = _L1;
            _Cz = _Z1 - _R;

            _cut_width = base_w + 2;
            _cut_length = _L2 - _L1 + 2;
            _cut_height = 20;

            difference() {
                translate([-_cut_width/2, _L1 - 0.1, _Z2 - 5])
                    cube([_cut_width, _cut_length, _cut_height]);

                translate([0, _Cy, _Cz])
                    rotate([0, 90, 0])
                        cylinder(h=_cut_width + 2, r=_R, center=true, $fn=240);
            }
        }
    }
}

// --- 描画処理 ---
if (print_ready_orientation) {
    rotate([90, 0, 0])
        reed_base_part();
} else {
    reed_base_part();
}