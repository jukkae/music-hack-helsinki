class Visualizer {
  AudioOutput out;
  
  // Polyform stuff
  PolyFormConfig polyConfig;
  PolyForm poly;
  int screenWidth;
  int screenHeight;
  int elapsedFrames;
  int numPolyPoints;
  int lastBeat;
  int pointsDir;
  int beatCounter;
  float modAmt;
  float modFreq;

  void init(musichack1 parent, AudioOutput _out, int w, int h) {
    out = _out;
    screenWidth = w;
    screenHeight = h;
    numPolyPoints = 3;

    poly = new PolyForm(parent);
    poly.init(null);
    poly.setNumPoints(numPolyPoints);
    poly.setChildNumPointsRatio(1);
    poly.setRecursionDepth(2);
    poly.setOpacity(128);
    pointsDir = 1;
    beatCounter = 0;
    
    modAmt = 0.0f;
    modFreq = 0.0f;
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
  
  void setModAmt(float _modAmt) {
    modAmt = _modAmt;
  }
  
  void setModFreq(float _modFreq) {
    modFreq = _modFreq;
  }
  
  void setPolyColor(color c) {
    poly.setLineColor(c);
  }
  
  void drawPoly(int beat) {
    //float radius = (8 * beat+16) + ((float)PApplet.sin(elapsedFrames / 512.0)) * 32.0;
    float childRatio = (0.025 * beat+1) + ((float)PApplet.cos(elapsedFrames / 256.0) * (float)PApplet.sin(elapsedFrames/128.0)) * 0.618 * (modAmt / 100.0);
    float angle = ((float)PApplet.cos(elapsedFrames / 256.0)) * 128.0;
    float radius = 32.0 + (screenWidth / modAmt)/4.0;
        
    poly.setAngleOffset(angle);
    //poly.setRadius(radius);
    poly.setChildRadiusRatio(childRatio);
    //poly.setChildNumPointsRatio(childNumPointsRatio);
    
    poly.doDraw();
  }

  void doDraw(int beat, int _elapsedFrames) {
    elapsedFrames = _elapsedFrames;

    if (beat != lastBeat) {
      beatCounter += 1;
      if (beatCounter >= 8) {
        numPolyPoints += pointsDir;
        if (numPolyPoints >= 12 || numPolyPoints <= 3) {
          pointsDir = -pointsDir;
        }
        poly.setNumPoints(numPolyPoints);
        beatCounter = 0;
      }
    } 
    lastBeat = beat;

    drawWaveforms();
    drawPoly(beat);
  }
}

