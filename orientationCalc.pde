


//---------------------------------
float getOrientation (ArrayList<Point2d> pts, Point2d COM) {

  float orientation  = 0.0; 
  float orientedness = 0.0;

  if (pts != null) {

    int nPoints = pts.size();
    if (nPoints > 2) {

      //arguments: an array of pixels, the array's width & height, and the location of the center of mass (com).
      //this function calculates the elements of a point set's tensor matrix,
      //calls the function calcEigenvector() to get the best eigenvector of this matrix
      //and returns this eigenVector as a pair of doubles

      //first we look at all the pixels, determine which ones contribute mass (the black ones),
      // and accumulate the sums for the tensor matrix
      float dX, dY; 
      float XXsum, YYsum, XYsum;

      XXsum = 0; 
      YYsum = 0; 
      XYsum = 0; 

      for (int j=0; j<nPoints; j++) {
        Point2d pt = (Point2d) pts.get(j);
        dX = pt.x - COM.x;
        dY = pt.y - COM.y;
        XXsum += dX * dX;
        YYsum += dY * dY;
        XYsum += dX * dY;
      }

      // here's the tensor matrix. 
      // watch out for memory leaks. 
      float matrix2x2[][] = new float[2][2];
      matrix2x2[0][0] =  YYsum;
      matrix2x2[0][1] = -XYsum;
      matrix2x2[1][0] = -XYsum;
      matrix2x2[1][1] =  XXsum;

      // get the orientation of the bounding box
      float[] response = calcEigenvector ( matrix2x2 );
      orientation  = response[0];
      orientedness = response[1];
    }
  }

  // orientedness is calculated but not returned. 
  return orientation;
}

//---------------------------------
float[] calcEigenvector ( float[][] matrix ) {

  //this function takes a 2x2 matrix, and returns a pair of angles which are the eigenvectors
  float A = matrix[0][0]; 
  float B = matrix[0][1];
  float C = matrix[1][0];
  float D = matrix[1][1];

  float multiPartData[] = new float[2]; // watch out for memory leaks. 

  //because we assume a 2x2 matrix,
  //we can solve explicitly for the eigenValues using the Quadratic formula.
  //the eigenvalues are the roots of the equation  det( lambda * I  - T) = 0
  float a, b, c, root1, root2;
  a = 1.0;
  b = (0.0 - A) - D;
  c = (A * D) - (B * C);
  float Q = (b * b) - (4.0 * a * c);
  if (Q >= 0) {
    root1 = ((0.0 - b) + sqrt ( Q)) / (2.0 * a);
    root2 = ((0.0 - b) - sqrt ( Q)) / (2.0 * a);

    //assume x1 and x2 are the elements of the eigenvector.  Then, because Ax1 + Bx2 = lambda * x1, 
    //we know that x2 = x1 * (lambda - A) / B.
    float factor2 = ( min (root1, root2) - A) / B;

    //we arbitrarily set x1 = 1.0 and compute the magnitude of the eigenVector with respect to this assumption
    float magnitude2 = sqrt (1.0 + factor2*factor2);

    //we now find the exact components of the eigenVector by scaling by 1/magnitude
    if ((magnitude2 == 0) || (Float.isNaN(magnitude2))) {
      multiPartData[0] = 0;
      multiPartData[1] = 0;
    } 
    else {
      float orientedBoxOrientation = atan2 ( (1.0 / magnitude2), (factor2 / magnitude2));
      float orientedBoxEigenvalue  = log (1.0+root2); // orientedness
      multiPartData[0] = orientedBoxOrientation;
      multiPartData[1] = orientedBoxEigenvalue;
    }
  } 
  else {
    multiPartData[0] = 0;
    multiPartData[1] = 0;
  }

  return multiPartData;
}



//---------------------------------
Point2d getCentroid (ArrayList<Point2d> pts) {
  float cx = 0; 
  float cy = 0; 
  float ct = 0; 
  int nCentroidPts = 0; 

  if (pts != null) {
    int nPoints = pts.size();

    for (int j=0; j<nPoints; j++) {
      Point2d pt = (Point2d) pts.get(j);
      cx += pt.x;
      cy += pt.y;
      nCentroidPts++;
    }

    if (nCentroidPts > 0) {
      cx /= (float)nCentroidPts;
      cy /= (float)nCentroidPts;
    }
  }
  
  Point2d centroid = new Point2d();
  centroid.set((int)round(cx), (int)round(cy)); 
  return centroid;
}

