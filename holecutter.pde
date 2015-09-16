//2015
//jward

//dat.gui 
var obj = {
app : "HoleCutter",
material : 0,
thickness : 3.175,
machine : "FabMo",
feedrate : 800,
plungerate : 300,
cut_depth : -4,
shape : "polygon",
radius : 15,
verts : 400,
pX : 75,
pY : 75,
width : 800,
rotate : 0,
show_section : true,
units : 0,
gcode : 0,
td : 3.175,
pn : 1,
pd : 3.175,
tabs : true,
tablength : 10,
tabdepth: 1,
pocketon : false,
safe_height : 4,
dpolygon : true,
points : 5,
ir : 3,
size : 30,
n : 6,
d : 8,
o : 0.00,
k : 0.001,
pins : 10,
way : 150,
wax : 150,
resize : false,

}

var ColorObject = function() 
{
this.color = "#391f8c";
}
var colorObject = new ColorObject();

var obj2 = { make:function(){ obj.gcode=1 });

var gui1 = new dat.GUI({ load: JSON });

//gui1.remember(obj);

var f1 = gui1.addFolder('ADVANCED SETTINGS');
f1.add(obj, 'machine').name('');
//f1.addColor(colorObject, 'color').name('bg color');
f1.add(obj, 'units', { mm:0 } );
f1.add(obj, 'material', { plywood:0} );
f1.add(obj, 'feedrate', 0, 20000).step(1);
f1.add(obj, 'plungerate', 0, 1000).step(1);
//f1.add(obj, 'pn', 1, 10).name('# of passes').step(1);
//f1.add(obj, 'pd').name('pass depth').listen();
f1.add(obj, 'safe_height', 0, 10).name('safe height').step(0.5);
f1.add(obj, 'way', 0, 500).name('y max').step(1);
f1.add(obj, 'wax', 0, 500).name('x max').step(1);
f1.add(obj, 'resize').name('resize');


var f2 = gui1.addFolder('HOLECUTTER');

f2.add(obj, 'machine').name('');
//f2.add(obj, 'pX', 0,170).listen().name('X center');
//f2.add(obj, 'pY', 0,210).listen().name('Y center');
f2.add(obj, 'radius',1.1,120).step(0.01).name('inside radius');
f2.add(obj, 'thickness', 0.1, 30.1).step(0.1).name('thickness');
f2.add(obj, 'cut_depth', -26, 0).step(0.1).name('cut depth');
f2.add(obj, 'td', 0, 10.7).step(1.5875).name('tool diameter');
f2.add(obj, 'pn', 1, 10).name('# of passes').step(1);
f2.add(obj, 'pd').name('pass depth').listen();
f2.add(obj, 'pocketon').name('make pocket');
f2.add(obj, 'tabs').listen().name('add tabs');

gui1.add(obj2, 'make').name('MAKE CUT FILE');

f2.open();

String[] gcode = { "" };

String[] txt = { "" };


int radius2 = 0;
float offset = 0;
int feedrate = obj.feedrate; //mm/min
int plungerate = obj.plungerate; //mm/min
float z = -1; //(change back to -1)depth of cut mm
float sh = 4; //safe height 
int pn = 1;//number of passes
float pd = z/pn;//pass depth when pn > 1
float zd = z;//display z

int wax = obj.wax;//work area of machine (mm)
int way = obj.way;

float sf = $(window).height()/way;  //display scale factor

int width = wax*sf;
int height = $(window).height()-30;

float tool_diameter = 3.175;
float thickness = obj.thick;
int verts = obj.verts;  
float rotate = 0;
float x = 0;
float y = 0;
float x2 = 0;
float y2 = 0;
int pX = obj.pX;
int pY = obj.pY;
int scolor = color(0,128,255);

float radius = obj.radius;  //radius of polygon

PFont font;


///////////////////////////////////////////////////////////////////
public void setup() 
{
size(width, height);
background(0);
strokeWeight(tool_diameter);
strokeJoin(ROUND);
strokeCap(SQUARE);
stroke(255);
noFill();
cursor(CROSS);
smooth();


font = createFont("txt", 32);
font2 = createFont("monospace", 14);
textFont(font);

}

public void draw() 
{
obj.verts = int(obj.radius*16);
obj.tablength = int(20);
obj.tabdepth = nf(0-(obj.thickness*0.6),1,0);
//println(obj.tablength);

if(obj.resize == true){
resize();
}
resizeSketch();

thickness = obj.thickness;
feedrate = obj.feedrate;
plungerate = obj.plungerate;
verts = obj.verts;
pX = obj.pX*sf;
pY = obj.pY*sf;
rotate = radians(obj.rotate);
z = obj.cut_depth;
pd = z/pn;
zd = z;
tool_diameter = obj.td;
pn = obj.pn;
obj.pd = pd;
obj.safe_height = sh;

if(obj.gcode == 1)
{
makegcode();
}

//display working area of machine

String bgcolor = colorObject.color;
bgcolor = "ff" + bgcolor.substring(1);
fill(unhex(bgcolor));

stroke(255,255,0);
strokeWeight(0);
rect(0,$(window).height()-(way*sf)-100,(wax*sf)*2,$(window).height()*2);
fill(221);

//font
textFont(font,obj.size*sf);
text(txt, pX, height-pY);

textFont(font2);
textSize(14);
text("HOLE CENTER = X0,Y0", 5,14);
//text("y:", 10,50);
//text(nf((height-mouseY)/sf,1), 30,50);
//text(nf(mouseX/sf,1), 30,30);

if(obj.show_section == true)
{
section();
}

//draw x y axis & origin
noStroke();
fill(0,204,0);
rect(0,height-way*sf,2,way*sf);
fill(204,0,0);
rect(0,height-2,wax*sf,height);
fill(255,255,0);
rect(0,$(window).height()-3,3,3);
translate(0, height);
scale(1,-1);

radius2 = obj.radius-tool_diameter/2;

//pocket
if(obj.pocketon == true)
{
obj.tabs = false;

//display pocket path settings
stroke(200);
noFill();
strokeWeight(1);//display cut width

//polygon pocket from inside
for(radius = 0; radius <= radius2-(tool_diameter*0.2); radius = radius+tool_diameter*0.8)
{
polygon();
}

}

//display shapes

centerpoint();

strokeWeight(tool_diameter*sf);//display cut width
radius = radius2;



if(obj.dpolygon == true){
polygon();
} 


if (mousePressed && (mouseButton == LEFT))
{
//pX=mouseX;
//pY=height-mouseY;
//obj.pX = pX/sf;
//obj.pY = pY/sf;
}

//end draw
}


///////////////////////////////////////////////////////////////////
void keyPressed()
{

if(keyCode == BACKSPACE)
{
txt = txt.substring (0,txt.length()-1);
}
else if((key != CODED) && (key != TAB) && (key != ESC) && (key != DELETE))
{
txt = txt + key.toString();
}

//key BACKSPACE, TAB, ENTER, RETURN, ESC, and DELETE

if (keyCode == LEFT)
{
obj.pX -= 1;
}
if (keyCode == RIGHT)
{
obj.pX += 1;
}
if (keyCode == UP)
{
obj.pY += 1;
}
if (keyCode == DOWN)
{
obj.pY -= 1;
}
if (key == ENTER)
{

}
}

///////////////////////////////////////////////////////////////////
void section(){

//draw material section view
fill(160,82,45);
rect(0,height,wax*sf,0-thickness*sf);
fill(0,51,153);
rect(pX-radius*sf-(tool_diameter/2*sf),height-thickness*sf,radius*2*sf+tool_diameter*sf,abs(z)*sf);
fill(255,0,0);
}
///////////////////////////////////////////////////////////////////
//input
void makegcode() 
{
header();
if((obj.pocketon == false) && (obj.dpolygon == true))
{  
makepolygon();
}
if((obj.pocketon == true) && (obj.dpolygon == true))
{
makepolygonpocket();
}


///////////////////////////////////////////////////////////////////
footer(); 

//make file & download link
String[] sa = reverse(gcode);
String g = join(sa, "\n");
var date = new Date();

//format date
second = nf(date.getSeconds(),2);
hours = nf(date.getHours(),2);
minutes = nf(date.getMinutes(),2);
month = nf(date.getMonth()+1,2);
day = nf(date.getDate(),2);

/*
var link = document.getElementById("download-link");

link.setAttribute("href", "data:text/plain;base64," + btoa(g));

//filename
//link.setAttribute("download", "gcode_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second + ".g");

link.setAttribute("download", "partmaker.g");
//download(link);

link.style.display = "none";
link.click();
//window.location.href = 'data:image/octet-stream;base64,' + btoa(g);

*/

   fabmoDashboard.submitJob(g, { filename : "gcode_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second + ".g", name : 'HoleCutter', description : 'Generated by HoleCutter' });

//println(g);

var reload = document.getElementById("reload");
reload.setAttribute("href", "javascript:history.go(0)");
reload.style.display = "inline";

translate(0, height);
scale(1,-1);
obj.gcode = 0;
  
}

//write gcode
///////////////////////////////////////////////////////////////////
void header(){

translate(0, height);
scale(1,-1);
gcode = splice(gcode," ",1);//inch g20
gcode = splice(gcode,"g21",1);//inch g20
gcode = splice(gcode,"g0z"+nf(sh,1,3),1); //go safe height
gcode = splice(gcode,"g0x0y0",1); //go home
gcode = splice(gcode,"m4",1);//turn on router
;
}
///////////////////////////////////////////////////////////////////
void footer()
{
gcode = splice(gcode,"m5",1);
gcode = splice(gcode,"g0x0y0z"+nf(sh,1,3),1);
gcode = splice(gcode,"g20",1);
gcode = splice(gcode,"m30",1);
}
///////////////////////////////////////////////////////////////////
void makepolygon(){   
//first pass
z = pd;
int pn2 = pn - 1;
  
for (int i = 0; i <= verts; i++) 
{

x = sin(TWO_PI/verts*i+rotate)*radius;
y = cos(TWO_PI/verts*i+rotate)*radius;  
if (i == 0) 
{
gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
//gcode = splice(gcode,"g4p0.5",1);
gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
gcode = splice(gcode,"g4p0.5",1);
gcode = splice(gcode,"f" + feedrate,1);
//println(pd);
//println(obj.tabdepth);
}

//tabs
else if(((obj.tabs==true)&&(i==int(verts*0.25-(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75-(obj.tablength/2)))))

{

if(pd<obj.tabdepth){
gcode = splice(gcode,"g0z" + nf(obj.tabdepth,1,3),1); //tab depth
}
else
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
}


else if( ((obj.tabs==true) && (i==int(verts*0.25+(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75+(obj.tablength/2)))))
{

gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3) + "f" + feedrate,1);

}
//


else 
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
} 
//done first pass

//if multiple pass
while (pn2 != 0)
{
pd = pd + z;
for (int i = 0; i <= verts; i++) 
{
x = sin(TWO_PI/verts*i+rotate)*radius;
y = cos(TWO_PI/verts*i+rotate)*radius;
if (i == 0) 
{
gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
//gcode = splice(gcode,"g4p0.5",1);
gcode = splice(gcode,"f" + feedrate,1);
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}

//tabs
else if(((obj.tabs==true)&&(i==int(verts*0.25-(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75-(obj.tablength/2)))))
{

if(pd<obj.tabdepth){
gcode = splice(gcode,"g0z" + nf(obj.tabdepth,1,3),1); //tab depth
}
else
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
}


else if( ((obj.tabs==true) && (i==int(verts*0.25+(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75+(obj.tablength/2)))))
{

gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3) + "f" + feedrate,1);

}
//


else 
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
} 
pn2 = pn2 -1;
}
gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
//reset
z = obj.cut_depth;
pn = obj.pn;
pd = z/pn;
}
///////////////////////////////////////////////////////////////////
void makepolygonpocket()
{
radius2=radius;
//multipass
z = pd;
int pn2 = pn - 1;
for(radius = 0; radius < radius2-tool_diameter*0.8; radius = radius+tool_diameter*0.8)
{
verts = nf(radius+2, 1, 0)*16;   
for (int i = 0; i <= verts; i++) 
{
x = sin(TWO_PI/verts*i+rotate)*radius;
y = cos(TWO_PI/verts*i+rotate)*radius;
    
if (i == 0 && radius ==0)
{
gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut

gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
gcode = splice(gcode,"g4p0.5",1);
gcode = splice(gcode,"f" + feedrate,1);
radius = tool_diameter*0.3;

}
else 
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
} 
}

//if multiple passes 
while (pn2 != 0)
{
pd = pd + z;
for(radius = 0; radius < radius2-tool_diameter*0.8; radius = radius+tool_diameter*0.8)
{
verts = nf(radius+1, 1, 0)*16; 
for (int i = 0; i <= verts; i++) 
{
x = sin(TWO_PI/verts*i+rotate)*radius;
y = cos(TWO_PI/verts*i+rotate)*radius;

if (i == 0 && radius ==0) 
{
gcode = splice(gcode,"g0z" + nf(sh,1,3),1);
gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
gcode = splice(gcode,"g4p0.5",1);
//gcode = splice(gcode,"M2," + nf(x, 1, 3) + "," + nf(y, 1, 3),1);
gcode = splice(gcode,"f" + feedrate,1);
radius = tool_diameter*0.3;

}
else 
{
gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
}
} 
}
pn2 = pn2 -1;
}
//reset pass depth
pd = z;
//go to safe height
gcode = splice(gcode,"g1z" + nf(sh,1,3),1);
//finish pass
radius = radius2;
verts = radius*16;
makepolygon();
//end pocket
}

/////////////////////////////////////////////////
void mouseOver() 
{
scolor = color(0,128,255);
}
/////////////////////////////////////////////////
void mouseOut() 
{
//scolor = color(0,128,255);
//scolor = color(200,100,200);
}

/////////////////////////////////////////////////

void centerpoint()
{
fill(255,150,0);
noStroke();
ellipse(pX,pY,5,5);
noFill();
stroke(scolor);
}


void polygon()
{
beginShape(); 
for (int i = 0; i <= verts; i++) 
{ 
x = pX+sin(TWO_PI/verts*i+rotate)*(radius*sf);
y = pY+cos(TWO_PI/verts*i+rotate)*(radius*sf);

if(((obj.tabs==true)&&(i==int(verts*0.25-(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75-(obj.tablength/2)))))
{
endShape();
beginShape();
stroke(200,100,200);
}

else if( ((obj.tabs==true) && (i==int(verts*0.25+(obj.tablength/2)))) || ((obj.tabs==true)&&(i==int(verts*0.75+(obj.tablength/2)))) )
{
endShape();
beginShape();
stroke(0,128,255);

}

else{
vertex(x, y);
}

}
endShape();
}


public void resizeSketch()
{

sf = $(window).height()/way;
height = $(window).height()-30;
size(wax*sf, height);


}

public void resize()
{

way=obj.way;
wax=obj.wax;

}


void tabs()
{






}

