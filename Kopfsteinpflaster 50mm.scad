difference() {
scale([0.5,0.5,0.5]) {    
translate([0,0,30])
    import("/home/oliwel/workspace/MoBaPrint/cobblestone_roller.stl");
translate([0,0,-60]) 
   import("/home/oliwel/workspace/MoBaPrint/cobblestone_roller.stl");
}
translate([0,0,-60]) cube([50,50,60]);
}