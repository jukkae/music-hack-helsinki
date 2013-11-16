/*
 * geokone-globals.pjs: Global variables for GeoKone
 *
 * Copyright (C) 2012 Sakari Lehtonen <sakari@psitriangle.net>
 *
 */

// Not really used now, as noLoop() is called
//
//
public static class GeoKoneGlobals {
  public static final int FPS = 15;

  public static final int OPER_NONE = 0;
  public static final int OPER_ADD = 1;
  public static final int OPER_SUB = 2;
  public static final int OPER_MUL = 4;
  public static final int OPER_DIV = 8;
  public static final int OPER_INV = 16;
  public static final int OPER_SET = 32;

  // Different states of debug, binary boolean operation compatible
  public static final int DEBUG_NONE = 0;
  public static final int DEBUG_CREATE = 1;
  public static final int DEBUG_INIT = 2;
  public static final int DEBUG_LOGIC = 4;
  public static final int DEBUG_STATE = 8;
  public static final int DEBUG_MESSAGES = 16;
  public static final int DEBUG_INPUT = 32;
  public static final int DEBUG_DRAW = 64;
  public static final int DEBUG_DOLOGIC = 128;
  public static final int DEBUG_MATH = 256;

  public static final int DEBUG = 0;
  //public static final int DEBUG = (DEBUG_CREATE | DEBUG_LOGIC | DEBUG_DRAW);
  //public static final int DEBUG = DEBUG_CREATE || DEBUG_LOGIC;

  // Current scene version
  // 0 = before version was introduced
  // 1 = first version with version variable
  // 2 = new node.js server implementation
  public static final int SCENE_VERSION = 3;

  // Canvas dimensions
  public static final int DEF_CANVAS_WIDTH = 1280;
  public static final int DEF_CANVAS_HEIGHT = 720;

  // Viewport dimensions
  public static final int DEF_VIEWPORT_WIDTH = 1680;
  public static final int DEF_VIEWPORT_HEIGHT = 1050;

  // Other dimensions
  public static final int DEF_PARAM_BOX_WIDTH = 270;

  // Scale factor
  public static final float DEF_SCALE_FACTOR = 1.0f;

  // The Golden Ratio, Phi = (1 + sqrt(5)) / 2
  public static final float GOLDEN_RATIO = 1.618033988749895f;

  // Stroke mode conversion tables
  // We do not want to define for each polyform
  public static final char[] gStrokeJoinModes = { 
    PConstants.MITER, PConstants.BEVEL, PConstants.ROUND
  };
  public static final char[] gStrokeCapModes = { 
    PConstants.SQUARE, PConstants.PROJECT, PConstants.ROUND
  };

  public static final int STROKE_JOIN_MITER = 0;
  public static final int STROKE_JOIN_BEVEL = 1;
  public static final int STROKE_JOIN_ROUND = 2;

  public static final int STROKE_CAP_SQUARE = 0;
  public static final int STROKE_CAP_PROJECT = 1;
  public static final int STROKE_CAP_ROUND = 2;

  public final static int PARAM_NONE = 0;
  public final static int PARAM_NUMPOINTS = 1;
  public final static int PARAM_RECURSIONDEPTH = 2;
  public final static int PARAM_CHILDNUMPOINTSRATIO = 4;
  public final static int PARAM_CHILDNUMPOINTSFIXED = 8;
  public final static int PARAM_CHILDRADIUSRATIO = 16;
  public final static int PARAM_RADIUS = 32;
  public final static int PARAM_ANGLE = 64;
  public final static int PARAM_ORIGOX = 128;
  public final static int PARAM_ORIGOY = 256;
  public final static int PARAM_LINEWEIGHT = 512;
  public final static int PARAM_DRAWBASE = 1024;
  public final static int PARAM_DRAWPOINTS = 2048;
  public final static int PARAM_FILLPOINTS = 4096;
  public final static int PARAM_POINTRADIUSRATIO = 8192;
  public final static int PARAM_STROKERATIO = 16384;
  public final static int PARAM_LINECOLOR = 32768;
  public final static int PARAM_POINTCOLOR = 65536;
  public final static int PARAM_STROKECOLOR = 131072;
  public final static int PARAM_DRAWSTROKE = 262144;
  public final static int PARAM_OPACITY = 524288;
  public final static int PARAM_STROKEJOIN = 1048576;
  public final static int PARAM_FILLCOLOR = 2097152;
  public final static int PARAM_FILLSHAPE = 4194304;
  public final static int PARAM_DRAWLINES = 8388608;

  public static boolean gShiftPressed = false;
  public static boolean gControlPressed = false;
  public static boolean gAltPressed = false;

  public static int gLastMoveX = 0; 
  public static int gLastMoveY = 0;

  public static int gLastMoveStepX = 0; 
  public static int gLastMoveStepY = 0;

  public static float gLastAngleStep = 0;

  public static float gLastInputAngleRad = 0;

  // Last popublic static int where the user touched
  public static int gLastTouchX = 0;
  public static int gLastTouchY = 0;

  // The scene path we might possibly be loading
  public static String scenePath;
  // The directory we are exporting images to
  public static String exportDir;
  // The filename we should export the image to
  public static String exportName;

  public static boolean exportImage = false;
  public static boolean exitAfterImageExport = true;
  public static boolean imageExported = false;
  public static boolean interactive = true;
}

