// --- 3Dプリント用 17cm音響管 ---

// [管の基本寸法]
tube_length = 170.0;     
tube_outer_dia = 26.0;   

// [内径と3Dプリント用補正]
base_inner_dia = 20.0;   
hole_compensation = 0.3; 
actual_inner_dia = base_inner_dia + hole_compensation;

rib_count = 3;         // 最低限の揺れ防止を担保する3本（三脚の原理）
rib_dia = 4.0;         // リブの太さ（丸み）
rib_protrusion = 1.0;  // 表面からの出っ張り量

$fn = 200; 

module subtle_rib_tube() {
    difference() {
        union() {
            // 1. 外側の円柱
            cylinder(h = tube_length, d = tube_outer_dia);
            
            // 丸リブ（3本）
            for (i = [0 : rib_count - 1]) {
                rotate([0, 0, i * (360 / rib_count)])
                    // 管の中心側にリブを押し込み、1mmだけ頭を出す計算式
                    translate([(tube_outer_dia / 2) - (rib_dia / 2) + rib_protrusion, 0, 0])
                        cylinder(h = tube_length, d = rib_dia, $fn = 60);
            }
        }
        
        // 2. 内側のくり抜き（貫通して真っ直ぐな管）
        translate([0, 0, -1])
            cylinder(h = tube_length + 2, d = actual_inner_dia);
    }
}

// 煙突のように立ててプリント
subtle_rib_tube();