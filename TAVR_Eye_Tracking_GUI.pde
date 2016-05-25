import java.util.function.Function;
import geomerative.*;
import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

String[] keyboardData= {"zxcv", "|_|", "qwert", "asdfg","<delete>", ".", "hjkl", "yuiop", "bnm"};
//String[] homeData= {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
//String[] homeData = {"Bedroom", "Kitchen", "Living Room", "Garage", "Keyboard"};
String[] homeData = {"Lights", "TV", "Outlet", "Stereo"};
String[] stereoData = {"Off", "Back", "Volume", "On"};
String[] volumeData = {"100%", "Mute", "Back", "25%", "50%", "75%"};
String[] lightsData= {"Off", "Back", "On"};
String[] keysData= {"asdf", "asdf", "asdf"};

//String[] lightsData= {"1 On", "2 On", "3 On", "Back", "1 Off", "2 Off", "3 Off"};
Ring lights;
Ring home;
Ring outlet;
Ring keyboard;
Ring keys;
Ring stereo;
Ring volume;

float interfaceT = 0;
boolean showInterface = true;
import processing.serial.*;
import cc.arduino.*;
boolean setupInterface; 

boolean useArduino;
Context ctx = ZMQ.context(1);


Arduino arduino;
int r1on = 13;
int r1off = 12;
int r2on = 11;
int r2off = 10;

int SCALE;
float OPTION_RADIUS = 25.0;

void setup() {
    size(displayWidth, displayHeight, P3D);
    SCALE = height *2;
    RG.init(this);
    smooth(8);
    PFont font = loadFont("Roboto-Regular-48.vlw");
    textFont(font, 50);
    Socket subscriber = ctx.socket(ZMQ.SUB);
    subscriber.connect("tcp://127.0.0.1:5000");
    
    subscriber.subscribe(ZMQ.SUBSCRIPTION_ALL);
    

    //socket = context.socket(zmq.SUB)
    //socket.connect("tcp://127.0.0.1:"+port)
    //socket.setsockopt(zmq.SUBSCRIBE, 'gaze_positions')
    //useArduino = true;
   
    //Arduino Setup
    if (useArduino) {
        arduino = new Arduino(this, Arduino.list()[1], 57600);
        arduino.pinMode(r1on, Arduino.OUTPUT);
        arduino.pinMode(r1off, Arduino.OUTPUT);
    }
    
    home = new Ring(homeData, displayWidth, displayHeight);
    lights = new Ring(lightsData, displayWidth, displayHeight);
    stereo = new Ring(stereoData, displayWidth, displayHeight);
    volume = new Ring(volumeData, displayWidth, displayHeight);
    home.selectedElement = "Home";
    //keyboard = new Ring(keyboardData, displayWidth, displayHeight);
    //keys = new Ring(keysData, displayWidth, displayHeight);
}


void draw() {
    translate(width/2, height/2);
    background(100, 100, 100, 255);
    
    blendMode(BLEND);
    strokeWeight(3);
    
    //if (mousePressed) {
    //   println(OPTION_RADIUS);
    //   OPTION_RADIUS = map(mouseX, 0, width, 1, 40);
    //}

    if (showInterface) {
        
        interfaceT = lerp(interfaceT, 1, .06);
        if (interfaceT >= .998) {
            interfaceT = 1;
            showInterface = false;
        }
    }
    scale(interfaceT);
    //scale(.2);
    switch(home.selectedElement) {
        case "TV":
            home.selectedElement = "Home";
            break;
        case "Outlet":
            home.selectedElement = "Home";
            break;            
        case "Lights":
            lights.draw(g); 
            break;
        case "Stereo":
            stereo.draw(g);
            break;
        case "Keyboard":
            if (keys.selectedElement == "") {
                keyboard.draw(g);
            }
            break;
        case "Home":
            home.draw(g);
            break;
        default:
            break;
    }
//"Off", "Back", "On", "Volume"};
    switch(volume.selectedElement) {
        case "Mute":
            launch("/Users/Torin/Documents/2016/Pupil Labs/TAVR_Eye_Tracking_GUI/Volume0.app");
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";
            break;
        case "25%":
            launch("/Users/Torin/Documents/2016/Pupil Labs/TAVR_Eye_Tracking_GUI/Volume25.app");
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";
            break;
        case "50%":
            launch("/Users/Torin/Documents/2016/Pupil Labs/TAVR_Eye_Tracking_GUI/Volume50.app");
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";
            break;
        case "75%":
            launch("/Users/Torin/Documents/2016/Pupil Labs/TAVR_Eye_Tracking_GUI/Volume75.app");
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";
            break;
        case "100%":
            launch("/Users/Torin/Documents/2016/Pupil Labs/TAVR_Eye_Tracking_GUI/Volume100.app");
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";
        case "Back":
            volume.selectedElement = "";
            stereo.selectedElement = "";
            home.selectedElement = "Stereo";            
            break;        
        default:
            break;
    }
    
    switch(stereo.selectedElement) {
        case "Volume":
            volume.draw(g);
            home.selectedElement = "";
            break;
        case "On":
            if (useArduino) {
                arduino.digitalWrite(r2on, Arduino.HIGH);
                delay(100);
                arduino.digitalWrite(r2on, Arduino.LOW); 
            }
            stereo.selectedElement = "";
            home.selectedElement = "Home";
            break;            
        case "Off":
            if (useArduino) {
                arduino.digitalWrite(r2off, Arduino.HIGH);
                delay(100);
                arduino.digitalWrite(r2off, Arduino.LOW); 
            }
            stereo.selectedElement = "";
            home.selectedElement = "Home";
            break;
        case "Back":
            stereo.selectedElement = "";
            home.selectedElement = "Home";
            break;
        default:
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
                home.selectedElement = "Home";
                break;
            case "Off":
                print("1 OFF1");
                if (useArduino) {
                    arduino.digitalWrite(r1off, Arduino.HIGH);
                    delay(100);
                    arduino.digitalWrite(r1off, Arduino.LOW);
                }
                lights.selectedElement = "";
                home.selectedElement = "Home";
                break;
            case "Back":
                lights.selectedElement = "";
                home.selectedElement = "Home";
                break;
            default: break;
        }
    } 
    

    
    
    //this is purely for the keyboard
    //switch(keyboard.selectedElement) {
    //    case "": break;
    //    case "qwert":
    //        String[] keysData = {"q", "w", "e", "r", "t"}; 
    //        keys = new Ring(keysData, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case "yuiop": 
    //        String[] keysData1 = {"y", "u", "i", "o", "p"}; 
    //        keys = new Ring(keysData1, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case "asdfg": 
    //        String[] keysData2 = {"a", "s", "d", "f", "g"}; 
    //        keys = new Ring(keysData2, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case "hjkl": 
    //        String[] keysData3 = {"h", "j", "k", "l"}; 
    //        keys = new Ring(keysData3, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case "zxcv": 
    //        String[] keysData4 = {"z", "x", "c", "v"}; 
    //        keys = new Ring(keysData4, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case "bnm": 
    //        String[] keysData5 = {"b", "n", "m"}; 
    //        keys = new Ring(keysData5, displayWidth, displayHeight);
    //        keys.draw(g);
    //        break;
    //    case ".": break;
    //    case "|_|": break;
    //    default : break;
        
    //}
    
    //switch(keys.selectedElement) {
    //    case "": break;
    //    default: print(keys.selectedElement); 
    //        keys.selectedElement = "";
    //        //keyboard.selectedElement = "";
    //        break;
    //}    
}