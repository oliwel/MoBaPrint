
//Europalette
 

//Customize
scale=1/87;
separate=true;
 

 
//Maße
fac=scale*87;
oMat=0.3;
mat=max(0.25,oMat*fac);
lng=13.8*fac;
wid=9.2*fac;
b1=1.1*fac;
b2=1.5*fac;
kMat=oMat*6*fac-mat*3+0.05;
brim=0.8;
brimh=0.3;
 
//Positionen
px1=(lng-b2)/2;
px2=lng-b2;
py1=(wid-b1)/2;
py2=wid-b1;
qy1=(wid-b2)/2;
qy2=wid-b2;
luecke=((wid-3*b2)/2-b1)/2;
z1=b2+luecke;
z2=qy1+b2+luecke;
 

 

//bottom();
if(separate) at(0,-2,mat*2) rotate([180,0,0]) top();
else at(0,0,mat+kMat) top();
 
 
//brim/Hilfssteg
/*color("red"){
    at(b2-brim,0)box(brim,wid,brimh);
    at((lng-brim)/2,0)box(brim,wid,brimh);
    at(lng-b2,0)box(brim,wid,brimh);
}*/
 
module bottom(){
    //Bodenbretter
    brettLaengs(b1);//Bodenrandbrett
    at(0,qy1) brettLaengs(b2);//Bodenmittelbrett
    at(0,py2) brettLaengs(b1);//Bodenrandbrett
 
    //Klötze
    at(0,0,mat){
        dreiKloetze(b1);
        at(0,qy1) dreiKloetze(b2);
        at(0,py2) dreiKloetze(b1);
    }
}
 
module top(){
    //3x Querbrett
    brettQuer(b2);
    at(px1) brettQuer(b2);
    at(px2) brettQuer(b2);
 
    //Deckbretter
    at(0,0,mat){
        brettLaengs(b2);
        at(0,z1) brettLaengs(b1);
        at(0,qy1) brettLaengs(b2);
        at(0,z2) brettLaengs(b1);
        at(0,qy2) brettLaengs(b2);
    }
    
}
 
module dreiKloetze(b){
     klotz(b);
     at(px1) klotz(b);
     at(px2) klotz(b);
}
 
module klotz(b){
    box(b2,b,kMat);
}
 
module brettLaengs(b){
    box(lng,b,mat);
}
 

module brettQuer(b){
    box(b,wid,mat);
}
 

//Tipparbeit sparen ;)
 
module at(x=0,y=0,z=0){
    translate([x,y,z]) children();
}
 
module box(w,h,d){
    cube([w,h,d]);
}
 