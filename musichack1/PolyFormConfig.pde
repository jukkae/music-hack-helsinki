/* PolyForm.pjs:
 *
 * Class representing a PolyForm config
 *
 * Copyright (C) 2012 Sakari Lehtonen <sakari@psitriangle.net>
 */

// Parameter IDs
// Let's try binary logic compatible ..
// maybe this way we can pack the scene somehow tighter

public class PolyFormConfig
{
  int recursionDepth;

  float origoX;
  float origoY;

  float radius;
  float childRadiusRatio;

  float angleOffset;

  int numPoints;
  float childNumPointsRatio;
  float childNumPointsFixed;

  float lineWeight;
  float strokeRatio;

  int strokeCap;
  int strokeJoin;
  int lineColor;
  int pointColor;
  int fillColor;
  int strokeColor;
  int opacity;

  boolean drawPoints;
  boolean fillPoints;
  boolean fillShape;
  boolean drawBase;
  boolean drawStroke;
  boolean drawLines;

  float pointRadius;
  float pointRadiusRatio;

  PolyFormConfig() {
    // Default values
    origoX = (float)GeoKoneGlobals.DEF_CANVAS_WIDTH/2;
    origoY = (float)GeoKoneGlobals.DEF_CANVAS_HEIGHT/2;

    lineColor = GeoKoneColors.COLOR_WHITE;
    strokeColor = GeoKoneColors.COLOR_YELLOW;
    pointColor = GeoKoneColors.COLOR_WHITE;
    fillColor = GeoKoneColors.COLOR_WHITE;
    opacity = GeoKoneColors.OPACITY_OPAQUE;

    numPoints = 3;
    childNumPointsRatio = 1;
    childNumPointsFixed = 0;

    recursionDepth = 1;

    radius = 64;
    childRadiusRatio = 1.0f;

    pointRadiusRatio = GeoKoneGlobals.GOLDEN_RATIO * 8;
    pointRadius = radius / pointRadiusRatio;

    angleOffset = 60.0f;

    lineWeight = 1.5f;
    strokeJoin = GeoKoneGlobals.STROKE_JOIN_MITER;
    strokeCap = GeoKoneGlobals.STROKE_CAP_SQUARE;
    strokeRatio = GeoKoneGlobals.GOLDEN_RATIO * 2;

    drawPoints = false;
    fillPoints = true;
    fillShape = false;
    drawBase = false;
    drawStroke = false;
    drawLines = true;
  }

  // Copy from existing config
  // This is called currently everytime some config parameter
  // is changed
  PolyFormConfig(PolyFormConfig config) {
    // Set some default values
    origoX = config.origoX;
    origoY = config.origoY;

    lineColor = config.lineColor;
    pointColor = config.pointColor;
    fillColor = config.fillColor;
    strokeColor = config.strokeColor;
    opacity = config.opacity;

    numPoints = config.numPoints;
    childNumPointsRatio = config.childNumPointsRatio;
    childNumPointsFixed = config.childNumPointsFixed;

    recursionDepth = config.recursionDepth;
    pointRadius = config.pointRadius;

    radius = config.radius;
    childRadiusRatio = config.childRadiusRatio;

    angleOffset = config.angleOffset;

    lineWeight = config.lineWeight;
    strokeRatio = config.strokeRatio;
    strokeCap = config.strokeCap;
    strokeJoin = config.strokeJoin;

    drawPoints = config.drawPoints;
    fillPoints = config.fillPoints;
    fillShape = config.fillShape;
    drawBase = config.drawBase;
    drawStroke = config.drawStroke;
    drawLines = config.drawLines;

    pointRadiusRatio = config.pointRadiusRatio;
  }
}

