// Computes "chain code" to trace edge of a blob.
// This code only traces the first blob found,
// Where "first" is defined as "having a pixel with a lower index" (i.e. higher and to the left).
// For multi-blobs, additional code would be needed to label connected blobs first.
// (See "connected component labelling" or "clustering").
// Note that the code does not find interior (nested) contours.


class Point2d {
  int x, y;
   Point2d () {
    x = 0;
    y = 0;
  }
  Point2d (int inx, int iny) {
    x = inx;
    y = iny;
  }
  void set (int inx, int iny){
     x = inx;
     y = iny;
  }
}

class Rectangle {
  float x; 
  float y; 
  float w; 
  float h; 
}


//===============================================
void drawChainCode() {
  noFill();
  strokeWeight(1);
  stroke(255, 0, 0);
  beginShape();
  for (int i=0; i<chain.size(); i++) {
    Point2d P = (Point2d)chain.get(i);
    vertex(P.x, P.y);
  }
  endShape();
}


//===============================================
void findFirstBlobPixel (color pix[], int pixW, int pixH) {
  boolean foundFirst = false;
  for (int y=0; y<pixH; y++) {
    for (int x=0; x<pixW; x++) {
      color val = pix[y*pixW + x];
      if (!foundFirst && brightness(val) > 0) {
        firstPixel.x = x;
        firstPixel.y = y;
        foundFirst = true;
      }
    }
  }
}

//===============================================
boolean isPixelLocationLegal (int x, int y, int pixW, int pixH) {
  if (x < 0 || x >= pixW) return false;
  if (y < 0 || y >= pixH) return false;
  return true;
}

//===============================================
/*  Compute the chain code of the object beginning at pixel (i,j).
 Return the code as NN integers in the array C.          */
void compute8NeighborChainCode (int i, int j, color pix[], int pixW, int pixH) {
  int val, n, m, q, r, ii, d, dii;
  int lastdir, jj;
  chain.clear();

  // Table given index offset for each of the 8 directions.
  int di[] = {
    0, -1, -1, -1, 0, 1, 1, 1
  };
  int dj[] = {
    1, 1, 0, -1, -1, -1, 0, 1
  };


  val = pix[j*pixW+i]; 
  n = 0; /* Initialize for starting pixel */
  q = i;   
  r = j; 
  lastdir = 4;

  do {
    m = 0;
    dii = -1;  
    d = 100;
    for (ii=lastdir+1; ii<lastdir+8; ii++) {     /* Look for next */
      jj = ii%8;
      if (isPixelLocationLegal (di[jj]+q, dj[jj]+r, pixW, pixH)) {
        if ( pix[(dj[jj]+r)*pixW + (di[jj]+q)] == val) {
          dii = jj;
          m = 1;
          break;
        }
      }
    }

    if (m != 0) { /* Found the next pixel ... */
      Point2d P = new Point2d(q, r);
      chain.add(P);

      q += di[dii];
      r += dj[dii];
      lastdir = (dii+5)%8;
    }
    else {
      break;    /* NO next pixel */
    }
  }
  while ( (q!=i) || (r!=j) );   /* Stop when next to start pixel */
}

