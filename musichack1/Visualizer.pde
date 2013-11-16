class Visualizer {
  // Polyform stuff
  PolyFormConfig polyConfig;
  PolyForm poly;
  int screenWidth;
  int screenHeight;

  void init(musichack1 parent, int w, int h) {
    screenWidth = w;
    screenHeight = h;
    
    poly = new PolyForm(parent);
    poly.init(null);
    poly.setNumPoints(6);
    poly.setChildNumPointsRatio(6);
    poly.setRecursionDepth(1);
  }

  void drawWaveforms(AudioOutput out) {
    float bufSize = out.bufferSize();
    float stepX = screenWidth / bufSize;
    float stepY = screenHeight / bufSize;
    float offsetX = 0;
    float offsetY = 64;
    float x1, y1;
    float x2, y2;

    // So we want to draw the lines
    // In screenWidth / 1024.0 steps
    for (int i = 0; i < out.bufferSize() - 1; i++)
    {
      x1 = offsetX + i * stepX;
      y1 = offsetY + out.left.get(i)*stepX*50;
      x2 = offsetX + (i+1)*stepX;
      y2 = offsetY + out.left.get(i+1)*stepX*50;
      line (x1, y1, x2, y2);
      y1 = offsetY*2 + out.right.get(i)*stepX*50;
      y2 = offsetY*2 + out.right.get(i+1)*stepX*50;
      line (x1, y1, x2, y2);
    }
  }

  void drawPoly(int beat, int elapsedFrames) {
    float radius = (8 * beat+16) + ((float)PApplet.sin(elapsedFrames / 512.0)) * 32.0;
    poly.setRadius(radius);
    poly.doDraw();
  }

  void doDraw(int beat, int elapsedFrames, AudioOutput out) {
    drawWaveforms(out);
    drawPoly(beat, elapsedFrames);
  }
}

