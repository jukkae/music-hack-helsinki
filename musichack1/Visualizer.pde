class Visualizer {
  AudioOutput out;
  
  // Polyform stuff
  PolyFormConfig polyConfig;
  PolyForm poly;
  PolyForm poly1;
  PolyForm poly2;
 
  int screenWidth;
  int screenHeight;
  int elapsedFrames;
  int numPolyPoints;
  int lastBeat;
  int pointsDir;
  int beatCounter;
  float modAmt;
  float modFreq;
  ArrayList<PolyForm> polys;
  int [] polyColors;
  int [] originalRadius;
  int numPolys;
  
  int kickCounter;
  
  PenroseLSystem ds;
  boolean dsResetted;
    
  int [] rainbowPattern = { GeoKoneColors.COLOR_WIPHALA_RED, GeoKoneColors.COLOR_WIPHALA_ORANGE, GeoKoneColors.COLOR_WIPHALA_YELLOW, GeoKoneColors.COLOR_WIPHALA_BLUE };

  void init(musichack1 parent, AudioOutput _out, int w, int h) {
    polys = new ArrayList();
    numPolys = 3;
    polyColors = new int[numPolys];
    originalRadius = new int[numPolys];
    kickCounter = 0;
    
    out = _out;
    screenWidth = w;
    screenHeight = h;
    numPolyPoints = 3;

    // middle poly
    poly = new PolyForm(parent);
    poly.init(null);
    poly.setNumPoints(13);
    poly.setRecursionDepth(1);
    poly.setChildRadiusRatio(0.5);
    poly.setChildNumPointsRatio(1);
    poly.setRadius(96);
    originalRadius[0] = 96;
    polyColors[0] = 0;
    
    polys.add(poly);
    
    // inner poly
    poly = new PolyForm(parent);
    poly.init(null);
    poly.setNumPoints(11);
    poly.setChildNumPointsRatio(1);
    poly.setRecursionDepth(1);
    poly.setRadius(46);
    originalRadius[1] = 46;

    poly.setChildRadiusRatio(0.95);
    poly.setAngleOffset(-2119);
    polyColors[1] = 1;

    
    polys.add(poly);

    poly = new PolyForm(parent);
    poly.init(null);
    poly.setNumPoints(32);
    poly.setRadius(168);
    originalRadius[2] = 168;

    poly.setAngleOffset(145);
    poly.setChildNumPointsRatio(3);
    poly.setChildRadiusRatio(0.355);
    poly.setRecursionDepth(1);
    poly.setLineWeight(1.5);
    polyColors[2] = 2;
    
    polys.add(poly);
    
    pointsDir = 1;
    beatCounter = 0;

    modAmt = 0.0f;
    modFreq = 0.0f;
    
      //Penrose
  ds = new PenroseLSystem();
  ds.simulate(4);
  dsResetted = false;
  }

  void drawWaveforms() {
    float bufSize = out.bufferSize();
    float stepX = screenWidth / bufSize;
    float stepY = screenHeight / bufSize;
    float offsetX = 0;
    float offsetY = 550;
    float x1, y1;
    float x2, y2;
    float mul = 96;
    float sepY = 64;

    // So we want to draw the lines
    // In screenWidth / 1024.0 steps
    for (int i = 0; i < out.bufferSize() - 1; i++)
    {
      x1 = offsetX + i * stepX;
      y1 = offsetY + out.left.get(i)*stepX*mul;
      x2 = offsetX + (i+1)*stepX;
      y2 = offsetY + out.left.get(i+1)*stepX*mul;
      line (x1, y1, x2, y2);
      y1 = offsetY + sepY + out.right.get(i)*stepX*mul;
      y2 = offsetY + sepY + out.right.get(i+1)*stepX*mul;
      line (x1, y1, x2, y2);
    }
  }
  
  // Set poly colors like this:
  // Have a rainbow pattern we want to cycle through all the polys
  // We want to cycle the colors in our polys like this
  
  // on every call of this
  // we cycle the color of each poly to the next in the rainbowColors array
  // If we hit the limit
  // we set it back to 0
  
  // need to store the current color from the array
  
  void cyclePolyColors() {
    PolyForm poly;
    int idx;
    color c;
    for (int i=0; i<numPolys; i++) {
      idx = polyColors[i];
      idx += 1;
      if (idx >= rainbowPattern.length) {
        idx = 0;
      }
      
      polyColors[i] = idx;
      c = color(rainbowPattern[idx]);
      poly = polys.get(i);
      poly.setLineColor(c);
    }
  }
  
  void triggerKick() {
    kickCounter = 12;
  }
  
  void setModAmt(float _modAmt) {
    modAmt = _modAmt;
  }
  
  void setModFreq(float _modFreq) {
    modFreq = _modFreq;
  }
  
  void setPolyColor(color c) {
    //poly.setLineColor(c);
  }
  
  void drawPoly(int beat) {
    PolyForm poly;
    //float radius = (8 * beat+16) + ((float)PApplet.sin(elapsedFrames / 512.0)) * 32.0;
    //float childRatio = (0.025 * beat+1) + ((float)PApplet.cos(elapsedFrames / 256.0) * (float)PApplet.sin(elapsedFrames/128.0)) * 0.618 * (modAmt / 100.0);
    float angle = ((float)PApplet.cos(elapsedFrames / 256.0)) * 256.0 + beat*32.0;
    float radius; 
        
    //poly.setAngleOffset(angle);
    //poly.setRadius(radius);
    //poly.setChildRadiusRatio(childRatio);
    //poly.setChildNumPointsRatio(childNumPointsRatio);
    
    for (int i=0; i<polys.size(); i++) {
      poly = polys.get(i);
      if (i%1 == 0) {
        angle = -angle;
      }
      radius = originalRadius[i] + kickCounter;
      
      poly.setAngleOffset(angle);
      poly.setRadius(radius);
      poly.doDraw();
    }    
  }

  void doDraw(int beat, int _elapsedFrames) {
    elapsedFrames = _elapsedFrames;
    kickCounter = kickCounter - 1;
    if (kickCounter < 0) {
      kickCounter = 0;
    }

    if (beat != lastBeat) {
      if (dsResetted == true) {
        ds.simulate(4);
        dsResetted = false;
      }
      
      beatCounter += 1;
      if (beatCounter >= 16) {
        //ds.simulate(4);
        
        ds.reset();
        dsResetted = true;

        numPolyPoints += pointsDir;
        if (numPolyPoints >= 12 || numPolyPoints <= 3) {
          pointsDir = -pointsDir;
        }
        //poly.setNumPoints(numPolyPoints);
        beatCounter = 0;
      }
    } 
    lastBeat = beat;

    drawWaveforms();
    drawPoly(beat);
    ds.render();
  }
}

