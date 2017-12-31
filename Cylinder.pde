import java.util.Map;
import com.hamoid.*;

VideoExport videoExport;

PFont helveticaSmall;
PFont helveticaLarge;

color blue = color(127,127,255);
color white = color(255,255,255);
color red = color(255,0,0);
color northColour = color(63,150,195);
color southColour = color(86,32,128);

StringList _seaIceData;
int _lineCount = 0;
StringDict _data = new StringDict();
int DAYOFYEARTODAY = 364;
float VerticalScale = 50;

void setup(){
  size(1000,1000,P3D);
  helveticaSmall = createFont("helvetica-normal-58c348882d347.ttf", 32);
  helveticaLarge = createFont("helvetica-normal-58c348882d347.ttf", 64);
  textFont(helveticaLarge);
  textAlign(CENTER, CENTER);
  textMode(SHAPE);
  frameRate(30);
  strokeWeight(4);
  strokeCap(PROJECT);
  loadData();
  
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(30);
  videoExport.startMovie();
}


void draw(){ 
  
  camera(500, 500, 866.0254, 500, 500, 0,0,1,0);
  //println(frameCount/365+1978);
  background(0);
  lights();
  ambientLight(255, 255, 255);
  
  fill(255);

  //rotateX( PI );
  
  float areaArctic = 0.0;
  float areaAntarctic = 0.0;
  float areaGlobal = 0.0;
  float areaArcticAnom = 0.0;
  float areaAntarcticAnom = 0.0;
  float areaGlobalAnom = 0.0;
  float lastArea = 0;
  float lastGX = 0.0;
  float lastGZ = 0.0;
  float lastX = 0.0;
  float lastZ = 0.0;
  float lastArcticArea = 0.0;
  float lastAntarcticArea = 0.0;
  String[] data = new String[10];
  
  translate( width/2, 1000, -1000 );
  
  float angle = (TWO_PI*(((frameCount+900)/2.8) % 365.0)/365.0) + PI;
  //angle = angle * 0.95;
  rotateY(-angle);
  renderScales();
  
  
  int maxD = frameCount*30;
  
  if(frameCount > 460){
    maxD = int(13800 + (frameCount - 460)/2.5);
  }
  
  pushMatrix();
    stroke(0);
    strokeWeight(1);
    textFont(helveticaLarge);
    rotateY(angle);
    
    text("Global Sea Ice Area",0,-1190,0);
    text("@kevpluck",0,-1120,0);
    int displayYear = maxD/365+1979;
    if(displayYear>2017) displayYear=2017;  // TODO, in 2018 increase by 1 :-)
    text(displayYear,-10,-1050,0);
    
    fill(northColour);
    text("Arctic", 0,-540,0);
    
    fill(southColour);
    text("Antarctic", 0, -470,0);
    
    fill(white);
    textFont(helveticaSmall);
    for(int i=0; i<=25; i+=5)
    {
      String unit = "M SqKm";
      if(i == 0) unit = " SqKm";
      text(i + unit,       -740,-(i * VerticalScale),0);
    }
  
    text("Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS Passive Microwave Data (NSIDC-0051),\n Near-Real-Time DMSP SSMIS Daily Polar Gridded Sea Ice Concentrations", 0, 400,0);
  
  popMatrix();
  
  for(int d=0; d<=maxD;d++)
  {
    int year = d / 365;
    year += 1979;
    int day = d % 365 + 1;
    float r = 2*PI * d/365.0;
    float x = (float) Math.sin(r) * 600;
    float z = (float) Math.cos(r) * 600;
    
    // So that the global line appears over antarctic line make the cylinder radius a smidge wider.
    
    float lerp = float(year-1978)/float(2017-1978);
    float xGlobal = (float) Math.sin(r) * (600.0 + lerp * 5);
    float zGlobal = (float) Math.cos(r) * (600.0 + lerp * 5);
    float xGlobalComet = (float) Math.sin(r) * 606.0;
    float zGlobalComet = (float) Math.cos(r) * 606.0;
    
    String line = GetData(year, day);
    
    if(line == "") {lastArea = 0; continue;}
    
    if((year==2017 && day >= DAYOFYEARTODAY) || year>=2018) continue;
    
    data = split(line, ',');
    if(data != null && data.length > 3)
    {
      // arctic    anom min -3.03, max 1.49
      // antarctic anom min -2.11, max 2.00
      areaArcticAnom = float(data[7]);
      areaAntarcticAnom = float(data[9]);
      areaGlobalAnom = areaArcticAnom + areaAntarcticAnom;
      
      areaArctic = float(data[3]);
      areaAntarctic = float(data[5]);
      areaGlobal = areaArctic + areaAntarctic;
      if(lastArea ==0)
      {
        lastArcticArea = areaArctic;
        lastAntarcticArea = areaAntarctic;
        lastArea = areaGlobal;
        lastGX = xGlobal;
        lastGZ = zGlobal;
        lastX = x;
        lastZ = z;
      }
    }
  
    int distanceFromEnd = maxD - d;
    
    
    color lcg=lerpColor(color(182,15,61), color(208,98,111), lerp);
    color lcn=northColour;
    color lcs=southColour;
    if(distanceFromEnd<50)
      {
        lcg=lerpColor(white, lcg, distanceFromEnd/50.0);
        lcn=lerpColor(white, lcn, distanceFromEnd/50.0);
        lcs=lerpColor(white, lcs, distanceFromEnd/50.0);
        xGlobal=xGlobalComet;
        zGlobal=zGlobalComet;
        x=xGlobalComet;
        z=zGlobalComet;
      }
    stroke(lcg);
    
    strokeWeight(5);
    line(xGlobal, -areaGlobal * VerticalScale, zGlobal, lastGX, -lastArea * VerticalScale, lastGZ);
    
    
    lerp = (areaArcticAnom + 3.03)/(3.03 + 1.49);
    stroke(lcn);
      
    strokeWeight(2);
    
    if(distanceFromEnd<50) strokeWeight(3);
    line(x, -areaArctic * VerticalScale, z, lastX, -lastArcticArea * VerticalScale, lastZ);
    
    lerp = (areaAntarcticAnom + 2.11)/(2.11 + 2.00);
    stroke(lcs);
    
    line(xGlobal, -areaAntarctic * VerticalScale, zGlobal, lastGX, -lastAntarcticArea * VerticalScale, lastGZ);
    
    lastGX=xGlobal;
    lastGZ=zGlobal;
    lastX = x;
    lastZ = z;
    lastArcticArea = areaArctic;
    lastAntarcticArea = areaAntarctic;
    lastArea = areaGlobal;
  }
  videoExport.saveFrame();
  
  
  if(frameCount > 1800){
    videoExport.endMovie();
    exit();
  }
}


void loadData()
{
  String[] lines = loadStrings("nsidc_NH_SH_nt_final_and_nrt.txt");
  
  for (String line : lines) {
    if(line.charAt(0) == '#' || line.charAt(0) == ' ') continue;
    
    String[] values = split(line, ',');
    String dateTime = values[0];
    String date = split(dateTime, ' ')[0];
    _data.set(date,line);
    
  }

}

public void renderScales()
{
  textFont(helveticaLarge);
  pushMatrix();
  rotateX(PI/2);
  //text("January",0,600,0);
  
  text("January", 0,600,0);
  rotateZ(-PI/6);
  text("February", 0,600,0);
  rotateZ(-PI/6);
  text("March", 0,600,0);
  text("Antarctic Summer",0 ,500,0);
  rotateZ(-PI/6);
  text("April", 0,600,0);
  rotateZ(-PI/6);
  text("May", 0,600,0);
  rotateZ(-PI/6);
  text("June", 0,600,0);
  rotateZ(-PI/6);
  text("July", 0,600,0);
  rotateZ(-PI/6);
  text("August", 0,600,0);
  rotateZ(-PI/6);
  text("September", 0,600,0);
  text("Arctic Summer", 0,500,0);
  rotateZ(-PI/6);
  text("October", 0,600,0);
  rotateZ(-PI/6);
  text("November", 0,600,0);
  rotateZ(-PI/6);
  text("December", 0,600,0);
  
  popMatrix();
}

public static DateTime GetNonLeapYear()
{
  return new DateTime(2001,1,1,0,0,0,0);
}
  
public String GetData(int year, int dayOfYear)
{
  String date;
  
  if(year < 1979) return "";
  if(year == 2017 && dayOfYear >= DAYOFYEARTODAY) return "";
  
  if(year == 1987 && dayOfYear > 336) return "";   //Missing data in 1987
  if(year == 1988 && dayOfYear <= 12) return "";   //Missing data in 1988
  
  // Years up to 1988 only have data for every second day so if png doesn't exist then try the next day
  do{
    DateTime dt = GetNonLeapYear().withDayOfYear(dayOfYear);
          
    int month = dt.monthOfYear().get();
    int day = dt.dayOfMonth().get();
    date = String.format("%04d-%02d-%02d", year, month, day);
    
    if(year > 1988) return _data.get(date);
    
    dayOfYear++;
    if(dayOfYear > 365) dayOfYear = dayOfYear - 3; // Don't go to the next next, simply skip back a few days - close enough!
  }
  while(!_data.hasKey(date));
  
  return _data.get(date);
}