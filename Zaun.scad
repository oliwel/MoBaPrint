rowcnt=4;
rowspace=4;
barcnt=18;
barspace=1.7;
innerwid=0.3;
outerwid=0.7;
pilelen=2;


totwidth=barcnt*(barspace+innerwid)-innerwid+2*outerwid;
totheight=rowcnt*(rowspace+innerwid)-innerwid+2*outerwid;

cube([outerwid,totheight+pilelen,outerwid]);
cube([totwidth,outerwid,outerwid]);
for (xpos = [1:barcnt-1]) {
    translate([xpos*(barspace+innerwid)-innerwid+outerwid,0,0]) cube([0.4,totheight,0.4]);    
}
for (ypos = [1:rowcnt-1]) {
    translate([0,ypos*(rowspace+innerwid)-innerwid+outerwid,0]) cube([totwidth,0.4,0.4]);    
}
translate([totwidth-outerwid,0,0]) cube([outerwid,20,outerwid]);

translate([0,totheight-outerwid,0]) cube([totwidth,outerwid,outerwid]);

