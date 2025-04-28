// -----------------------------------------------------------------------------
// brother_robot_complete_with_hinges.scad
// “BROTHER ROBOT” full prototype  (v1.2)
//  part = "assembly" で全体、他は hip_bracket / upper_leg … など個別 STL
// -----------------------------------------------------------------------------
part = "assembly";

// ───────── 共通パラメータ ─────────
wall        = 2.2;
screw_clear = 0.3;
m2   = 2   + screw_clear;
m25  = 2.5 + screw_clear;

// サーボ寸法
xl330      = [20,34,27];
xl330_hole = [16,27, 3.5];
_2xl430      = [34,46.5,34];
_2xl430_hole = [28,40, 5.0];

// 全体寸法
hip_spacing = 80;
upper_len   = 120;
lower_len   = 110;
foot_w      = 50;
foot_d      = 40;
foot_t      = 6;

// ───────── 汎用ユーティリティ ─────────
module fillet_cube(v,r=1){
  translate([r,r,r]) minkowski(){
    cube([v[0]-2*r,v[1]-2*r,v[2]-2*r]);
    sphere(r,$fn=24);
  }
}
module screw_hole(d,h){
  translate([0,0,-0.1]) cylinder(h+0.2,d=d,$fn=24);
}

// ───────── ヒンジ耳＋穴 ─────────
module hinge(pin_r=2,clr=0.5,ear=6,len=20){
  difference(){
    union(){
      translate([-len,0,0]) cube([ear,len,ear]);
      translate([ len-ear,0,0]) cube([ear,len,ear]);
    }
    translate([-len+ear/2,len/2,ear/2])
      rotate([90,0,0]) cylinder(h=ear+1,d=2*pin_r+clr,$fn=24);
    translate([ len-ear/2,len/2,ear/2])
      rotate([90,0,0]) cylinder(h=ear+1,d=2*pin_r+clr,$fn=24);
  }
}

// ───────── サーボマウント ─────────
module servo_mount(size,hole_xy,hole_z,hole_d){
  difference(){
    fillet_cube([size[0]+2*wall,size[1]+2*wall,size[2]+2*wall],1);
    translate([wall,wall,wall]) cube(size);
    for(sx=[-1,1],sy=[-1,1])
      translate([wall+size[0]/2+sx*hole_xy[0]/2,
                 wall+size[1]/2+sy*hole_xy[1]/2,
                 hole_z])
        screw_hole(hole_d,size[2]+2*wall);
  }
}

// ───────── 個別パーツ ─────────
module hip_bracket(){
  servo_mount(_2xl430,_2xl430_hole,_2xl430_hole[2],m25);
  translate([0,_2xl430[1]+2*wall,_2xl430[2]/2])
    rotate([90,0,0]) cylinder(h=_2xl430[1]/2,d=8,$fn=24);
}

module upper_leg(){
  difference(){
    fillet_cube([wall*2+16,wall*2+16,upper_len],1);
    translate([wall+4,wall+4,wall]) cube([8,8,upper_len-2*wall]);
  }
}
module lower_leg(){
  difference(){
    fillet_cube([wall*2+16,wall*2+16,lower_len],1);
    translate([wall+4,wall+4,wall]) cube([8,8,lower_len-2*wall]);
  }
}
module foot_plate(){
  fillet_cube([foot_w,foot_d,foot_t],1);
  for(sx=[-1,1],sy=[-1,1])
    translate([foot_w/2+sx*foot_w/3,foot_d/2+sy*foot_d/3,0])
      screw_hole(m2,foot_t);
}
module waist_frame(){
  box=[60,30,80];
  difference(){
    fillet_cube([box[0]+2*wall,box[1]+2*wall,box[2]+2*wall],2);
    translate([wall,wall,wall]) cube(box);
    translate([box[0]/2,0,box[2]/2]) rotate([0,90,0])
      cube([box[1],5,box[2]]);
  }
}

// ───────── 全体アセンブリ ─────────
module assembly(){
  translate([0,0,lower_len+upper_len]) waist_frame();
  for(s=[-1,1]){
    // hip
    translate([s*hip_spacing/2,0,lower_len+upper_len-wall]){
      hinge(); hip_bracket();
    }
    // upper leg
    translate([s*hip_spacing/2+s*(_2xl430[0]-wall),0,lower_len]){
      upper_leg(); hinge();
    }
    // knee servo
    translate([s*hip_spacing/2+s*(_2xl430[0]-wall),0,lower_len-0.1])
      servo_mount(xl330,xl330_hole,xl330_hole[2],m2);
    // lower leg
    translate([s*hip_spacing/2+s*(_2xl430[0]-wall),0,0]){
      lower_leg(); hinge();
    }
    // ankle servo
    translate([s*hip_spacing/2+s*(_2xl430[0]-wall),0,-0.1])
      servo_mount(xl330,xl330_hole,xl330_hole[2],m2);
    // foot
    translate([s*hip_spacing/2+s*(_2xl430[0]-wall),0,-foot_t]) foot_plate();
  }
}

// ───────── Dispatcher ─────────
if(part=="assembly")               assembly();
else if(part=="hip_bracket")       hip_bracket();
else if(part=="upper_leg")         upper_leg();
else if(part=="lower_leg")         lower_leg();
else if(part=="foot_plate")        foot_plate();
else if(part=="waist_frame")       waist_frame();
else echo("invalid part=",part);
