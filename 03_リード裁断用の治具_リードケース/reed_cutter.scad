// --- 3Dプリント用 リード裁断用の治具 ---

// "ALL"         : 全4パーツを重ならずにフラット配置（一括印刷用）
// "TOOL1"       : Tool 1（9.4mm短冊メーカー）のみ表示
// "TOOL2"       : Tool 2（30mmチョッパー）のみ表示
// "STRIP_BASE", "STRIP_TOP", "CHOP_BASE", "CHOP_TOP" : 各単体出力用
render_target = "ALL";

// [寸法パラメーター]
reed_w = 9.4;          // 仕上がり幅（クリアランス確保）
reed_l = 30.0;         // 仕上がり長さ（正確に30.0mmカット）
wall_w = 10.0;         // 壁の厚み（10.0mm）

// [遊び・クリアランス設定]
pin_d1 = 4.0;          // ピン根本
pin_d2 = 2.8;          // ピン先端（テーパー）
hole_d = 5.2;          // 穴の太さ（1.2mmの遊び）

base_h = 4.0;          // ベースの厚み
wall_h = 0.40;         // 壁の高さ（0.3mmシートをしっかりホールド）
top_h = 5.0;           // トップの厚み

$fn = 60;

// ==========================================
// 【Tool 1】 9.4mm 短冊メーカー
// ==========================================
s_bed_w = 40;  
s_bed_l = 195; 

module strip_base_v() {
    difference() {
        union() {
            cube([s_bed_w, s_bed_l, base_h]);
            translate([0, 0, base_h]) cube([wall_w, s_bed_l, wall_h]);
            translate([wall_w, s_bed_l - wall_w, base_h]) cube([reed_w, wall_w, wall_h]);
                
            _pz = base_h + wall_h;
            translate([wall_w/2, 10, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
            translate([wall_w/2, s_bed_l - 20, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
            translate([wall_w + reed_w/2, s_bed_l - wall_w/2, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
        }
    }
}

module strip_top_v() {
    difference() {
        union() {
            cube([wall_w + reed_w, s_bed_l, top_h]);
            translate([-10, s_bed_l/2 - 10, 0]) cube([10, 20, top_h]);
        }
        translate([-0.1, -0.1, -0.1]) cube([wall_w + 0.2, s_bed_l + 0.2, wall_h + 0.2]); 
        translate([wall_w - 0.1, s_bed_l - wall_w - 0.1, -0.1]) cube([reed_w + 0.2, wall_w + 0.2, wall_h + 0.2]); 

        translate([wall_w/2, 10, -1]) cylinder(h=top_h+2, d=hole_d);
        translate([wall_w/2, s_bed_l - 20, -1]) cylinder(h=top_h+2, d=hole_d);
        translate([wall_w + reed_w/2, s_bed_l - wall_w/2, -1]) cylinder(h=top_h+2, d=hole_d);
    }
}

// ==========================================
// 【Tool 2】 30mm チョッパー
// ==========================================
track_w = reed_w + 0.2;     
c_w = wall_w + track_w + wall_w; 
c_front = 40;               
c_back = reed_l;            

module chop_base_v() {
    difference() {
        union() {
            translate([0, -c_front, 0]) cube([c_w, c_front + c_back + 10, base_h]);
            translate([0, -c_front, base_h]) cube([wall_w, c_front + c_back, wall_h]);
            translate([wall_w + track_w, -c_front, base_h]) cube([wall_w, c_front + c_back, wall_h]);
            
            translate([0, reed_l, base_h]) cube([c_w, 10, wall_h]);

            _pz = base_h + wall_h;
            translate([wall_w/2, 5, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
            translate([c_w - wall_w/2, 5, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
            translate([wall_w/2, reed_l - 5, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
            translate([c_w - wall_w/2, reed_l - 5, _pz]) cylinder(h=top_h, d1=pin_d1, d2=pin_d2); 
        }
    }
}

module chop_top_v() {
    difference() {
        union() {
            cube([c_w, c_back, top_h]);
            // 右側の取っ手
            translate([c_w, 5, 0]) cube([10, 15, top_h]);
        }

        translate([-0.1, -0.1, -0.1]) cube([wall_w + 0.2, c_back + 0.2, wall_h + 0.2]); 
        translate([wall_w + track_w - 0.1, -0.1, -0.1]) cube([wall_w + 0.2, c_back + 0.2, wall_h + 0.2]); 

        // 穴
        translate([wall_w/2, 5, -1]) cylinder(h=top_h+2, d=hole_d);
        translate([c_w - wall_w/2, 5, -1]) cylinder(h=top_h+2, d=hole_d);
        translate([wall_w/2, reed_l - 5, -1]) cylinder(h=top_h+2, d=hole_d);
        translate([c_w - wall_w/2, reed_l - 5, -1]) cylinder(h=top_h+2, d=hole_d);
    }
}

// --- 印刷用・条件分岐レイアウト処理 ---
if (render_target == "STRIP_BASE") {
    translate([0, 0, 0]) strip_base_v();
} else if (render_target == "STRIP_TOP") {
    translate([0, s_bed_l, top_h]) rotate([180, 0, 0]) strip_top_v();
} else if (render_target == "CHOP_BASE") {
    translate([0, c_front, 0]) chop_base_v();
} else if (render_target == "CHOP_TOP") {
    translate([0, c_back, top_h]) rotate([180, 0, 0]) chop_top_v();
} else if (render_target == "TOOL1") {
    strip_base_v();
    translate([50, s_bed_l, top_h]) rotate([180, 0, 0]) strip_top_v();
} else if (render_target == "TOOL2") {
    translate([0, c_front, 0]) chop_base_v();
    translate([40, c_back, top_h]) rotate([180, 0, 0]) chop_top_v();
} else {
    // ALL: 4パーツが一括印刷できる最適化フラット配置
    translate([0, 0, 0]) 
        strip_base_v();
        
    translate([70, s_bed_l, top_h]) 
        rotate([180, 0, 0]) 
        strip_top_v();
        
    translate([110, c_front, 0]) 
        chop_base_v();
        
    translate([150, c_back, top_h]) 
        rotate([180, 0, 0]) 
        chop_top_v();
}