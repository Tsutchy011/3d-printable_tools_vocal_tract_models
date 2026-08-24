// --- リード式音源 リード固定部分 ---

// "CASE"   : 本体のみ出力
// "SLEEVE" : スリーブ（鞘）のみ出力
// "BOTH"   : 両方並べて出力（デフォルト）
render_target = "BOTH"; 

// サポート材なしで印刷するため、出力時は true にしてください。
print_ready_orientation = true; 

// === 寸法・クリアランス設定 ===
clearance = 0.25;      // スリーブと本体の隙間
lock_bump = 0.5;       // ロック用突起の大きさ

reed_w = 10.0;         // リード幅
reed_l = 30.0;         // リード長さ

internal_clearance_w = 0.6; 
internal_clearance_l = 0.8; 
storage_depth = 4.0;        

wall_t = 1.6;          // 外壁の厚み
ejector_w = 8.0;       

// [内部計算寸法]
box_in_w = reed_w + internal_clearance_w;
box_in_l = reed_l + internal_clearance_l;
box_out_w = box_in_w + wall_t * 2;
box_out_l = box_in_l + wall_t * 2;
box_out_h = storage_depth + wall_t * 2;

$fn = 120; // 楕円や円柱を滑らかにするため高精度化

// ==========================================
// パーツ1: 本体カートリッジ（中箱）
// ==========================================
module reed_storage_case() {
    difference() {
        union() {
            // メインボディ
            cube([box_out_w, box_out_l, box_out_h]);
            
            // スリーブ固定用のクリック突起（左右の奥側）
            translate([0, box_out_l - 5, box_out_h/2])
                sphere(r=lock_bump);
            translate([box_out_w, box_out_l - 5, box_out_h/2])
                sphere(r=lock_bump);
        }
        
        // 内部の収納空洞
        translate([wall_t, -0.1, wall_t])
            cube([box_in_w, box_in_l + wall_t + 0.1, storage_depth]);
            
        // 💡 【修正完了】親指スライド用の幅広長穴（スロット）
        // 四角い穴を廃止し、指の形に馴染む丸型を2つ繋げた滑らかな長穴にしました。
        translate([0, 0, box_out_h - wall_t - 0.1]) {
            hull() {
                // 手前側の丸み
                translate([box_out_w/2, wall_t + 6, 0])
                    cylinder(h=wall_t + 0.2, d=ejector_w);
                // 奥側（スタート地点）の丸み
                translate([box_out_w/2, box_out_l - wall_t - 6, 0])
                    cylinder(h=wall_t + 0.2, d=ejector_w);
            }
        }
            
        // 最後の1枚まで押し出すための傾斜スロープ
        translate([wall_t - 0.1, wall_t, wall_t - 0.1])
            rotate([3, 0, 0])
                cube([box_in_w + 0.2, box_in_l, storage_depth]);
    }
}

// ==========================================
// パーツ2: 保護スリーブ（鞘）
// ==========================================
module reed_storage_sleeve() {
    out_w = box_out_w + clearance*2 + wall_t*2;
    out_l = box_out_l + clearance + wall_t; 
    out_h = box_out_h + clearance*2 + wall_t*2;

    difference() {
        // スリーブ外殻
        translate([-clearance - wall_t, -wall_t, -clearance - wall_t])
            cube([out_w, out_l, out_h]);

        // カートリッジを挿入する空洞
        translate([-clearance, 0, -clearance])
            cube([box_out_w + clearance*2, box_out_l + 2, box_out_h + clearance*2]);

        // クリック突起を受け止める凹み
        translate([-clearance, box_out_l - 5, box_out_h/2])
            sphere(r=lock_bump + 0.2); 
        translate([box_out_w + clearance, box_out_l - 5, box_out_h/2])
            sphere(r=lock_bump + 0.2);

        // 本物の「U字切り欠き」（後方の上下）
        translate([box_out_w/2, box_out_l + clearance, box_out_h/2])
            cylinder(h=box_out_h * 3, d=13.0, center=true);
    }
}

// ==========================================
// 印刷用の姿勢への配置
// ==========================================
// X軸まわりに 180° 回して天地を返し、造形面 (z = 0) にぴったり接地させます。
// 回転させただけだと造形面より下に潜るため、パーツごとの高さ・奥行きの分だけ
// translate で戻しているのがポイントです。

module place_case() {
    // 本体は z = 0 〜 box_out_h、y = 0 〜 box_out_l の範囲にある
    translate([0, box_out_l, box_out_h])
        rotate([180, 0, 0])
            reed_storage_case();
}

module place_sleeve() {
    // スリーブは本体より (clearance + wall_t) だけ外側に張り出している
    translate([0, box_out_l + clearance, box_out_h + clearance + wall_t])
        rotate([180, 0, 0])
            reed_storage_sleeve();
}

// --- 描画処理 ---
if (print_ready_orientation) {
    if (render_target == "CASE") {
        place_case();
    } else if (render_target == "SLEEVE") {
        place_sleeve();
    } else {
        // 並べて印刷
        place_case();
        translate([box_out_w + 10, 0, 0])
            place_sleeve();
    }
} else {
    // 組み立てプレビュー（スリーブに半分差し込んだ状態）
    reed_storage_case();
    translate([0, 15, 0]) 
        %reed_storage_sleeve(); 
}