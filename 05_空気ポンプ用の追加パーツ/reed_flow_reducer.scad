// --- 3Dプリント用  リード式音源 直結型 気流減衰アダプタ ---

// ★出力するパーツを選んでください★
render_target = "ADAPTER";   // "ADAPTER"（本体）/ "GAUGE"（試し嵌め用・プラグのみ）/ "PINS" / "ALL"

show_cross_section = false;
add_labels  = true;
add_grooves = true;        // テーパー上の目盛り溝

$fn = 120;

// ============================================================
//  ★★ ポンプ側テーパープラグ ★★
// ============================================================
pump_d_small  = 16.5;   // 先端（細い側）
pump_d_large  = 20.8;   // 根元（太い側）
pump_plug_len = 15.0;
pump_tip_ch   = 0.5;
groove_dia    = [18.0, 19.0, 20.0];   // 目盛り溝を入れる径
groove_depth  = 0.25;
groove_w      = 0.6;

// ============================================================
//  ★★ 音源カプセル側プラグ（フランジ突き当て式）★★
// ============================================================
reed_fit      = -0.40;  // 直径方向。きつければさらに -0.05 ずつ
capsule_bore  = 12.8;
flange_dia    = 18.0;
flange_h      = 1.5;
reed_plug_len = 3.0;
reed_tip_ch   = 0.4;

// ---- 流路径 ----
bore_dia     = 7.0;
inlet_throat = 7.0;   // 強すぎたら 4.0（従来のφ4チューブ相当）へ

// ---- 本体 ----
body_dia    = 30.0;
chamber_dia = 20.0;
chamber_h   = 24.0;
funnel_h    = 8.0;

// ---- ブリード孔（3.14 / 5.31 / 9.08 mm2、合計 17.5 mm2）----
bleed_d     = [2.0, 2.6, 3.4];
bleed_z     = 30.0;
bleed_angle = 45;
label_z     = 25.0;

// ---- 栓ピン ----
pin_len   = 6.0;
pin_clear = 0.08;

// ============================================================
//  導出値
// ============================================================
pump_slope   = (pump_d_large - pump_d_small) / pump_plug_len;
reed_d_root  = capsule_bore + 0.2 + reed_fit;
reed_d_tip   = capsule_bore - 0.2 + reed_fit;
reed_pre_ch  = reed_d_root - (reed_d_root - reed_d_tip) * (reed_plug_len - reed_tip_ch) / reed_plug_len;

inlet_cone_h = (chamber_dia - inlet_throat) / 2;
pump_cone_h  = (body_dia - pump_d_large) / 2 * 1.6;
z_cham_bot   = pump_plug_len + inlet_cone_h;
z_cham_top   = z_cham_bot + chamber_h;
z_slot       = z_cham_top + funnel_h;
z_flange_bot = z_slot - flange_h;
shoulder_h   = (body_dia - flange_dia) / 2;
z_shoulder   = z_flange_bot - shoulder_h;
z_tip        = z_slot + reed_plug_len;

function z_of_dia(d) = (d - pump_d_small) / pump_slope;

// ============================================================
//  プラグ（本体・ゲージ共通）
// ============================================================
module pump_plug() {
    d_ch = pump_d_small + pump_slope * pump_tip_ch;
    difference() {
        union() {
            cylinder(h = pump_tip_ch, d1 = pump_d_small - 2 * pump_tip_ch, d2 = d_ch);
            translate([0, 0, pump_tip_ch])
                cylinder(h = pump_plug_len - pump_tip_ch, d1 = d_ch, d2 = pump_d_large);
        }
        if (add_grooves)
            for (d = groove_dia)
                translate([0, 0, z_of_dia(d) - groove_w / 2])
                    difference() {
                        cylinder(h = groove_w, d = pump_d_large + 2);
                        cylinder(h = groove_w, d = d - 2 * groove_depth);
                    }
    }
}

module reed_plug() {   // z=0 がフランジ上面
    cylinder(h = reed_plug_len - reed_tip_ch, d1 = reed_d_root, d2 = reed_pre_ch);
    translate([0, 0, reed_plug_len - reed_tip_ch])
        cylinder(h = reed_tip_ch, d1 = reed_pre_ch, d2 = reed_pre_ch - 2 * reed_tip_ch);
}

module bleed_cut(d) {
    translate([chamber_dia / 2 - 1.5, 0, bleed_z])
        rotate([0, bleed_angle, 0])
            translate([0, 0, -1.5])
                cylinder(h = 18, d = d);
}

module wall_label(txt, ang) {
    rotate([0, 0, ang + 90])
        translate([0, -(body_dia / 2 - 0.8), label_z])
            rotate([90, 0, 0])
                linear_extrude(1.2)
                    text(txt, size = 6, halign = "center", valign = "center",
                         font = "Liberation Sans:style=Bold");
}

// ============================================================
//  パーツ1：アダプタ本体
// ============================================================
module adapter() {
    difference() {
        union() {
            pump_plug();
            translate([0, 0, pump_plug_len])
                cylinder(h = pump_cone_h, d1 = pump_d_large, d2 = body_dia);
            translate([0, 0, pump_plug_len + pump_cone_h])
                cylinder(h = z_shoulder - pump_plug_len - pump_cone_h, d = body_dia);
            translate([0, 0, z_shoulder])
                cylinder(h = shoulder_h, d1 = body_dia, d2 = flange_dia);
            translate([0, 0, z_flange_bot]) cylinder(h = flange_h, d = flange_dia);
            translate([0, 0, z_slot]) reed_plug();
        }
        translate([0, 0, -0.01]) cylinder(h = pump_plug_len + 0.02, d = inlet_throat);
        translate([0, 0, pump_plug_len - 0.01])
            cylinder(h = inlet_cone_h + 0.02, d1 = inlet_throat, d2 = chamber_dia);
        translate([0, 0, z_cham_bot - 0.01]) cylinder(h = chamber_h + 0.02, d = chamber_dia);
        translate([0, 0, z_cham_top - 0.01])
            cylinder(h = funnel_h + 0.02, d1 = chamber_dia, d2 = bore_dia);
        translate([0, 0, z_slot - 0.01]) cylinder(h = reed_plug_len + 1, d = bore_dia);
        for (i = [0:len(bleed_d) - 1]) rotate([0, 0, 120 * i]) bleed_cut(bleed_d[i]);
        if (add_labels) for (i = [0:len(bleed_d) - 1]) wall_label(str(i + 1), 120 * i);
    }
}

// ============================================================
//  パーツ2：試し嵌めゲージ（両プラグのみ）
// ============================================================
module fit_gauge() {
    g_collar = 3.0;
    g_z1 = pump_plug_len + pump_cone_h;
    g_z2 = g_z1 + g_collar;
    g_z3 = g_z2 + shoulder_h;
    difference() {
        union() {
            pump_plug();
            translate([0, 0, pump_plug_len])
                cylinder(h = pump_cone_h, d1 = pump_d_large, d2 = body_dia);
            translate([0, 0, g_z1]) cylinder(h = g_collar, d = body_dia);
            translate([0, 0, g_z2]) cylinder(h = shoulder_h, d1 = body_dia, d2 = flange_dia);
            translate([0, 0, g_z3]) cylinder(h = flange_h, d = flange_dia);
            translate([0, 0, g_z3 + flange_h]) reed_plug();
        }
        translate([0, 0, -0.01]) cylinder(h = g_z3 + flange_h + reed_plug_len + 1, d = bore_dia);
        rotate([0, 0, 90]) translate([0, -(body_dia / 2 - 0.8), g_z1 + g_collar / 2])
            rotate([90, 0, 0]) linear_extrude(1.2)
                text(str("T", reed_fit), size = 3.4, halign = "center", valign = "center");
    }
}

// ============================================================
//  パーツ3：ブリード孔の栓ピン（3本組）
// ============================================================
module bleed_pin(d, num) {
    head_d = d + 6;
    head_h = 3.5;
    difference() {
        union() {
            cylinder(h = head_h, d = head_d);
            translate([0, 0, head_h])
                cylinder(h = pin_len, d1 = d - pin_clear, d2 = d - 0.5);
        }
        for (a = [0:60:359])
            rotate([0, 0, a]) translate([head_d / 2, 0, -0.5])
                cylinder(h = head_h + 1, d = 1.6, $fn = 20);
        translate([0, 0, -0.01]) linear_extrude(0.6)
            mirror([1, 0, 0])
                text(num, size = 4, halign = "center", valign = "center",
                     font = "Liberation Sans:style=Bold");
    }
}

module bleed_pin_set() {
    for (i = [0:len(bleed_d) - 1]) translate([i * 14, 0, 0]) bleed_pin(bleed_d[i], str(i + 1));
}

// ============================================================
//  描画
// ============================================================
module render_all_parts() {
    if (render_target == "ADAPTER")    adapter();
    else if (render_target == "GAUGE") fit_gauge();
    else if (render_target == "PINS")  bleed_pin_set();
    else if (render_target == "ALL") {
        adapter();
        translate([42, -20, 0]) bleed_pin_set();
        translate([42,  22, 0]) fit_gauge();
    }
}

echo(str("ポンプ側テーパー φ", pump_d_small, " → φ", pump_d_large, " / 長さ ", pump_plug_len, "mm"));
echo(str("  受け内径18.0で 差し込み ", z_of_dia(18.0), "mm / 19.0で ", z_of_dia(19.0),
         "mm / 20.0で ", z_of_dia(20.0), "mm"));
echo(str("音源側プラグ 先端 φ", reed_d_tip, " → 根元 φ", reed_d_root, "（受け φ", capsule_bore, "）"));

if (show_cross_section) {
    difference() {
        render_all_parts();
        translate([-80, 0, -10]) cube([160, 160, 160]);
    }
} else {
    render_all_parts();
}
