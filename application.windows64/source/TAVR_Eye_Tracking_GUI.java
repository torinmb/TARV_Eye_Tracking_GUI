import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.function.Function; 
import geomerative.*; 
import processing.serial.*; 
import cc.arduino.*; 
import geomerative.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TAVR_Eye_Tracking_GUI extends PApplet {




String[] keyboardData= {"zxcv", "|_|", "qwert", "asdfg","<delete>", ".", "hjkl", "yuiop", "bnm"};
//String[] homeData= {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
//String[] homeData = {"Bedroom", "Kitchen", "Living Room", "Garage", "Keyboard"};
String[] homeData = {"Lights", "TV", "Outlet", "Stereo"};
String[] lightsData= {"Off", "Back", "On"};
String[] keysData= {"asdf", "asdf", "asdf"};

//String[] lightsData= {"1 On", "2 On", "3 On", "Back", "1 Off", "2 Off", "3 Off"};
Ring lights;
Ring home;
Ring outlet;
Ring keyboard;
Ring keys;
float interfaceT = 0;
boolean showInterface = true;


boolean setupInterface; 

boolean useArduino;


Arduino arduino;
int r1on = 13;
int r1off = 12;

int SCALE;
float OPTION_RADIUS = 25.0f;

public void setup() {
    
    SCALE = height *2;
    RG.init(this);
    
    PFont font = loadFont("Roboto-Regular-48.vlw");
    textFont(font, 50);
    //useArduino = true;
   
    //Arduino Setup
    if (useArduino) {
        arduino = new Arduino(this, Arduino.list()[1], 57600);
        arduino.pinMode(r1on, Arduino.OUTPUT);
        arduino.pinMode(r1off, Arduino.OUTPUT);
    }
   
    home = new Ring(homeData, displayWidth, displayHeight);
    lights = new Ring(lightsData, displayWidth, displayHeight);
    keyboard = new Ring(keyboardData, displayWidth, displayHeight);
    keys = new Ring(keysData, displayWidth, displayHeight);
}


public void draw() {
    translate(width/2, height/2);
    background(255);
    blendMode(BLEND);
    strokeWeight(2);
    
    if (mousePressed) {
       println(OPTION_RADIUS);
       OPTION_RADIUS = map(mouseX, 0, width, 1, 40);
    }
    if (showInterface) {
        
        interfaceT = lerp(interfaceT, 1, .06f);
        if (interfaceT >= .998f) {
            interfaceT = 1;
            showInterface = false;
        }
    }
    scale(interfaceT);
    //scale(.2);
    switch(home.selectedElement) {
        case "Lights":
            lights.draw(g); 
            break;
        case "Keyboard":
            if (keys.selectedElement == "") {
                keyboard.draw(g);
            }
            break;
        default: 
            home.draw(g); 
            break;
    }
    
    
    //this is purely for the keyboard
    switch(keyboard.selectedElement) {
        case "": break;
        case "qwert":
            String[] keysData = {"q", "w", "e", "r", "t"}; 
            keys = new Ring(keysData, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case "yuiop": 
            String[] keysData1 = {"y", "u", "i", "o", "p"}; 
            keys = new Ring(keysData1, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case "asdfg": 
            String[] keysData2 = {"a", "s", "d", "f", "g"}; 
            keys = new Ring(keysData2, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case "hjkl": 
            String[] keysData3 = {"h", "j", "k", "l"}; 
            keys = new Ring(keysData3, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case "zxcv": 
            String[] keysData4 = {"z", "x", "c", "v"}; 
            keys = new Ring(keysData4, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case "bnm": 
            String[] keysData5 = {"b", "n", "m"}; 
            keys = new Ring(keysData5, displayWidth, displayHeight);
            keys.draw(g);
            break;
        case ".": break;
        case "|_|": break;
        default : break;
        
    }
    
    switch(keys.selectedElement) {
        case "": break;
        default: print(keys.selectedElement); 
            keys.selectedElement = "";
            //keyboard.selectedElement = "";
            break;
    }
    
    if (home.selectedElement == "Lights") {
        switch(lights.selectedElement) {
            case "On":
                if (useArduino) {
                    arduino.digitalWrite(r1on, Arduino.HIGH);
                    delay(100);
                    arduino.digitalWrite(r1on, Arduino.LOW); 
                }
                lights.selectedElement = "";
                home.selectedElement = "";
                break;
            case "Off":
                print("1 OFF1");
                if (useArduino) {
                    arduino.digitalWrite(r1off, Arduino.HIGH);
                    delay(100);
                    arduino.digitalWrite(r1off, Arduino.LOW);
                }
                lights.selectedElement = "";
                home.selectedElement = "";
                break;
            case "Back":
                lights.selectedElement = "";
                home.selectedElement = "";
                break;
            default: break;
        }
    } 
}




class Ring {
    RShape ring;
    RShape safeZone;
    RFont text;
    String selectedElement;
    int selectedRingIndex;
    boolean firstTime;
    boolean firstTimeOverElement;
    String[] data;
    
    
    Ring(String[] data, int width, int height) {
        this.selectedElement = "";
        this.data = data;
        this.ring = new RShape();
        this.safeZone = RG.getEllipse(0, 0, 40);
        this.safeZone = RG.centerIn(safeZone, g, 330);
        for (int i = 1; i < this.data.length + 1; i++) {
            RPath path = new RPath(0, 0);
            int x1 = getX(i, this.data.length, SCALE);
            int y1 = getY(i, this.data.length, SCALE);
            int x0 = getX(i-1, this.data.length, SCALE);
            int y0 = getY(i-1, this.data.length, SCALE);
            
            path.addLineTo(x0, y0);
            path.addLineTo(x1, y1);
            path.addClose();
            this.ring.addChild(new RShape(path));
        }    
        this.ring = this.ring.diff(this.safeZone);
    }

    public void draw(PGraphics g) {
        ring.draw(g);
        safeZone.draw(g);
        int ringWeight = 10;
        RPoint p = new RPoint(mouseX-width/2, mouseY-height/2);
        if (safeZone.contains(p)){
            firstTime = true;
            firstTimeOverElement = true;
            stroke(0,100,255,250);
            ringWeight = 80;
        }
        stroke(0,0,0,80);
        safeZone.draw(g);
        stroke(0, 0, 0, ringWeight);
        ring.draw(g);
        for(int i=0; i < ring.countChildren(); i++) {
            if(ring.children[i].contains(p)) {
               if (firstTime) {
                   selectedRingIndex = i;
               }
               if (!firstTime && selectedRingIndex != i) {
                   firstTimeOverElement = false;
               }
               if (selectedRingIndex == i) {
                  if (firstTimeOverElement) {
                      stroke(0,100,255,250);
                  }
               }

               ring.children[i].draw();
               stroke(0, 0, 0, ringWeight);
               if (firstTime) {
                   firstTime = false;
                   selectedElement = this.data[i];
               }
            }
            drawText(i);
        }
    }
    
    public void drawText(int index) {
        int i = index;
        fill(50);
        textSize(25);

        int x1 = getX(i + 1, this.data.length, SCALE);
        int y1 = getY(i + 1, this.data.length, SCALE);
        int x0 = getX(i, this.data.length, SCALE);
        int y0 = getY(i, this.data.length, SCALE);

        float xavg = (x1 + x0) / OPTION_RADIUS;
        float yavg = (y1 + y0) / OPTION_RADIUS;
        float textCenter = textWidth(this.data[i]) / 4.0f;
        xavg -= textCenter;
        
        text(this.data[i], xavg - textCenter, yavg);
        strokeWeight(10);
        point(xavg - textCenter, yavg);
        strokeWeight(3);
        noFill();
    }

    public int getX(int i, int segments, int size) {
        float index = 1.0f * TWO_PI * i / segments; 
        return round(cos(index ) * size);
    }

    public int getY(int i, int segments, int size) {
        float index = 1.0f * TWO_PI * i / segments; 
        return round(sin(index) * size);
    }

    
}
    public void settings() {  size(displayWidth, displayHeight, P3D);  smooth(8); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--hide-stop", "TAVR_Eye_Tracking_GUI" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
