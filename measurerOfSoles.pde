import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import java.util.*;

String shoeDefaultImageFilename;
String shoeImageFilename;
PImage shoeImage; 
boolean bShoeImageLoaded; 

PImage binarizedShoeImage;
color black = color (0); 
color white = color (255); 

Point2d firstPixel;
Point2d shoeCentroid; 
Rectangle boundaryRect;
float shoeOrientation; 
ArrayList<Point2d> chain;
ImageInfo II; 
int theDpiValue = -1;

//---------------------------------------------------------------------
void setup() {
  loadShoeImage(); 

  int w = 256; 
  int h = 256; 
  if ((shoeImage != null) && (shoeImage.width > 0)) {
    bShoeImageLoaded = true;
    w = shoeImage.width;
    h = shoeImage.height;
    binarizedShoeImage = createImage (w, h, RGB);
  }
  size (w, h);
  noLoop();

  firstPixel = new Point2d(0, 0);
  chain = new ArrayList<Point2d>();
  process();
} 

//---------------------------------------------------------------------
void process() {
  if (bShoeImageLoaded) {

    // clean up the image of the shoe sole tracing
    binarizeShoeImage(); 
    color pix[] = binarizedShoeImage.pixels;
    int pixW = binarizedShoeImage.width;
    int pixH = binarizedShoeImage.height;

    // trace the contour of the shoe sole tracing
    findFirstBlobPixel (pix, pixW, pixH);
    compute8NeighborChainCode (firstPixel.x, firstPixel.y, pix, pixW, pixH);

    // Compute the oriented bounding rectangle of the shoe tracing
    shoeCentroid = getCentroid (chain); 
    shoeOrientation = getOrientation (chain, shoeCentroid);
    rotateContour (chain, shoeCentroid, shoeOrientation);
    boundaryRect = getContourDimensions (chain);

    // Extract the dimensions of the shoe's boundary rectangle, in inches
    int DPI = (theDpiValue > 0) ? theDpiValue : 72; 
    float shoeLength = max(boundaryRect.w, boundaryRect.h) / (float) DPI; 
    float shoeWidth  = min(boundaryRect.w, boundaryRect.h) / (float) DPI; 
    
    if (theDpiValue == -1){
      println("Caution: assuming image resolution is 72 DPI!"); 
    }
    println("Shoe Length (inches) = " + shoeLength); 
    println("Shoe Width  (inches) = " + shoeWidth);
  }
}

//---------------------------------------------------------------------
void draw() {
  background(128); 

  if (bShoeImageLoaded) {
    image (binarizedShoeImage, 0, 0);

    noFill();
    smooth(); 
    stroke (255, 0, 0); 

    drawChainCode();
    ellipse (shoeCentroid.x, shoeCentroid.y, 30, 30); 

    // draw the orientation axis of the shoe sole tracing
    float dx = 100 * sin(shoeOrientation); 
    float dy = 100 * cos(shoeOrientation); 
    line (shoeCentroid.x, shoeCentroid.y, shoeCentroid.x + dx, shoeCentroid.y + dy); 
  
    // draw the boundary rectangle of the reoriented shoe
    noSmooth();
    stroke (0, 200, 0); 
    rect (boundaryRect.x, boundaryRect.y, boundaryRect.w, boundaryRect.h);
  }
}

//---------------------------------------------------------------------
void loadShoeImage() {
  bShoeImageLoaded = false;
  shoeDefaultImageFilename = sketchPath + "/data/" + "shoe-72dpi.jpg";
  shoeImageFilename = getUserSelectedImageFilename(); // See FileLoading.pde
  shoeImage = loadImage (shoeImageFilename);
  theDpiValue = getImageDpi (shoeImageFilename); 
}

//---------------------------------------------------------------------
int getImageDpi(String filename){
  // if possible, extract the DPI of the image. See imageInfo.pde
  int result = -1;
  II = new ImageInfo();
  InputStream inStream = null;
  try {
    inStream = new FileInputStream (filename);
    boolean bVerbose = true;
    II.setDetermineImageNumber(false);
    II.run(shoeImageFilename, inStream, II, bVerbose);
    result = II.getPhysicalWidthDpi();
    println ("-----------------------------");
    println ("DPI VALUE = " + theDpiValue);
    inStream.close();
  } 
  catch (IOException e) {
    System.out.println(e);
    try {
      inStream.close();
    } 
    catch (IOException ee) {
    }
  }
  return result; 
}

//---------------------------------------------------------------------
void binarizeShoeImage() {
  if (bShoeImageLoaded) {

    int threshold = 127; 
    int nPixels = shoeImage.width  * shoeImage.height;
    color originalPixels[] = shoeImage.pixels; 

    binarizedShoeImage.loadPixels();
    for (int i=0; i<nPixels; i++) {
      float val = brightness( originalPixels[i] ); 
      binarizedShoeImage.pixels[i] = (val < threshold) ? white : black;
    }
    binarizedShoeImage.updatePixels();
  }
}

//---------------------------------------------------------------------

