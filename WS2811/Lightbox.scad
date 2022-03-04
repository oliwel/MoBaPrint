/* Konstanten für Kastenformat */
OPEN_NONE = 0; // Box mit fünf Seiten
OPEN_LEFT = -1; // Box mit vier Seite, vorne und links offen
OPEN_RIGHT = 1; // Box mit vier Seite, vorne und rechts offen

/* Position für das LED Loch */
LED_TOP = 0; // "oben"
LED_BACK = 1; // Rückwand
LED_TUNNEL = 2; // keine
LED_CABLEIN = 3; // keine
LED_3MM = 4;
LED_NONE = 5; // keine

/* LED Größen */
LED_5050 = [5.5,5.5]; // Die Standard WS2812 LEDs
LED_3528 = [4.0,3.0];
LED_1206 = [3.5,2];
LED_DEFAULT = LED_5050;

/* Wandstärke */
wall = 0.6;
tunnel_height = 2;
/*
 * width/height = Abmessungen des "Fensters" (Außenmass)
 * depth = Tiefe der Kiste
 * open = Kiste mit zwei offenen Seiten für Über-Eck Einbau
 * led = Position der LED
 * led_offset = Abweichung der LED Position von der Mitte
 *    Zahl > 1: Offset in Einheiten von der Mitte aus
 *    Zahl < 1: relative Position auf der Wand von links außen gemessen
*/
module lightbox( width = 20, height = 25, depth = 15, open = OPEN_NONE, led = LED_BACK, led_offset = 0.5, led_size = LED_DEFAULT ) {
    shrink = (open != OPEN_NONE ? wall : (2*wall));
    move = open * wall;
    led_move = (abs(led_offset) < 1 ? ((led_offset * width) - (0.5 * width)) : led_offset);
    //tunnel_length = 5; //(height+led_size[1])/2;
    //tunnel_width = led_size[0]+2;
    translate([0,0,depth/2])
    difference(){
        cube([width,height,depth],true);        
        translate([move,0,wall]) cube([width-shrink,height-2*wall,depth],true);
        // Loch mit 1.2 wall Höhe um Rendering Fehler zu unterdrücken
        if (led == LED_TOP) {
            translate([led_move, height/2-(0.5*wall),0]) cube([led_size[0],1.2*wall,led_size[1]],true);
        } else if (led == LED_BACK) {
            translate([led_move ,0,-depth/2+(0.5*wall)]) cube([led_size[0],led_size[1],1.2*wall],true);
        } else if (led == LED_TUNNEL) {
            //translate([0, height/2,(-depth+tunnel_height)/2 + wall]) cube([tunnel_width, 2*wall, tunnel_height],true);
        } else if (led == LED_CABLEIN) {
            cutoff_width = ((len(led_size) == undef) ? led_size : 5);
            translate([led_move, height/2, -depth/2+wall+1]) cube([cutoff_width, 2*wall, 2],true);
        } else if (led == LED_3MM) {
            translate([led_move ,0,-depth/2+(0.5*wall)]) cylinder(d=3, h=2*wall, center=true, $fn=20);
        }   
    }
    /*if (led == LED_TUNNEL) {
        color([1,0,0])
        translate([led_move - tunnel_width/2 - wall, -led_size[1]/2-wall ,-depth/2+wall])
        difference(){
            cube([tunnel_width+2*wall, tunnel_length+wall , tunnel_height + wall]);
            translate([wall,wall,0]) cube([tunnel_width, tunnel_length, tunnel_height]);
            translate([(tunnel_width-led_size[0])/2+wall, wall, tunnel_height]) cube([led_size[0],led_size[1],wall]);
        }
    }*/
    if (led == LED_3MM) {        
        translate([led_move ,0,wall]) 
        difference(){
            cylinder(d=5, h=2*wall,center=true, $fn=20);
            cylinder(d=3, h=2*wall, center=true, $fn=20);
        }
    }    
}

/*
translate([50,0,0])
difference(){
    lightbox( width = 39, height = 25, depth = 15, led = LED_CABLEIN, led_size = LED_3528);
    translate([0,2.5-wall,10])cube([45,20,10],true);
}

union(){
    difference(){
        lightbox( width = 39, height = 25, depth = 15, led = LED_CABLEIN, led_size = 12);
        translate([0,2.5-wall,10])cube([45,20,10],true);
    }
    translate([0,0,7.5])cube([wall,25,15],true);
}*/

lightbox( width = 12, height = 14, depth = 12, led = LED_CABLEIN, led_offset=0.5, led_size = LED_5050);
translate([20,0,0]) lightbox( width = 12, height = 14, depth = 12, led = LED_CABLEIN, led_offset=0.5, led_size = LED_5050);