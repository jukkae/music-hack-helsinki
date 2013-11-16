/* PolyForm.pjs:
 *
 * Class representing a circular polygon shape, defined by it's radius and number of points 
 * around the circle.
 *
 * Copyright (C) 2012 Sakari Lehtonen <sakari@psitriangle.net>
 */

import java.util.ArrayList;

public class PolyForm {
  PApplet parent; // The parent PApplet that we will render ourselves onto
  // States

  // Initialize
  final static int STATE_POLYFORM_INIT = 0;
  // Shown, Ready
  final static int STATE_POLYFORM_READY = 1;

  // Polyform is static
  final static int STATE_POLYFORM_STATIC = 2;

  // Polyform is active
  final static int STATE_POLYFORM_ACTIVE = 3;

  final static int MAX_RECURSION_DEPTH = 10;
  final static int MAX_NUM_POINTS_PER_POLY = 16384; // arbitary number for now, TODO

  // Private
  // Current state
  int _state;

  // Active/Being Modified ?
  // For optimization
  boolean _active;

  // Optimization
  float _angleInc;
  float _angleRad;

  // Children polyform
  ArrayList<PolyForm> _children;

  // _cfg points to the Currently Active Polyform settings
  // _cfg can be manipulated between drawing the polyform
  // for changing drawing parameters per state
  PolyFormConfig _cfg;
  PolyFormConfig _parentCfg;
  // The drawing config
  // Is set to either _cfg or _parentCfg
  PolyFormConfig _drawCfg;

  PolyForm(PApplet p) {
    parent = p;
    _cfg = new PolyFormConfig();
  }

  PolyForm(PApplet p, PolyFormConfig config) {
    parent = p;
    _cfg = new PolyFormConfig();
    copyConfigParams(config, _cfg);
  }

  void init(PolyFormConfig parentCfg) {
    _state = STATE_POLYFORM_INIT;
    _active = true;

    _children = null;
    if (parentCfg != null) {
      _parentCfg = parentCfg;
    }
    else {
      _parentCfg = _cfg;
    }

    if (_cfg.recursionDepth > 0) {
      _children = new ArrayList<PolyForm>();
      addChildren(_cfg.numPoints);
    }

    _angleInc = PConstants.TWO_PI / _cfg.numPoints;
    _angleRad = PApplet.radians(_cfg.angleOffset);

    changeState(STATE_POLYFORM_READY);
  }

  void copyConfigParams(PolyFormConfig src, PolyFormConfig dst) {
    dst.numPoints = src.numPoints;
    dst.childNumPointsRatio = src.childNumPointsRatio;
    dst.childNumPointsFixed = src.childNumPointsFixed;

    dst.recursionDepth = src.recursionDepth;

    dst.origoX = src.origoX;
    dst.origoY = src.origoY;

    dst.radius = src.radius;
    dst.childRadiusRatio = src.childRadiusRatio;

    dst.angleOffset = src.angleOffset;

    dst.lineColor = src.lineColor;
    dst.pointColor = src.pointColor;
    dst.fillColor = src.fillColor;
    dst.strokeColor = src.strokeColor;
    dst.opacity = src.opacity;
    dst.lineWeight = src.lineWeight;
    dst.strokeCap = src.strokeCap;
    dst.strokeJoin = src.strokeJoin;
    dst.strokeRatio = src.strokeRatio;

    dst.pointRadius = src.pointRadius;

    dst.pointRadiusRatio = src.pointRadiusRatio;
    dst.drawPoints = src.drawPoints;
    dst.fillPoints = src.fillPoints;
    dst.fillShape = src.fillShape;
    dst.drawBase = src.drawBase;
    dst.drawStroke = src.drawStroke;
    dst.drawLines = src.drawLines;
  }

  PolyFormConfig getConfig() {
    return _cfg;
  }

  void copyValuesFromConfig(PolyFormConfig src) {
    copyConfigParams(src, _cfg);

    // Have to set this as is used in internal calculations
    // normally set from setAngleOffset
    _angleRad = PApplet.radians(_cfg.angleOffset);

    // set numpoints also resets internal variable
    // and re-creates the children
    setNumPoints(_cfg.numPoints);
  }

  void addChildren(int count) {
    PolyFormConfig config;
    PolyForm child;

    // Add count amount of children to this polyform
    for (int i=0; i<count; i++) {
      config = new PolyFormConfig();

      copyConfigParams(_cfg, config);
      inheritParentValuesToConfig(i, config);

      // Create the actual polyform
      child = new PolyForm(parent, config);
      if (child != null) {
        child.init(_parentCfg);
        _children.add(child);
      }
    }
  }

  void setParentConfig(PolyFormConfig parentConfig) {
    _parentCfg = parentConfig;
  }

  // Set initial child values
  void inheritParentValuesToConfig(int index, PolyFormConfig config) {
    // Set radius and pointRadiusRatio based on the ratios
    float r = _cfg.radius / _cfg.childRadiusRatio;
    float pr = _cfg.pointRadius / _cfg.childRadiusRatio;

    // Set number of child points based on the ratio
    int childNumPoints;
    if (_cfg.childNumPointsFixed > 0) {
      childNumPoints = (int)_cfg.childNumPointsFixed;
    }
    else {
      childNumPoints = (int)(_cfg.numPoints * _cfg.childNumPointsRatio);
    }

    config.radius = r;
    config.pointRadius = pr;
    config.numPoints = childNumPoints;

    if (config.recursionDepth > 0) {
      config.recursionDepth = _cfg.recursionDepth - 1;
    }

    // Calculate the child position
    float angle_rad = PApplet.radians(_cfg.angleOffset) + (PConstants.TWO_PI / _cfg.numPoints) * index;
    float x, y;
    x = ((float)PApplet.sin(angle_rad) * _cfg.radius);
    y = ((float)PApplet.cos(angle_rad) * _cfg.radius);
    config.origoX = x;
    config.origoY = y;
  }

  PolyForm getChild(int index) {
    return (PolyForm)_children.get(index);
  }

  float[] getVertexPointAtIndex(int index) {
    float[] vertex = new float[2];
    float angle_rad = PApplet.radians(_cfg.angleOffset) + (PConstants.TWO_PI / _cfg.numPoints) * index;

    float x = ((float)PApplet.sin(angle_rad) * _cfg.radius);
    float y = ((float)PApplet.cos(angle_rad) * _cfg.radius);

    vertex[0] = x;
    vertex[1] = y;

    return vertex;
  }

  void recreateChildren() {
    if (_cfg.recursionDepth > 0) {
      _children = null;
      _children = new ArrayList<PolyForm>();
      addChildren(_cfg.numPoints);
    }
  }

  void setNumPoints(int _numPoints) {
    // Boundaries
    if (_numPoints <= 0) {
      _numPoints = 1;
    } 
    else if (_numPoints > MAX_NUM_POINTS_PER_POLY) {
      _numPoints = MAX_NUM_POINTS_PER_POLY;
    }

    // Set
    _cfg.numPoints= _numPoints;
    _angleInc = PConstants.TWO_PI / _cfg.numPoints;

    println(_cfg.numPoints);

    recreateChildren();
  }

  int getNumPoints() {
    return _cfg.numPoints;
  }

  void setChildNumPointsRatio(float _childNumPointsRatio) {
    if (_childNumPointsRatio <= 0) {
      _childNumPointsRatio = 1;
    }

    _cfg.childNumPointsRatio = _childNumPointsRatio;

    recreateChildren();
  }

  float getChildNumPointsRatio() {
    return _cfg.childNumPointsRatio;
  }

  void setChildNumPointsFixed(float _childNumPointsFixed) {
    if (_childNumPointsFixed < 0) {
      _childNumPointsFixed = 0;
    }

    _cfg.childNumPointsFixed = _childNumPointsFixed;

    recreateChildren();
  }

  float getChildNumPointsFixed() {
    return _cfg.childNumPointsFixed;
  }

  void setRadius(float _radius) {
    _cfg.radius = _radius;
    recreateChildren();
  }

  float getRadius() {
    return _cfg.radius;
  }

  float getWidth() {
    return _cfg.radius*2;
  }

  float getHeight() {
    return _cfg.radius*2;
  }

  void setPos(float _origoX, float _origoY) {
    _cfg.origoX = _origoX;
    _cfg.origoY = _origoY;
  }

  void setOrigoX(float _origoX) {
    _cfg.origoX = _origoX;
  }

  float getOrigoX() {
    return _cfg.origoX;
  }

  void setOrigoY(float _origoY) {
    _cfg.origoY = _origoY;
  }

  float getOrigoY() {
    return _cfg.origoY;
  }

  void setAngleOffset(float _angleOffset)
  {
    _cfg.angleOffset = _angleOffset;
    _angleRad = PApplet.radians(_angleOffset);

    recreateChildren();
  }

  float getAngleOffset() {
    return _cfg.angleOffset;
  }

  void setChildRadiusRatio(float _childRadiusRatio)
  {
    _cfg.childRadiusRatio = _childRadiusRatio;
    recreateChildren();
  }

  float getChildRadiusRatio() {
    return _cfg.childRadiusRatio;
  }

  void setPointRadiusRatio(float _pointRadiusRatio)
  {
    if (_pointRadiusRatio == 0 || _pointRadiusRatio < 0) {
      _pointRadiusRatio = 1;
    }

    _cfg.pointRadiusRatio = _pointRadiusRatio;
  }

  float getPointRadiusRatio() {
    return _cfg.pointRadiusRatio;
  }

  void setRecursionDepth(int _recursionDepth)
  {
    if (_recursionDepth <= 0) {
      _recursionDepth = 0;
    }

    // Limit the recursion depth based on the number of children
    // so that browser doesn't hopefully crash so easily
    int totalNumPoints = (int)Math.pow(_cfg.numPoints, _recursionDepth);
    if (totalNumPoints <= MAX_NUM_POINTS_PER_POLY) {
      _cfg.recursionDepth = _recursionDepth;
    }

    recreateChildren();
  }

  int getRecursionDepth() {
    return _cfg.recursionDepth;
  }

  // This sets the strokeJoin from int to processign variable
  // The integer value is stored in the database
  // But for drawing purposes we must use the string variable name
  // We translate here in order to prevent runtime decision and string comparison
  //
  // So, when the strokeJoin variable is set, it is set from integer
  // and stored internally as "butt", "cap", "round"
  //
  // When we get this variable name, it is also returned as integer
  // Actually the proces(float)PApplet.sing is done on the javascript side
  void setStrokeJoin(int _strokeJoin) {
    _cfg.strokeJoin = _strokeJoin;

    // set stroke cap to Round if strokeJoin is Round
    if (_cfg.strokeJoin == GeoKoneGlobals.STROKE_JOIN_ROUND) {
      _cfg.strokeCap = GeoKoneGlobals.STROKE_CAP_ROUND;
    } 
    else {
      _cfg.strokeCap = GeoKoneGlobals.STROKE_CAP_SQUARE;
    }
  }

  int getStrokeJoin() {
    return _cfg.strokeJoin;
  }

  void setStrokeRatio(float _strokeRatio) {
    if (_strokeRatio < 0) {
      _strokeRatio = 0;
    }

    _cfg.strokeRatio = _strokeRatio;
  }

  float getStrokeRatio() {
    return _cfg.strokeRatio;
  }

  // TODO: figure out a better way to propagate the changes to the children
  // Maybe we can set a parent class and get the value from the parent directly ..
  void setLineWeight(float _lineWeight) {
    if (_lineWeight <= 0) {
      _lineWeight = 1.0f;
    }

    _cfg.lineWeight = _lineWeight;
  }

  float getLineWeight() {
    return _cfg.lineWeight;
  }

  void setLineColor(int _lineColor) {
    // Only set if changed
    if (_cfg.lineColor != _lineColor) {
      _cfg.lineColor = _lineColor;
    }
  }

  int getLineColor() {
    return _cfg.lineColor;
  }

  void setPointColor(int _pointColor) {
    _cfg.pointColor = _pointColor;
  }

  int getPointColor() {
    return _cfg.pointColor;
  }

  void setFillColor(int _fillColor) {
    _cfg.fillColor = _fillColor;
  }

  int getFillColor() {
    return _cfg.fillColor;
  }

  void setStrokeColor(int _strokeColor) {
    _cfg.strokeColor = _strokeColor;
  }

  int getStrokeColor() {
    return _cfg.strokeColor;
  }

  void setOpacity(int _opacity) {
    if (_opacity > 255) {
      _opacity = 255;
    } 
    else if (_opacity < 0) {
      _opacity = 0;
    }
    _cfg.opacity = _opacity;
  }

  int getOpacity() {
    return _cfg.opacity;
  }

  void toggleDrawPoints() {
    _cfg.drawPoints = !_cfg.drawPoints;
  }

  void toggleDrawBase() {
    _cfg.drawBase = !_cfg.drawBase;
  }

  void toggleStroke() {
    _cfg.drawStroke = !_cfg.drawStroke;
  }

  void toggleDrawLines() {
    _cfg.drawLines = !_cfg.drawLines;
  }

  void toggleFillPoints() {
    _cfg.fillPoints = !_cfg.fillPoints;
  }

  void toggleFillShape() {
    _cfg.fillShape = !_cfg.fillShape;
  }

  // If polyform is active, it is being actively modified
  // If it is not active, we don't have to re-draw it, it is static
  boolean isActive() {
    return _active;
  }

  boolean isStatic() {
    return !_active;
  }

  // Set 
  void setActive() {
    _active = true;
  }

  void setStatic() {
    _active = false;
  }

  void _drawPolygon() {
    float x, y;

    if (_drawCfg.drawLines == true) {
      strokeWeight(_drawCfg.lineWeight);
      stroke(_drawCfg.lineColor, _drawCfg.opacity);
    } 
    else {
      noStroke();
    }

    // Fill shape ?
    if (_drawCfg.fillShape == true) {
      fill(_drawCfg.fillColor, _drawCfg.opacity);
    } 
    else {
      noFill();
    }

    beginShape();
    // Draw all the vertex points and lines between them
    for (int i=0; i<_cfg.numPoints; i++) {
      // Calculate vertex
      x = ((float)PApplet.sin(_angleRad) * _cfg.radius);
      y = ((float)PApplet.cos(_angleRad) * _cfg.radius);

      // Plot
      vertex(x, y);

      // Increase angle
      _angleRad = _angleRad + _angleInc;
    }
    endShape(PConstants.CLOSE);
  }

  void _drawStroke() {
    float x, y;

    float weight = _drawCfg.lineWeight + 
      (_drawCfg.lineWeight * _drawCfg.strokeRatio);
    strokeWeight(weight);
    noFill();
    stroke(_drawCfg.strokeColor, _drawCfg.opacity);

    beginShape();

    for (int i=0; i<_cfg.numPoints; i++) {
      x = ((float)PApplet.sin(_angleRad) * _cfg.radius);
      y = ((float)PApplet.cos(_angleRad) * _cfg.radius);
      vertex(x, y);

      _angleRad = _angleRad + _angleInc;
    }

    endShape(PConstants.CLOSE);
  }

  void _drawPoints() {
    float x, y;
    float pr;

    // Calc point radius
    pr = _cfg.radius / _drawCfg.pointRadiusRatio;
    if (pr < 0) {
      pr = 1.0f;
    }

    strokeWeight(_drawCfg.lineWeight);
    stroke(_drawCfg.lineColor, _drawCfg.opacity);

    // Fill points ?
    if (_drawCfg.fillPoints == true) {
      fill(_drawCfg.pointColor, _drawCfg.opacity);
    } 
    else {
      noFill();
    }

    for (int i=0; i<_cfg.numPoints; i++) {
      // Calculate vertex
      x = ((float)PApplet.sin(_angleRad) * _cfg.radius);
      y = ((float)PApplet.cos(_angleRad) * _cfg.radius);

      ellipse(x, y, pr, pr);

      // Increase angle
      _angleRad = _angleRad + _angleInc;
    }
  }

  void _drawFeatures() {		
    // Set drawing attributes
    if (_drawCfg.drawStroke == true && _drawCfg.drawLines == true) {
      _drawStroke();
    }

    // Line attributes
    if (_drawCfg.drawLines == true || _drawCfg.fillShape == true) {
      _drawPolygon();
    }

    if (_drawCfg.drawPoints == true) {
      _drawPoints();
    }
  }

  void _drawPolyForms() {
    PolyForm poly;
    float pointRadius;

    // If number of points below 1, only draw center point
    // This is to prevent drawing bugs when no of points 
    // below 1 with drawPolygon etc
    if (_cfg.numPoints <= 1) {
      pointRadius = _cfg.radius / _drawCfg.pointRadiusRatio;
      if (pointRadius < 0) {
        pointRadius = 1.0f;
      }

      // Fill points ?
      if (_drawCfg.fillPoints == true) {
        fill(_drawCfg.pointColor, _drawCfg.opacity);
      } 
      else {
        noFill();
      }

      ellipse(0, 0, pointRadius, pointRadius);

      return;
    }

    // We have to convert the integer strokeCap and strokeJoin
    // to processing.js string variables
    //strokeCap(GeoKoneGlobals.gStrokeCapModes[_drawCfg.strokeCap]);
    //strokeJoin(GeoKoneGlobals.gStrokeJoinModes[_drawCfg.strokeJoin]);

    // recursionDepth of 0 means that this poly is the last of the children
    // or that it doesn't have any children at all
    if (_cfg.recursionDepth == 0) {
      _drawFeatures();
    } 
    else {
      // If we have recursion depth
      // Base needs to be drawn before the children
      if (_drawCfg.drawBase == true) {
        _drawFeatures();
      }

      // Else draw only the children
      if (_children != null) {
        for (int i=0; i<_cfg.numPoints; i++) {
          try {
            poly = (PolyForm)_children.get(i);
          } 
          catch (IndexOutOfBoundsException e) {
            return;
          }
          poly.doDraw();
        }
      }
    }
  }

  void doDraw() {
    // Draw only if ready
    if (_state != STATE_POLYFORM_READY) {
      return;
    }

    // Figure out if we have a parent
    // If we do, inherit the drawing properties from the 
    // parent (colors, line weight, etc)
    // All settings which do not require re-creating the geometry
    if (_parentCfg != null) {
      _drawCfg = _parentCfg;
    } 
    else {
      _drawCfg = _cfg;
    }

    // Assign drawing context
    pushMatrix();
    translate(_cfg.origoX, _cfg.origoY);
    _drawPolyForms();
    popMatrix();
  }

  void changeState(int next_state) {
    _state = next_state;
  }
}

