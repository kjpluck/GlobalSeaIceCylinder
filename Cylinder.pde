import java.util.Map;


StringList _seaIceData;
int _lineCount = 0;
StringDict _data = new StringDict();

void setup(){
  size(1000,1000,P3D);
  frameRate(30);
  strokeWeight(4);
  loadData();
}

void draw(){ 
  camera(500, 500, 866.0254, 500, 500, 0,0,1,0);
  //println(frameCount/365+1978);
  background(0);
  lights();
  
  fill(255, 128, 0);

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
  
  float angle = (TWO_PI*((frameCount/3.0) % 365.0)/365.0) + PI;
  rotateY(-angle);
  text(frameCount/365+1978,-10,20,0);
  stroke(127);
  strokeWeight(7);
  line(0,0,0,0,-2000,0);
  stroke(0);
  
  if(frameCount % 30 == 0) println(frameCount);
  //slow down when frameCount > 1350;
  
  int maxD = frameCount*10;
  
  if(frameCount > 1380){
    maxD = 13800 + (frameCount - 1380)/2;
  }
  
  for(int d=0; d<=maxD;d++)
  {
    int year = d / 365;
    year += 1979;
    int day = d % 365 + 1;
    float r = 2*PI * d/365.0;
    float x = (float) Math.sin(r) * 600;
    float z = (float) Math.cos(r) * 600;
    
    // So that the global line appears over antarctic line make the cylinder radius a smidge wider.
    float xGlobal = (float) Math.sin(r) * 601;
    float zGlobal = (float) Math.cos(r) * 601;
    
    String line = GetData(year, day);
    
    if(line == "") {lastArea = 0; continue;}
    
    if((year==2017 && day >= 82) || year>=2018) continue;
    
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
    
    color blue = color(0,0,255);
    color red = color(255,0,0);
    
    float lerp = (areaGlobalAnom + 2.11+3.03)/(2.11+3.03 + 2.00+1.49);
    stroke(lerpColor(red, blue, lerp));
    
    strokeWeight(5);
    line(xGlobal, -areaGlobal*50, zGlobal, lastGX, -lastArea*50, lastGZ);
    
    lerp = (areaArcticAnom + 3.03)/(3.03 + 1.49);
    stroke(lerpColor(red, blue, lerp));
      
    strokeWeight(2);
    line(x, -areaArctic*50, z, lastX, -lastArcticArea*50, lastZ);
    
    lerp = (areaAntarcticAnom + 2.11)/(2.11 + 2.00);
    stroke(lerpColor(red, blue, lerp));
    
    line(x, -areaAntarctic*50, z, lastX, -lastAntarcticArea*50, lastZ);
    lastGX=xGlobal;
    lastGZ=zGlobal;
    lastX = x;
    lastZ = z;
    lastArcticArea = areaArctic;
    lastAntarcticArea = areaAntarctic;
    lastArea = areaGlobal;
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



void drawCylinder( int sides, float r, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;

    // draw top of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);

    // draw bottom of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    
    // draw sides
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
        vertex( x, y, -halfHeight);    
    }
    endShape(CLOSE);

}

public static DateTime GetNonLeapYear(){
    return new DateTime(2001,1,1,0,0,0,0);
  }
  
  public String GetData(int year, int dayOfYear){
    String date;
    
    if(year < 1979) return "";
    if(year == 2017 && dayOfYear >= 82) return "";
    
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