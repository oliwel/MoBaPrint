garageY=46.5+10/12;
garageH=10;
transom=false;

Xexplode=0; // set to 1 or more to space out the layers in the X direction for an exploded view
Zexplode=0; // set to 1 or more to space out the layers in the Z direction for an exploded view
print=0; // which layer to print:
// 0: all
// 1: was N dirt
// 2: dirt
// 3: basement
// 4: 1st floor
// 5: 2nd floor
// 6: roof
// 7: garage
// 8: garage roof
// 9: whatever

position = (print>0) ? 2 : 1; // position of the sliding doors, 1=closed, 2=open, 3=across foyer

// scale in feet per inch
ftperinch=10;
floorT= 12/12;

color1 = "tan";
color2 = [85,107,.75*47]*.75/255; //"darkolivegreen";
carpetcolor = "beige";
interiorwallcolor = "bisque";
woodcolor = "saddlebrown";
vinylcolor = "burlywood";
hearthcolor = [60/255,60/255,0,1];

module EWwall(x0,y0,l,h=9,t=4,z0=floorT) {
	color(interiorwallcolor) mirror() translate([x0,y0,z0]) cube([l,t/12,h]);
}

module NSwall(x0,y0,l,t=4,h=9,z0=floorT) {
	mirror() {
		color(interiorwallcolor) translate([x0,y0,z0]) cube([t/12,l,h]);
		if (h<4) color(woodcolor) translate([x0-.5/12,y0,z0+h]) cube([(t+1)/12,l,1/12]);
	}
}

module EWdoor(x0,y0,w=32,h=7,z0=floorT,t=4) {
	color(woodcolor) mirror() {
		translate([x0-w/2/12,y0-2/12,z0]) cube([w/12,(t+2)/24,h]);
		translate([x0-w/2/12,y0+(t+2)/24,z0]) cube([w/12,(t+2)/24,h]);
	}
}

module NSdoor(x0,y0,w=32,h=7,z0=floorT,t=4) {
	color(woodcolor) mirror() {
		translate([x0-2/12,y0-w/2/12,z0]) cube([(t+2)/24,w/12,h]);
		translate([x0+(t+2)/24,y0-w/2/12,z0]) cube([(t+2)/24,w/12,h]);
	}
}

module NSdoortrim(x0,y0,w=32,h=7,z0=floorT,t=4) {
	color(woodcolor) mirror() {
		translate([x0+(t-.01)/12,y0-(w/2+4)/12,z0]) cube([1.01/12,(w+8)/12,h+4/12]); // outside
		translate([x0-1/12,y0-(w/2+4)/12,z0]) cube([1.01/12,(w+8)/12,h+4/12]); // inside
	}
}

module EWdoortrim(x0,y0,w=32,h=7,z0=floorT,t=4) {
	color(woodcolor) mirror() {
		translate([x0-(w/2+4)/12,y0-1/12,z0]) cube([(w+8)/12,1.01/12,h+4/12]); // outside
		translate([x0-(w/2+4)/12,y0+(t-.01)/12,z0]) cube([(w+8)/12,1.01/12,h+4/12]); // inside
	}
}


module EWwindow(x0=0,y0=0,z0=32,w=26,h=50) {
	color("white") mirror() {
		translate([x0-w/2/12,y0-2/12,floorT+z0/12]) cube([w/12,3.75/12,h/12]);
		translate([x0-w/2/12,y0+4/12,floorT+z0/12]) cube([w/12,3.75/12,h/12]);
		translate([x0-w/2/12,y0,floorT+z0/12]) cube([w/12,5/12,(h/2-1)/12]);
		translate([x0-w/2/12,y0,floorT+z0/12+(h/2+1)/12]) cube([w/12,5/12,(h/2-1)/12]);
	}
}

module NSwindow(x0=0,y0=0,z0=32,w=26,h=50) {
	color("white") mirror() {
		translate([x0-2/12,y0-w/2/12,floorT+z0/12]) cube([3.75/12,w/12,h/12]);
		translate([x0+4/12,y0-w/2/12,floorT+z0/12]) cube([3.75/12,w/12,h/12]);
		translate([x0,y0-w/2/12,floorT+z0/12]) cube([5/12,w/12,(h/2-1)/12]);
		translate([x0,y0-w/2/12,floorT+z0/12+(h/2+1)/12]) cube([5/12,w/12,(h/2-1)/12]);
	}
}


module Ewindowtrim(x0=0,y0=0,z0=32,w=26,h=50) {
	mirror() translate([x0,y0,floorT+z0/12]) {
		color("white") translate([-1/12,-(w/2+4)/12,-4/12]) cube([1.01/12,(w+8)/12,(h+4)/12]); // outside bottom&sides
		color("white") translate([-1/12,-(w/2+8)/12,h/12]) cube([1.01/12,(w+16)/12,4/12]); // top
		if (print>0) color(woodcolor) translate([5.99/12,(-(w/2+2)-2)/12,-4/12]) 
				cube([1.01/12,(w+8)/12,(h+8)/12]); // inside 
	}
}


module Wwindowtrim(x0=0,y0=0,z0=32,w=26,h=50) {
	mirror() translate([x0,y0,floorT+z0/12]) {
		color("white") translate([5.99/12,-(w/2+4)/12,-4/12]) cube([1.01/12,(w+8)/12,(h+4)/12]); // outside bottom&sides
		color("white") translate([5.99/12,-(w/2+8)/12,h/12]) cube([1.01/12,(w+16)/12,4/12]); // top
		if (print>0) color(woodcolor) translate([-1/12,(-(w/2+2)-2)/12,-4/12]) 
				cube([1.01/12,(w+8)/12,(h+8)/12]); // inside 
	}
}


module Swindowtrim(x0=0,y0=0,z0=32,w=26,h=50) {
	mirror() translate([x0,y0,floorT+z0/12]) {
		color("white") translate([-(w/2+4)/12,-1/12,-4/12]) cube([(w+8)/12,1.01/12,(h+4)/12]); // outside bottom&sides
		color("white") translate([-(w/2+8)/12,-1/12,h/12]) cube([(w+16)/12,1.01/12,4/12]); // top
		if (print>0) color(woodcolor) translate([(-(w/2+2)-2)/12,5.99/12,-4/12]) 
				cube([(w+8)/12,1.01/12,(h+8)/12]); // inside 
	}
}


module Nwindowtrim(x0=0,y0=0,z0=32,w=26,h=50) {
	mirror() translate([x0,y0,floorT+z0/12]) {
		color("white") translate([-(w/2+4)/12,5.99/12,-4/12]) cube([(w+8)/12,1.01/12,(h+4)/12]); // outside bottom&sides
		color("white") translate([-(w/2+8)/12,5.99/12,h/12]) cube([(w+16)/12,1.01/12,4/12]); // top
		if (print>0) color(woodcolor) translate([(-(w/2+2)-2)/12,-1/12,-4/12]) 
				cube([(w+8)/12,1.01/12,(h+8)/12]); // inside 
	}
}


module EWpicturewindow(x0=0,y0=0,z0=32,w=36,h=50) {
	color("white") mirror() translate([x0-w/2/12,y0-.125,floorT+z0/12]) cube([w/12,1,h/12]);
}

module NSpicturewindow(x0=0,y0=0,z0=32,w=36,h=50) {
	color("white") mirror() translate([x0-.125,y0-w/2/12,floorT+z0/12]) cube([1,w/12,h/12]);
}

module shell1() {
	difference() { 
		union() {
			difference() {
				color(color1) union() {
					EWwall(0,0,27+4/12,t=7);
					EWwall(0,40-7/12,1+6/12,t=7);
					EWwall(13+8/12-7/12,40-7/12,13+8/12,t=7);
					NSwall(0,0,40,t=7);
					NSwall(27+4/12-7/12,0,40,t=7);
					NSwall(1,40,garageY-46.5+7+2/12,t=7,h=8);
					NSwall(13+8/12-7/12,40,garageY-46.5+10+6/12,t=7,h=8);
				}
				color(interiorwallcolor) mirror() translate([.5,.5,0]) cube([26+4/12,39,11]);
				color(interiorwallcolor) mirror() translate([1.5,39+5/12,0]) cube([11+8/12,12,10]);
			}
			for(i=[4,12,28,36]) Ewindowtrim(0,i);
			Ewindowtrim(1,44);
			color(woodcolor) mirror() translate([-1/12,20-68/2/12,floorT]) cube([2/12,68/12,transom ? 8+4/12 : 7]);
			color(woodcolor) mirror() translate([6/12,20-68/2/12,floorT]) cube([2/12,68/12,transom ? 8+4/12 : 7]);
			for(i=[2+2/12,5+0/12,7+10/12,12+0/12,25+0/12]) Swindowtrim(i,0);
			for(i=[2.5,5]) Wwindowtrim(26+10/12,i);
			for(i=[13+10/12]) Wwindowtrim(26+10/12,i,w=52);
			for(i=[21+10/12,25+4/12]) Wwindowtrim(26+10/12,i,z0=6,w=36,h=78);
			for(i=[32+6/12,33+10/12]) Wwindowtrim(26+10/12,i,w=14,h=36,z0=42);
			Wwindowtrim(13+2/12,45.5);
			Nwindowtrim(21+10/12,40-6/12,w=28,h=42,z0=48);
		}
		//color(woodcolor) mirror() for(i=[17+6/12,21+10/12]) translate([-1.5/12,i,4/12+floorT]) 
		//		cube([1.75/12,8/12,36/12]);
		// east face
		for(i=[4,12,28,36]) NSwindow(0,i);
		color(woodcolor) for(i=[17+10/12,22+2/12]) NSpicturewindow(0,i,z0=6,w=8,h=68);
		color(woodcolor) NSdoor(-1/12,20,w=36,t=8.5,h=80/12);
		NSpicturewindow(0,20,58,22,16);
		if (transom) NSpicturewindow(0,20,86,60,10);
		NSwindow(1,44);
		// south face
		for(i=[2+2/12,5+0/12,7+10/12,12+0/12,25+0/12]) EWwindow(i,0);
		//for(i=[14+10/12,22+2/12]) EWwindow(i,0);
		// west face
		//for(i=[2,9.5]) NSwindow(26+10/12,i);
		for(i=[2.5,5]) NSwindow(26+10/12,i);
		for(i=[13+10/12]) NSpicturewindow(26+10/12,i,w=52);
		for(i=[21+10/12]) NSpicturewindow(26+10/12,i,z0=6,w=36,h=76);
		NSdoor(26+9/12,25+4/12,w=36,t=8,h=6+10/12);
		NSwindow(26+10/12,25+4/12,z0=6,w=32,h=70);
		for(i=[32+6/12,33+10/12]) NSpicturewindow(26+10/12,i,w=14,h=36,z0=42);
		NSwindow(13+2/12,45.5);
		// north face
		EWpicturewindow(21+10/12,40-6/12,w=28,h=42,z0=48);
	}
}

module shell2() {
	difference() { 
		union() {
			difference() {
				color(color2) {
					EWwall(0,0,27+4/12,t=7,h=8);
					EWwall(0,40-7/12,27+4/12,t=7,h=8);
					NSwall(0,0,40,t=7,h=8);
					NSwall(27+3/12-.5,0,40,t=7,h=8);
				}
				color(interiorwallcolor) mirror() translate([.5,.5,0]) cube([26+4/12,39,10]);
			}
			for(i=[4,12,28,36]) Ewindowtrim(0,i,h=42);
			Ewindowtrim(0,20,z0=40,h=34);
			for(i=[9+0/12,11+6/12,18+8/12,21+2/12]) Swindowtrim(i,0,h=42);
			for(i=[8+8/12,11+2/12,28+10/12,31+4/12,18+0/12,22+0/12]) 
					Wwindowtrim(26+10/12,i,h=42);
			for(i=[11+10/12,18+8/12]) Nwindowtrim(i,40-6/12,h=42);
		}
		// east face
		for(i=[4,12,28,36]) NSwindow(0,i,h=42);
		NSwindow(0,20,z0=40,h=34);
		// south face
		for(i=[9+0/12,11+6/12,18+8/12,21+2/12]) EWwindow(i,0,h=42);
		// west face
		for(i=[8+8/12,11+2/12,28+10/12,31+4/12,18+0/12,22+0/12]) NSwindow(26+10/12,i,h=42);
		// north face
		for(i=[11+10/12,18+8/12]) EWwindow(i,40-6/12,h=42);
	}
}

module EWbathsink(w=24) {
	difference() {
		color("saddlebrown") cube([w/12,2,3]);
		if (print>0) color("bisque") translate([w/2/12,14/12,3]) scale([18/12,1,1]) 
			sphere(r=.5,center=true,$fn=12);
	}
}	

module EWtoilet() {
	if (print>0) color("white") {
		difference() {
			translate([0,-14/12,14/12]) scale([1,20/14,1]) 
				sphere(r=7/12,center=true,$fn=18);
			translate([-10/12,-2,14/12]) cube([24/12,2,1]);
		}
		translate([-10/12,-8/12,15/12]) cube([20/12,7/12,1]);
		translate([-4/12,-20/12,0]) cube([8/12,10/12,1]);
	}
}

module NStoilet() {
	rotate(a=90) EWtoilet();
}

module shower(w=36,d=36) {
	color("white") difference() { 
		cube([w/12,d/12,6.5]);
		translate([2/12,2/12,2/12]) cube([(w-4)/12,(d-4)/12,6.5]);
		translate([2/12,-1/12,4/12]) cube([(w-4)/12,4/12,5+8/12]);
		translate([(w-2.2)/12,2/12,4/12]) cube([2.4/12,(d-4)/12,5+8/12]);
	}
}

module powderroom() {
	EWwall(0.5,29+8/12,9+8/12);
	difference() {
		union() {
			EWwall(0.5,24+0/12,10);
			EWdoortrim(2+4/12,24+0/12);
		}
		EWdoor(2+4/12,24+0/12);
	}
	difference() {
		union() {
			NSwall(6+8/12,24+4/12,5+4/12);
			NSdoortrim(6+8/12,25+10/12,w=24);
		}
		NSdoor(6+8/12,25+10/12,w=24);
	}
	if (print>0) EWwall(6+8/12,29+0/12,3+6/12);

	mirror() translate([3.75,27.5,floorT]) EWbathsink(w=30);
	mirror() color("silver",.7) translate([5+0/12,29.375,6]) cube([2,.125/12,3+0/12],center=true);
	mirror() translate([2,29.5,floorT]) EWtoilet();
}

module den() {
	EWwall(8.5,34+2/12,2);
	NSwall(8.5,34+6/12,3+6/12);
	NSwall(8.5,38,1+6/12);
	EWwall(8.5,37+8/12,1.5);
	difference() {
		union() {
			NSwall(10+2/12,31,3+6/12);
			NSdoortrim(10+2/12,32+4/12);
		}
		NSdoor(10+2/12,32+4/12);
	}
	color(carpetcolor) mirror() {
		translate([.5,30+0/12,floorT]) cube([9+8/12,4+2/12,.25/12]);
		translate([.5,34+0/12,floorT]) cube([8+0/12,5+10/12,.25/12]);
	}
}

module workshop() {
	NSwall(6.5,43+2/12,garageY-46.5+5+6/12,h=8);
	EWwall(6.5,43+2/12,2+2/12,h=8);
	difference() {
		union() {
			NSwall(8+6/12,39+6/12,4+0/12,h=8);
			NSdoortrim(8+6/12,41+6/12);
		}
		NSdoor(8+6/12,41+6/12);
	}
	EWwall(1.5,40-6/12,7+4/12);
	difference() {
		union() {
			EWwall(9+10/12,37+8/12,3+8/12,h=9);
			EWdoortrim(11+4/12,37+8/12);
		}
		EWdoor(11+4/12,37+8/12);
	}
	NSwall(13+2/12,38,1.5,h=9);
}

module closet() {
	NSwall(6+8/12,21+8/12,2+6/12);
	difference() {
		union() {
			EWwall(6+8/12,21+8/12,3+6/12);
			EWdoortrim(8+5/12,21+8/12,w=28);
		}
		EWdoor(8+5/12,21+8/12,w=28);
	}
}


panelW = 36;
frameW = 1.5/12;
wallL = 31;

module slidingdoor() {
	color("saddlebrown") for (i=[0,5,7,9-frameW-2/12]) translate([0,-panelW/24,i]) cube([1/12,panelW/12,frameW]);
	color("saddlebrown") for (i=[-panelW/24,panelW/24-frameW]) translate([0,i,frameW]) cube([1/12,frameW,9-2*frameW]);
	color("saddlebrown") for (i=[-1,1]) translate([0,-frameW/2+i*panelW/12/6,5]) cube([1/12,frameW,2]);
	%color("gray") translate([-1/48,-panelW/24+frameW,frameW]) cube([1/24,panelW/12-2*frameW,9-2/12-2*frameW]);
}

module projectspace() {
	NSwall(9+6/12,0.5,wallL/12);
	NSwall(9+6/12,.5+15+10/12-wallL/12,wallL/12);
	EWwall(0.5,16,9+4/12);
	mirror() if (position == 2) {
		for (i=[.5+panelW/24,.5+15+10/12-panelW/24]) translate([9+6/12+5/12,i,floorT]) slidingdoor();
		for (i=[.5+panelW/24,.5+15+10/12-panelW/24]) translate([9+6/12+7/12,i,floorT]) slidingdoor();
	} else  if (position == 1) {
		for (i=[(15+10/12)/2+.5-(.51*panelW/12),(15+10/12)/2+.5+(.51*panelW/12)]) translate([9+6/12+7/12,i,floorT]) slidingdoor();
		for (i=[(15+10/12)/2+.5-(1.5*panelW/12)+frameW,(15+10/12)/2+.5+(1.5*panelW/12)-frameW]) translate([9+6/12+5/12,i,floorT]) slidingdoor();
	} else {
		for (i=[.5+panelW/24,.5+21+2/12-panelW/24]) translate([9+6/12+5/12,i,floorT]) slidingdoor();
		for (i=[.5+panelW/24,.5+21+2/12-1.5*panelW/12]) translate([9+6/12+7/12,i,floorT]) slidingdoor();
	}
	mirror() color("saddlebrown") translate([9+6/12+4/12,.5,9-2/12+floorT]) cube([4/12,21+2/12,2/12]);
	mirror() color("saddlebrown") translate([9+6/12+4/12,.5,-1/19+floorT]) cube([4/12,21+2/12,1/12]);
}


module stairs(l=12+8/12,w=3+2/12,h=10,n=12) {
	if (print>0) color(carpetcolor) for(i=[0 : n-2]) translate([0,l-l/n*(i+1),h/n*i]) cube([w,l/n,h/n]);
	color(interiorwallcolor) hull() {
		translate([0,l-l/n,0]) cube([w,2/12,2/12]);
		translate([0,l/n,h/n*(n-2)]) cube([w,2/12,2/12]);
	}
}

module stairwell() {
	NSwall(10+2/12,19,2+8/12,h=3);
	NSwall(10+2/12,21+8/12,9+4/12);
	NSwall(13.5,19,2+8/12,h=3);
	NSwall(13.5,21+8/12,5+10/12);

	color(interiorwallcolor) for(i=[10+2/12,13.5]) hull() {
		mirror() translate([i,19+0/12,8+5/12+floorT]) cube([4/12,2/12,7/12]);
		mirror() translate([i,21+8/12,6+5/12+floorT]) cube([4/12,2/12,2+7/12]);
	}

	mirror() translate([10+5/12,18,floorT]) stairs();
	color(carpetcolor) mirror() translate([13.5,31-3-6.625/12,floorT]) cube([13/12,2*13/12,2*10/12]);
	color(carpetcolor) mirror() translate([13.5,31-3-7/12+2*13/12,floorT]) cube([13/12,1*13/12,1*10/12]);
}

module woodstove() {
		color("dimgray") mirror() {
		hull() {
			cube([26/12,26/12,2/12]);
			translate([0,3/12,0]) cube([29/12,20/12,2/12]);
		}
		translate([0,3/12,0]) cube([20/12,22/12,1]);
		hull() {
			translate([0,0,1]) cube([26/12,26/12,20/12]);
			translate([0,3/12,1]) cube([29/12,20/12,20/12]);
		}
		translate([6/12,13/12,32/12]) cylinder(r=3/12,h=6.25,$fn=18);
	}
}

module hearth() {
	color(hearthcolor) hull() {
		translate([61/12,11/12,0]) cube([1/12,(16+26)/12,1/12]);
		translate([0,11/12,0]) rotate(a=45) cube([.5/sqrt(2),.5/sqrt(2),1/12]);
		translate([0,(11+36)/12,0]) rotate(a=45) cube([.5/sqrt(2),.5/sqrt(2),1/12]);
	}
	color(hearthcolor) translate([(58-24)/12,0,0]) cube([24/12,(52+12)/12,1/12]);
	color(hearthcolor) translate([(57.5)/12,0,0]) cube([.5/12,(52+12)/12,28/12]);
}

module cornerbasecabinet() {
	color("saddlebrown") cube([33/12,23/12,35/12]);
	color("saddlebrown") translate([10/12,-9/12,0]) cube([23/12,33/12,35/12]);

	color("wheat") translate([0,0,35/12]) cube([33/12,2,1/12]);
	color("wheat") translate([9/12,-9/12,35/12]) cube([2,33/12,1/12]);
}

module EWbasecabinet(w=12,h=36,d=24) {
	color("saddlebrown") translate([0,1/12,0]) cube([w/12,(d-1)/12,(h-1)/12]);
	color("wheat") translate([0,0,(h-1)/12]) cube([w/12,d/12,1/12]);
}

module NSbasecabinet(w=12,d=24,h=36) {
	color("saddlebrown") translate([1/12,0,0]) cube([(d-1)/12,w/12,(h-1)/12]);
	color("wheat") translate([0,0,(h-1)/12]) cube([d/12,w/12,1/12]);
}

module EWtallcabinet(w=36,d=24,h=8) {
	color("saddlebrown") cube([w/12,d/12,h]);
}

module NStallcabinet(w=36,d=24,h=8) {
	color("saddlebrown") cube([d/12,w/12,h]);
}

module cornerwallcabinet(z0=54,h=42) {
	color("saddlebrown") {
		translate([0,1,z0/12]) cube([33/12,1,h/12]);
		translate([1+9/12,-9/12,z0/12]) cube([1,33/12,h/12]);
		translate([1.75,.25,z0/12]) rotate(a=45) cube([1.5/sqrt(2),1.5/sqrt(2),h/12]);
	}
}

module EWwallcabinet(w=12,z0=54,h=42,d=12) {
	color("saddlebrown") translate([0,2-d/12,z0/12]) cube([w/12,d/12,h/12]);
}

module NSwallcabinet(w=12,z0=54,h=42) {
	color("saddlebrown") translate([1,0,z0/12]) cube([1,w/12,h/12]);
}

module EWrange(w=32) {
	color("silver") translate([0,-2/12,0]) cube([w/12,2+2/12,3+1/12]);
	color("silver") translate([0,20/12,0]) cube([w/12,4/12,3+9/12]);
}

module NSdishwasher(w=23,h=36) {
	color("silver") translate([0/12,.5/12,0]) cube([1/12,w/12,(h-2)/12]);
}


module EWventhood(w=32,z0=62) {
	color("dimgray") hull() {
		translate([0,10/12,z0/12]) cube([w/12,14/12,7.25/12]);
		translate([3/12,4/12,(z0+1)/12]) cube([(w-6)/12,.01/12,3/12]);
	}
	color("dimgray") translate([(w/2)/12,2-5/12,z0/12]) cylinder(r=3/12,h=9-(z0)/12,$fn=25);
	translate([-1/12,0,0]) EWwallcabinet(w+2,z0+.001,h=4+7.25);
} 

module EWfridge(w=36) {
	color("silver") translate([0,-4/12,0]) cube([w/12,2+4/12,66/12]);
}

module NSkitchensink() {
	color("silver") translate([2/12,0,0]) {
		hull() for (x=[0.25,1.5]) for (y=[0,7/12]) for (z=[0,-.5]) translate([x,y,z]) sphere(r=.1,$fn=5);
	}
	color("silver") translate([2/12,.875,0]) {
		hull() for (x=[0.25,1.5]) for (y=[0.125,1.125]) for (z=[0,-.5]) translate([x,y,z])  sphere(r=.1,$fn=5);
	}
}

module island() {
	color("wheat") translate([0,0,40/12]) EWbasecabinet(w=60,h=2,d=18);
	color("wheat") translate([0,14/12,0]) EWbasecabinet(w=60,h=40,d=4);
	color("wheat") translate([60/12,(26+18)/12,0]) rotate(a=180) 
		EWbasecabinet(w=60,h=36,d=26);
}

module lattice() {
	latticeW=3;
	latticeH=8;
	color("saddlebrown") for(i=[0,latticeW]) translate([0,i,0]) cube([16.5,2/12,latticeH/12]);
	color("saddlebrown") for(i=[12/12:18/12:15.5]) translate([i,0,1/12]) cube([2/12,latticeW,(latticeH-2)/12]);
}


module kitchen() {
	// N wall cabinets
	mirror() translate([24.001,39.501-2,floorT]) cornerbasecabinet();
	mirror() translate([23+2/12,39.501-2,floorT]) EWbasecabinet(w=10);
	mirror() translate([20+5.5/12,39.501-2,floorT]) EWrange();
	mirror() translate([19+7/12,39.501-2,floorT]) EWbasecabinet(w=10);
	mirror() translate([16+7/12,39.501-2,floorT]) EWtallcabinet();
	mirror() translate([13+6.5/12,39.501-2,floorT]) EWfridge();
	mirror() translate([24.001,39.501-2,floorT]) cornerwallcabinet();
	mirror() translate([23+2/12,39.501-2,floorT]) EWwallcabinet(w=10);
	mirror() translate([20+5.5/12,39.501-2,floorT]) EWventhood();
	mirror() translate([19+7/12,39.501-2,floorT]) EWwallcabinet(w=10);
	mirror() translate([13+7/12,39.501-2,floorT]) EWwallcabinet(w=36,z0=74,h=22,d=24);
	// W wall cabinets
	difference() {
		mirror() translate([24.001+9/12,35.5-8-0/12,floorT]) NSbasecabinet(w=39+48+24);
		if (print>0) mirror() translate([24.001+9/12,32+2/12,3+floorT]) NSkitchensink();
	}
	mirror() translate([24.001+9/12,35.5-8-0/12,floorT]) NSwallcabinet(w=48);
	mirror() translate([24.001+9/12,31.5,floorT]) NSwallcabinet(w=39,z0=90,h=6);
	mirror() translate([24.001+9/12,35.5-9/12,floorT]) NSwallcabinet(w=24);
	mirror() translate([24.001+9/12,34+9/12,floorT]) NSdishwasher();
	
	mirror() translate([17,29,floorT]) island();
	mirror() translate([10+4/12,27.5,8+floorT]) lattice();
}

module floor1() {
	mirror() difference() {
		union() {
			color(color1) cube([(27+4/12),40,floorT]);
			color(vinylcolor) translate([0,0,floorT]) cube([27+4/12,40,.125/12]);
		}
		color(interiorwallcolor) translate([10.5,19,-1]) cube([3,11+4/12,floorT+2]);
	}
	color(color1) mirror() translate([1,40,0]) cube([12+8/12,garageY-36,floorT]);
	color(vinylcolor) mirror() translate([1.5,40,floorT]) cube([12+1/12,garageY-36,.125/12]);
	color(carpetcolor) mirror() translate([10,.5,floorT]) cube([17,13.25,.25/12]);
}

module firstfloor() {
	shell1();
	floor1();
	projectspace();
	workshop();
	powderroom() ;

	stairwell();
	den();
	closet();
	kitchen();

	mirror() translate([26+4/12,12+9/12,floorT+1/12]) woodstove();
	mirror() translate([22,11+2/12,floorT]) hearth();
}

//
// second floor
//

module masterbathsink(w=90) {
	difference() {
		union() {
			color("saddlebrown") translate([0,1/12,0]) cube([23/12,(w-2)/12,35/12]);
			color("wheat") translate([0,0,35/12]) cube([24/12,w/12,1/12]);
		}
		color("bisque") translate([14/12,.2*w/12,3]) scale([1,18/12,1]) 
			sphere(r=.5,center=true,$fn=12);
		color("bisque") translate([14/12,.8*w/12,3]) scale([1,18/12,1]) 
			sphere(r=.5,center=true,$fn=12);
	}
}	

module masterbathtub() {
	color("white") difference() {
		hull() {
			cube([1,1,28/12]);
			translate([59.5/12,0,14/12]) cube([1/12,1/12,28/12],center=true);
			translate([0,59.5/12,14/12]) cube([1/12,1/12,28/12],center=true);
			translate([59.5/12,30/12,14/12]) cylinder(r=.5/12,h=28/12,center=true);
			translate([30/12,59.5/12,14/12]) cylinder(r=.5/12,h=28/12,center=true);
		}
		hull() for(i=[[.5,.5,28/12],[53/12,.5,28/12],[.5,53/12,28/12],[29/12,53/12,28/12],[53/12,29/12,28/12],
					[.75,.75,.5],[50/12,.75,.5],[.75,50/12,.5],[26/12,50/12,.5],[50/12,26/12,.5]]) {
			translate(i) sphere(r=3/12,center=true,$fn=10);
		}
	}
}

module masterbathshower(w=48,d=48) {
	color("white") {
		hull() for(i=[[0,0,0],[w/2/12,0,0],[w/12,d/2/12,0],[w/12,d/12,0],[0,d/12,0]]) translate(i) cube([.01,.01,1/12]);
		cube([1/12,w/12,7]); // west
		translate([0,d/12-1/12,0]) cube([w/12,1/12,7]); // south
		for (i=[0,w/2/12-3/12]) translate([i,0,0]) cube([4/12,1/12,7]); // north
		for (i=[d/2/12,d/12-4/12]) translate([w/12-1/12,i,0]) cube([1/12,4/12,7]); // east
		for (i=[0,7-4/12]) {
			translate([0,0,i]) cube([w/2/12,1/12,3/12+(1/12)/(7-4/12)*i]); // north
			translate([w/12-1/12,d/2/12,i]) cube([1/12,d/2/12,3/12+(1/12)/(7-4/12)*i]); // east
			hull() {
				translate([w/2/12,0,i]) cube([1/12,1/12,3/12+(1/12)/(7-4/12)*i]);
				translate([w/12-1/12,d/2/12,i]) cube([1/12,1/12,3/12+(1/12)/(7-4/12)*i]);
			}
		}
	}
}

module masterbath() {
	EWwall(0.5,9.5,9+10/12,h=8);
	NSwall(10+2/12,9.5,7+0/12,h=8);
	NSwall(10+2/12,16.5,9+6/12,h=8);
	*NSwall(5+10/12,9+10/12,3,h=8);
	difference() {
		union() {
			EWwall(0.5,26+0/12,10+0/12,h=8);
			EWdoortrim(4+2/12,26+0/12);
		}
		EWdoor(4+2/12,26+0/12);
	}
	if (print>0) EWwall(5+10/12,16.5,4+8/12,h=8);
	difference() {
		union() {
			NSwall(5+10/12,16.5,9+6/12,h=8);
			NSdoortrim(5+10/12,16.5+(9+6/12)/2);
		}
		NSdoor(5+10/12,16.5+(9+6/12)/2);
	}

	if (print>0) mirror() {
		translate([10+3/12,14+10/12,floorT]) rotate(a=180) NStoilet();
		//translate([10+2/12,13+10/12,floorT]) rotate(a=180) masterbathshower(w=48,d=48);
		translate([10+1.99/12,12+10.01/12,floorT]) rotate(a=180) shower(w=48,d=36);
		translate([6/12,20-45/12,floorT]) masterbathsink();
		translate([6/12,9+10/12,floorT]) masterbathtub();
	}
	
	mirror() color("silver",.7) for (y=[-1,1]) translate([.5,20+y*(2+7/12),6]) cube([.125/12,2,3+0/12],center=true);
}

module masterbedroom() {
	NSwall(10+2/12,26+4/12,4+6/12,h=8);
	EWwall(10+2/12,30+6/12,3+4/12,h=8);
	difference() {
		union() {
			NSwall(13+6/12,30+6/12,9,h=8);
			if (print>0) NSdoortrim(13+6/12,32+8/12);
		}
		NSdoor(13+6/12,32+8/12);
	}
}

module stairwall() {
	color("saddlebrown") mirror() translate([13+6/12,18+10/12,floorT]) {
		for (i=[0,6/12,2+4/12,3-2/12]) translate([0,0,i]) cube([4/12,11+8/12,2/12]); // horiz
		for (i=[1/12,5+8.5/12,11+4/12]) translate([.5/12,i,2/12]) cube([3/12,3/12,3+0/12]); // posts
		for (i=[8.5/12:.5:5+8/12]) translate([1.5/12,i,6/12]) cube([1/12,1/12,2+0/12]); // banisters
		for (i=[6+4/12:.5:11+3/12]) translate([1.5/12,i,6/12]) cube([1/12,1/12,2+0/12]); // banisters
	}
}

module SEbedroom() {
	difference() {
		union() {
			NSwall(13+8/12,0.5,11+7/12,h=8);
			if (print>0) NSdoortrim(13+8/12,7+6/12,w=28);
		}
		NSdoor(13+8/12,7+6/12,w=28);
	}
	difference() {
		union() {
			EWwall(10+2/12,11+10/12,3+10/12,h=8);
			if (print>0) EWdoortrim(12+2/12,11+10/12);
		}
		EWdoor(12+2/12,11+10/12);
	}
	if (print>0) EWwall(13+8/12,4+11/12,3+0/12,h=8);
	EWwall(13+8/12,9+6/12,3+0/12,h=8);
}

module SWbedroom() {
	difference() {
		union() {
			NSwall(16+8/12,0.5,13+0/12,h=8);
			if (print>0) NSdoortrim(16+8/12,2+8/12,w=28);
			if (print>0) NSdoortrim(16+8/12,11+8/12);
		}
		NSdoor(16+8/12,2+8/12,w=28);
		NSdoor(16+8/12,11+8/12);
	}
	EWwall(17+0/12,13+2/12,9+10/12,h=8);
}

module NWbedroom() {
	difference() {
		union() {
			NSwall(16+8/12,27+6/12,12+0/12,h=8);
			if (print>0) NSdoortrim(16+8/12,37+0/12,w=28);
			if (print>0) NSdoortrim(16+8/12,29+2/12);
		}
		NSdoor(16+8/12,37+0/12,w=28);
		NSdoor(16+8/12,29+2/12);
	}
	EWwall(13+8/12,34+4/12,3+0/12,h=8);
	
}


module upstairsbathsink(w=60) {
	difference() {
		union() {
			color("saddlebrown") cube([w/12,23/12,35/12]);
			color("wheat") translate([0,0,35/12]) cube([w/12,2,1/12]);
		}
		color("bisque") translate([.25*w/12,14/12,3]) scale([18/12,1,1]) 
			sphere(r=.5,center=true,$fn=12);
		color("bisque") translate([.75*w/12,14/12,3]) scale([18/12,1,1]) 
			sphere(r=.5,center=true,$fn=12);
	}
}	


module upstairsbath() {
	difference() {
		union() {
			NSwall(16+8/12,13+6/12,6+8/12,h=8);
			if (print>0) NSdoortrim(16+8/12,18+0/12);
		}
		NSdoor(16+8/12,18+0/12);
	}
	NSwall(16+8/12,20+0/12,7+6/12,h=8,t=3);
	difference() {
		union() {
			EWwall(17+0/12,19+10/12,9+10/12,h=8);
			EWdoortrim(25+2/12,19+10/12);
			EWdoortrim(18+8/12,19+10/12);
		}
		EWdoor(25+2/12,19+10/12);
		EWdoor(18+8/12,19+10/12);
	}
	EWwall(16+11/12,27+2/12,9+11/12,h=8);
	NSwall(21+6/12,19+10/12,7+4/12,h=8);
	NSwall(25+2/12,13+2/12,2+0/12,h=8);
	EWwall(16+11/12,15+2/12,3,h=8);
	EWwall(25+2/12,14+2/12,1+8/12,h=8);
	EWwall(25+2/12,15+2/12,1+8/12,h=8);
	if (print>0) NSwall(19+10/12,13+6/12,2+0/12,h=8);

	if (print>0) mirror() {
		translate([21+10/12,22+0/12,floorT]) NStoilet();
		translate([21+10/12,24+3/12,floorT]) shower(w=60,d=36);
		translate([20+2/12,13+6/12,floorT]) upstairsbathsink();
		translate([17+4/12,15+5/12,floorT+6/12]) EWtallcabinet(w=30,d=2,h=3+0/12);
		translate([17+4/12,15+5/12,floorT+3+7/12]) EWtallcabinet(w=30,d=2,h=3+0/12);
		color("silver") translate([26+4/12,12+9/12,0]+[-6/12,13/12,0]) cylinder(r=3/12,h=8+floorT,$fn=18);
		translate([25+6/12,15+6/12,floorT+6/12]) EWtallcabinet(w=12,d=1,h=3+0/12);
		translate([25+6/12,15+6/12,floorT+3+7/12]) EWtallcabinet(w=12,d=1,h=3+0/12);
 	}

	mirror() color("silver",.7) for (x=[-1,1]) translate([22+8/12+x*(1+2/12),13+6/12,6]) cube([2,.125/12,3+0/12],center=true);
}


module EWwasherdryer() {
	color("white") cube([27/12,31/12,38.5/12]);
	color("white") translate([27.25/12,0,0]) cube([27/12,31/12,38.5/12]);
}

module NSwasherdryer() {
	color("white") cube([31/12,27/12,38.5/12]);
	color("white") translate([0,28/12,0]) cube([31/12,27/12,38.5/12]);
}


module laundryroom() {
	mirror() translate([16+11.5/12,24.5,floorT]) EWwasherdryer();
	mirror() translate([16+11/12,25+2/12,floorT]) EWwallcabinet(w=55,h=24,z0=60);
}

module floor2() {
	mirror() if (print>0) difference() {
		color(carpetcolor) translate([-.5,-.5,0]) cube([28+4/12,41,floorT+.25/12]);
		color("white") {
			for(i=[-1,40]) translate([-1,i,-.01]) cube([30,1,floorT+.011+.25/12]);
			for(i=[-1,27+4/12]) translate([i,-1,-.01]) cube([1,42,floorT+.011+.25/12]);
		}
		color(interiorwallcolor) translate([10+6/12,19,-1]) cube([3,11+6/12,floorT+2]);
		color(vinylcolor) translate([.5,9.5,floorT-.125/12]) cube([9+8/12,7+4/12,1]);
		color(vinylcolor) translate([.5,16.5,floorT-.125/12]) cube([5.5,10,1]);
		color(vinylcolor) translate([16+8/12,13+2/12,floorT-.125/12]) cube([10.5,12,1]);
	} else {
		color("white") cube([27+4/12,40,floorT]);
	}
}

module secondfloor() {
	shell2();
	floor2();
	SEbedroom();
	masterbath();
	masterbedroom();
	if (print>0) stairwall();
	NWbedroom();
	SWbedroom();
	upstairsbath();
	if (print>0) laundryroom();
	translate([0,20,-10]) porchroof();
}


//
// roof
//
hipped=1;
pitch=5/12;
breezewaypitch = 5/12;
windowW = 18;
windowpitch = windowW+6;
Nwindows = 6;
dormerW = (windowpitch*Nwindows+16)/12;

module hippedroof() {
	difference() {
		color("gray") hull() {
			translate([-2,-2,0]) cube([31+8/12,44,6/12]); 
			translate([13+8/12,10,pitch*(15+8/12)]) rotate([0,45,0]) cube([.0001,20,.0001]);
		}
		color("white") hull() {
			translate([10+8/12,20-dormerW/2+4/12,-1]) cube([5+4/12, dormerW-8/12,pitch*(12+8/12)+4/12]);
			translate([13+8/12,20-dormerW/2+4/12,pitch*(15+8/12)-8/12]) cube([.0001,dormerW-8/12,.0001]);
		}
		color("white") translate([10+8/12,20-dormerW/2+4/12,pitch*(12+8/12)-8/12]) cube([2+8/12, dormerW-8/12,pitch*(12+8/12)+4/12]);
	}
}


module gabledroof() {
	difference() {
		color("gray") hull() {
			translate([-2,-1.5,0]) cube([31+8/12,43,6/12]); 
			translate([13+8/12,-1.5,pitch*(15+8/12)]) rotate([0,45,0]) cube([.0001,43,.0001]);
		}
		color(color2) for(i=[-2,41]) translate([-3,i,-1]) cube([35,1,25]); 
		color(color2) for(i=[-2,40]) hull() {
			translate([0,i,-1]) cube([27+8/12,2,18/12]); 
			translate([13+8/12,i,pitch*(13+8/12)]) rotate([0,45,0]) cube([.0001,2,.0001]);
		}
		color("white") hull() {
			translate([10+8/12,20-dormerW/2+4/12,-1]) cube([5+4/12, dormerW-8/12,pitch*(12+8/12)+4/12]);
			translate([13+8/12,20-dormerW/2+4/12,pitch*(15+8/12)-8/12]) cube([.0001,dormerW-8/12,.0001]);
		}
		color("white") translate([10+8/12,20-dormerW/2+4/12,pitch*(12+8/12)-8/12]) cube([2+8/12, dormerW-8/12,pitch*(12+8/12)+4/12]);
	}
}

module roof() {
	mirror() {
		// main section
		if (hipped) {
			hippedroof();
		} else {
			gabledroof();
		}
		// chimney
		color(color2) translate([24+9/12,12+11/12,1]) cube([2.0,2.0,6]);
		color(color2) {
			translate([24+7/12,12+9/12,7]) cube([2+4/12,2+4/12,.5]);
			for (x=[24+8/12:22/12:28]) for (y=[12+10/12:22/12:15])
				translate([x,y,1]) cube([4/12,4/12,6]); 
		}
		color("silver") translate([25+9/12,13+11/12,7.5]) cylinder(r=.5,h=1,$fn=18);
		// dormer
		difference() {
			color("gray") hull() {
				translate([10+4/12,19.5-dormerW/2,0]) cube([3+4/12,dormerW+1,1/12]); 
				translate([13+8/12,19.5-dormerW/2,pitch*(15+8/12)]) 
						rotate([0,45,0]) cube([.0001,dormerW+1,.0001]);
				translate([10+4/12,19.5-dormerW/2,pitch*(18+8/12)]) 
						rotate([0,45,0]) cube([.0001,dormerW+1,.0001]);
			}
			color(color2) for(i=[19-dormerW/2,20+dormerW/2]) translate([-3,i,-1]) cube([35,1,25]);
			color("white") hull() {
				translate([11+2/12,20-dormerW/2+4/12,-1]) cube([2+8/12, dormerW-8/12,pitch*(12+8/12)-8/12+1+9/12]);
				translate([10+8/12,20-dormerW/2+4/12,pitch*(18+8/12)-6/12]) 
						rotate([0,45,0]) cube([.0001,dormerW-8/12,.0001]);
			}
			for (i=[20-(Nwindows-1)*windowpitch/24:windowpitch/12:20+(Nwindows-1)*windowpitch/24]) 
					NSpicturewindow(-(10+8/12),i,z0=56,w=windowW,h=18); 
		}
		// joists
		if(print>0) color("gray") for(i=[20+6/12-dormerW/2:1.5:20+dormerW/2]) 
				translate([10+8/12,i,0]) cube([6,4/12,.5]);		
	}
}

module breezewayroof() {
	difference() {
		mirror() color("gray") hull() {
			translate([0,0,0]) cube([15+8/12,garageY-46.5+14,6/12]);
			translate([6+10/12,0,5/12*(7+10/12)]) rotate([0,45,0]) cube([1/12,garageY-46.5+14,1/12]);
		}
		mirror() color("gray") translate([-1,garageY-40,-garageH-1]) rotate(a=15) cube([28,10,garageH+1.01]);
		if (hipped) { 
			translate([1,garageY-40,garageH-10]) rotate(a=-15)  garageroof();
		}
	}
}


module porchroof() {
	mirror() { 
		difference() {
			color("gray") hull() {
				translate([-6.001,-5,9+floorT-.001]) cube([6.001,10,.501]);
				translate([-6,0,9+floorT+8/12*5]) rotate([45,0,0]) cube([6,1/12,1/12]);
			}
			color("white") translate([-7,-6,7+floorT]) cube([8,14,2]);
			color("white") translate([-7,-6,7+floorT]) cube([1,14,12]);
			color(color2) hull() {
				translate([-9,-3,8+floorT]) cube([3.5,6,16/12+8/12]);
				translate([-9,0,9+floorT+8/12*4]) rotate([45,0,0]) cube([3.5,1/12,1/12]);
			}
		}
	}
}


module porch() {
	mirror() { 
		// posts
		color("saddlebrown") for (y=[-4.5,4.5]) {
			for (x=[-5.5,-2.5]) translate([x-3/12,y-3/12,floorT]) cube([6/12,6/12,9]);
			for (z=[.5:2:9]) translate([-5.5,y-2/12,z-2/12+floorT]) cube([3,4/12,4/12]);
		}
		// decking
		color("sienna") mirror() {
			translate([0,-5,0]) cube([6,10,floorT]);
			// stairs
			for(i=[[5+10/12,-5,0],[6+4/12,-5,-8/12],[6+10/12,-5,-16/12]]) {
				translate(i-[0,0,1.5]) cube([8/12,10,1.875]);
			}
			// posts under deck
			for(i=[-5,4.5]) translate([5.25,i,-1.5]) cube([.5,.5,1.5]);
		}
	}
}


//
// garage
//


module garagefloor() {
	color("slategray") mirror() translate([0,0,-6/12]) cube([28,36,6/12]);
}

module garageshell() {
	difference() {
		union()  {
			difference() {
				color(color2) mirror() cube([28,36,garageH]);
				color("beige") mirror() translate([.5,.5,-1]) cube([27,35,garageH+2]);
			}
			Ewindowtrim(0,32+8/12,z0=42-12*floorT);
			color("white") NSdoortrim(0,10,w=16*12,h=(garageH<10.5)?8:9,z0=0,t=6);
			color("white") NSdoortrim(0,25,w=9*12,h=(garageH<10.5)?8:9,z0=0,t=6);
			color("white") NSdoortrim(27.5,3,t=6,w=36,z0=0);
			EWdoortrim(12+10/12,0,t=6,w=36,z0=2,h=7);
		}
		color("tan") NSdoor(0,10,w=16*12,h=(garageH<10.5)?8:9,z0=0,t=6);
		color("tan") NSdoor(0,25,w=9*12,h=(garageH<10.5)?8:9,z0=0,t=6);
		color("white") NSwindow(0,32+8/12,z0=42-12*floorT);
		color("white") for (i=[3.25:1.5:17]) NSpicturewindow(0,i,w=12,h=12,z0=((garageH<10.5)?5:6)*12+4);
		color("white") for (i=[21.25:1.5:29]) NSpicturewindow(0,i,w=12,h=12,z0=((garageH<10.5)?5:6)*12+4);
		EWdoor(12+10/12,0,t=6,w=36,z0=2,h=7);
		NSdoor(27.5,3,t=6,w=36,z0=0);
	}
}

module garageroof() {
	mirror() {
		difference() {
			color("gray") hull() {
				if (hipped) {
					translate([-2,-2,0]) cube([32,40,6/12]); 
					translate([14,9,5/12*(16)]) rotate([0,45,0]) cube([1/12,16,1/12]);
				} else {
					translate([-2,-.5,0]) cube([32,38,6/12]); 
					translate([14,-.5,5/12*(16)]) rotate([0,45,0]) cube([1/12,38,1/12]);
				}
			}
			if (!hipped) color(color2) for(i=[-1,37]) translate([-3,i,-1]) cube([36,1,25]); 
			if (!hipped) color(color2) hull() {
				translate([0,36,-1]) cube([28,2,18/12]); 
				translate([14,36,5/12*(14)]) rotate([0,45,0]) cube([1/12,2,1/12]);
			}
		}
	}
}

module garage() {
	garagefloor();
	garageshell();
	// stairs
	color("sienna") mirror() {
		for(i=[8:8:16]) translate([9+i/12,.5,0]) cube([8-i/6,3,i/12]);
		hull() {
			translate([9+24/12,.5,0]) cube([8-24/6,3,24/12]);
			translate([9+24/12,.5,0]) cube([8,3,.1/12]);
		}
	}
}

module basementfloor() {
	color("slategray") mirror() {
		cube([(27+4/12),40,floorT]);
		translate([1,40,0]) cube([12+8/12,garageY-46.5+7+2/12,floorT]);
	}
}

module basementshell() {
	difference() { 
		union() {
			color(color1) {
				EWwall(0,0,27+4/12,t=6,h=10);
				EWwall(0,40-.5,1+6/12,t=6,h=10);
				EWwall(13+8/12-.5,40-.5,13+8/12,t=6,h=10);
				NSwall(0,0,40,t=6,h=10);
				NSwall(27+4/12-.5,0,40,t=6,h=10);
				NSwall(1,40,garageY-46.5+7+2/12,t=6,h=10);
				NSwall(13+8/12-.5,40,garageY-46.5+7+2/12,t=6,h=10);
				EWwall(1,garageY+2/12,12+8/12,t=6,h=10);
				//NSwall(13+5/12,.5,13+8/12,t=6,h=10);
				//EWwall(13+5/12,13+11/12,13+8/12,t=6,h=10);
			}
			for(i=[8+0/12,11+0/12]) Swindowtrim(i,0,w=30);
			color("white") NSdoortrim(26+9/12,3,w=36,t=8,h=7.5);
			color("white") NSdoortrim(26+9/12,6+6/12,w=36,t=8,h=7.5);
			for(i=[15+6/12+3:3:22]) Wwindowtrim(26+10/12,i,w=30);
			color("white") EWdoortrim(24+4/12,0,w=36,h=7.5);
			color("white") EWdoortrim(20+10/12,0,w=36,h=7.5);
		}
		// south face
		for(i=[8+0/12,11+0/12]) EWwindow(i,0,w=30);
		EWpicturewindow(24+4/12,0,z0=6,w=36,h=7*12);
		EWpicturewindow(20+10/12,0,z0=6,w=36,h=7*12);
		// west face
		for(i=[15+6/12+3:3:22]) NSwindow(26+10/12,i,w=30);
		NSpicturewindow(26+9/12,3,z0=6,w=36,h=7*12);
		NSpicturewindow(26+9/12,6+6/12,z0=6,w=36,h=7*12);
	}
}


module basementstairs() {
	NSwall(10+2/12,19,11,h=10);
	NSwall(13.5,19,10,h=10);

	mirror() translate([10+5/12,18,floorT]) stairs(l=14,h=11,n=14);
	for (i=[13.5,10+4/12-14/14]) color(carpetcolor) mirror() 
				translate([i,29+0/12+2*14/14,floorT]) cube([13/12,1*14/14,1*11/14]);
	color(carpetcolor) mirror() 
			translate([10+4/12-14/14,29+0/12+14/14,floorT]) cube([13/12,14/14,11/14]);
	color(carpetcolor) mirror() translate([13.5,29+0/12,floorT]) cube([13/12,2*14/14,2*11/14]);

}


module basement() {
	EWwall(0.5,19,10,h=10);
	difference() {
		union() {
			EWwall(0.5,30-4/12,10,h=10);
			EWdoortrim(7.5,30-4/12);
		}
		EWdoor(7.5,30-4/12);
	}

	basementfloor();
	basementshell();
	basementstairs();
	//screenporch();
}


module dirtwalls() {
	color("saddlebrown") mirror() {
		// east
		translate([-1,garageY+6/12,-11]) rotate(a=15) cube([28,36-6/12,9.5]);
		hull() {
			translate([-1.5,garageY-46.5+47,-11]) cube([1,1,9.5]);
			translate([-1.5,15,-11]) cube([1,1,9.5]);
			translate([-1.5,-1.5,-11]) cube([1,1,6]);
		}
		translate([-8,15,-11]) cube([7.5,10,9.5]);
		
		// south
		hull() {
			translate([-1.5,-1.5,-6]) cube([1,1,1]);
			translate([-1.5,-1.5,-11]) cube([1,1,1]);
			translate([14,-1.5,-11]) cube([1,1,.5]);
		}
		translate([14,-1.5,-11]) cube([14,1,.5]);
		// west
		translate([28,-1.5,-11]) cube([1,14,.5]);
		hull() {
			translate([28,12,-11]) cube([1,1,.5]);
			translate([28,40.5,-11]) cube([1,1,8]);
		}
		hull() {
			translate([28,40.5,-11]) cube([1,1,8]);
			translate([14,40.5,-11]) cube([1,1,9.5]);
		}
		hull() {
			translate([14,40.5,-11]) cube([1,1,9.5]);
			translate([14,garageY-46.5+50.5,-11]) cube([1,1,9.5]);
		}
		hull() {
			translate([14,garageY-46.5+50.5,-11]) cube([1,1,9.5]);
			translate([24.75,garageY-46.5+53.5,-11]) cube([1,1,9.5]);
		}
		// under deck
		hull() {
			translate([29,23+0/12,-11]) cube([12.5,1,3.5]);
			translate([27,23+4/12+22,-11]) cube([14.5,4,9.5]);
		}
	}
}

module dirt() {
	if (print>0) color("saddlebrown") difference() { 
		union() {
			dirtwalls();
			translate([-20,40,-11.75]) scale([1.05,1.05,1]) translate([20,-40,11]) hull() {
				intersection() { 
					dirtwalls();
					translate([0,0,-11]) cube([100,200,1.5],center=true);
				}
			}
		}
		hull() {
			translate([0,garageY-46.5+54,-11]) rotate(a=-15) cube([1,1,17], center=true);
			translate([7,garageY-46.5+78,-11]) rotate(a=-15) cube([1,1,17], center=true);
			translate([-15,garageY-46.5+84,-11]) rotate(a=-15) cube([1,1,17], center=true);
			translate([-22,garageY-46.5+56,-11]) rotate(a=-15) cube([1,1,17], center=true);
			translate([-15,garageY-46.5+54,-11]) rotate(a=-15) cube([1,1,17], center=true);
		}
		translate([-14,20,-11]) cube([24,36,2], center=true);
		translate([-7,garageY-46.5+44,-11]) cube([10,16,17], center=true);
		hull() {
			translate([-35,47,-11]) cube([8,3,17], center=true);
			translate([-35,25,-11]) cube([8,1,6], center=true);
		}
	} else {
		dirtwalls();
	}
}

module deck() {
	color("sienna") {
		cube([14,24,10/12]); // decking
		// top rail
		//translate([.5,23.5,3+10/12]) cube([10,.5,2/12]); // north
		translate([0,16.5,3+10/12]) cube([.5,7.5,2/12]); // east
		translate([0,0,3+10/12]) cube([14,.5,2/12]); // south
		translate([13.5,0.5,3+10/12]) cube([.5,23.5,2/12]); // west
		// 4x4 posts
		for(i=[0:(13+8/12)/2:(13+7/12)]) translate([i,0,10/12]) cube([4/12,4/12,3]); // south
		translate([0,23+8/12,10/12]) cube([4/12,4/12,3]); // north
		//for(i=[0:(10+2/12)/2:(10+3/12)]) translate([i,23+8/12,10/12]) cube([4/12,4/12,3]); // north
		translate([0,16.5,10/12]) cube([4/12,4/12,3]); // east
		for(i=[0:(23+8/12)/3:(23+8/12)]) translate([13+8/12,i,10/12]) cube([4/12,4/12,3]); // west
		// horizontal rails
		for(i=[4/12,1+10/12,2+8/12,]) {
			//translate([4/12,23+9/12,i+10/12]) cube([10,2/12,4/12]); // north
			translate([1/12,16+10/12,i+10/12]) cube([2/12,7,4/12]); // east
			translate([4/12,2/12,i+10/12]) cube([13+4/12,2/12,4/12]); // south
			translate([13+9/12,4/12,i+10/12]) cube([2/12,23.5,4/12]); // west
		}
		// banisters
		if (print>=0) for(i=[8/12:8/12:(13+7/12)]) translate([i,0,15/12]) cube([2/12,3/12,1+8/12]); // south
		//for(i=[8/12:8/12:(10+3/12)]) translate([i,23+10/12,15/12]) cube([2/12,3/12,1+8/12]); // north
		if (print>=0) for(i=[16+10/12:8/12:(23+8/12)]) translate([-1/12,i,15/12]) cube([3/12,2/12,1+8/12]); // east
		if (print>=0) for(i=[8/12:8/12:(23+8/12)]) translate([13+10/12,i,15/12]) cube([3/12,2/12,1+8/12]); // west
		// stairs
		for(i=[[0,24-2/12,-2],[0,24+4/12,-2.5],[0,25-2/12,-3]]) translate(i) cube([14,8/12,2]);
		// posts
		translate([13.5,0,-7.5]) cube([.5,.5,7.5]); 
		translate([13.5,23.5/2,-4.5]) cube([.5,.5,4.5]); 
		translate([13.5,23.5,-1.5]) cube([.5,.5,1.5]);
		translate([0,23.5,-2.5]) cube([.5,.5,2.5]);
	}
}


module dovetail() {
	translate([-5,45,0]) {
		for(i=[-15,0]) hull() {
			translate([i,0,0]) cube([8,1,100],center=true);
			translate([i,4,0]) cube([6,2,100],center=true);
		}
		translate([0,65,0]) cube([100,120,100],center=true);
	}
}


module clippedfirstfloor() {
	difference() {
		firstfloor();
		mirror() translate([-1,garageY,-2]) rotate(a=15) translate([-1,0,0]) cube([28,5,11+floorT]);
	}
}


//
// main
//

module all() {
	translate([30*Xexplode,0,-40*Zexplode]) dirt();
	translate([30*Xexplode,0,-20*Zexplode-11]) basement();
	clippedfirstfloor();
	translate([0,20,0]) porch();
	mirror() translate([27+4/12,23+4/12,floorT-10/12-2/12]) deck();
	translate([-30*Xexplode,0,20*Zexplode+9+floorT]) secondfloor();
	translate([-60*Xexplode,0,40*Zexplode+17+2*floorT]) roof();
	translate([1,garageY,-1]) rotate(a=-15) garage();
	translate([1-30*Xexplode,garageY,20*Zexplode + garageH-1]) rotate(a=-15)  garageroof();
	translate([1-30*Xexplode,40,20*Zexplode + 8+floorT]) breezewayroof();
}


scale(25.4/ftperinch) translate([0,0,11]) if (print<1) {
	all(); 
} else if (print == 1) {
	intersection() {
		union() { 
			dirt();
			intersection() {
				union() {
					translate([0,20,0]) porch();
					mirror() translate([27+4/12,23+4/12,floorT-10/12-2/12]) deck();
				}
				translate([0,0,-20]) cube([100,200,40-.01],center=true);
			}
		}
		dovetail();
	}
} else if (print == 2) {
	difference() {
		union() { 
			dirt();
			intersection() {
				union() {
					translate([0,20,0]) porch();
					mirror() translate([27+4/12,23+4/12,floorT-10/12-2/12]) deck();
				}
				translate([0,0,-20]) cube([100,200,40-.01],center=true);
			}
		}
		//dovetail();
	}
} else if (print == 3) {
	translate([0,0,-11]) basement();
} else if (print == 4) {
	clippedfirstfloor();
	difference() {
		union() {
			translate([0,20,0]) porch();
			mirror() translate([27+4/12,23+4/12,floorT-10/12-2/12]) deck();
		}
		translate([0,0,-20]) cube([100,200,40-.01],center=true);
	}
} else if (print == 5) {
	translate([0,0,9+floorT]) secondfloor();
} else if (print == 6) {
	translate([0,0,17+2*floorT]) roof();
} else if (print == 7) {
	translate([1,garageY,-1]) rotate(a=-15) garage();
} else if (print == 8) {
	translate([1-30*Xexplode,garageY,20*Zexplode + garageH-1]) rotate(a=-15)  garageroof();
	translate([1-30*Xexplode,40,20*Zexplode + 8+floorT]) breezewayroof();
} else if (print == 9) {
	difference() {
		union() {
			translate([1,garageY,-1]) rotate(a=-15) garage();
			translate([1-30*Xexplode,garageY,20*Zexplode + garageH-1]) rotate(a=-15)  garageroof();
			translate([1-30*Xexplode,40,20*Zexplode + 8+floorT]) breezewayroof();
		}
		cube([400,400,20],center=true);
	}
} else if (print == 10) {
	difference() {
		union() {
			clippedfirstfloor();
			translate([0,0,9+floorT]) secondfloor();
			translate([0,0,17+2*floorT]) roof();
		}
		cube([22,400,400],center=true);
	}
} else {
	clippedfirstfloor();
	translate([1,46.5,-1]) rotate(a=-15) garage();
}

