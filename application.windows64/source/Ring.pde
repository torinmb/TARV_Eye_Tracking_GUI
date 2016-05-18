import geomerative.*;

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

    void draw(PGraphics g) {
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
    
    void drawText(int index) {
        int i = index;
        fill(50);
        textSize(25);

        int x1 = getX(i + 1, this.data.length, SCALE);
        int y1 = getY(i + 1, this.data.length, SCALE);
        int x0 = getX(i, this.data.length, SCALE);
        int y0 = getY(i, this.data.length, SCALE);

        float xavg = (x1 + x0) / OPTION_RADIUS;
        float yavg = (y1 + y0) / OPTION_RADIUS;
        float textCenter = textWidth(this.data[i]) / 4.0;
        xavg -= textCenter;
        
        text(this.data[i], xavg - textCenter, yavg);
        strokeWeight(10);
        point(xavg - textCenter, yavg);
        strokeWeight(3);
        noFill();
    }

    int getX(int i, int segments, int size) {
        float index = 1.0 * TWO_PI * i / segments; 
        return round(cos(index ) * size);
    }

    int getY(int i, int segments, int size) {
        float index = 1.0 * TWO_PI * i / segments; 
        return round(sin(index) * size);
    }

    
}