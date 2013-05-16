
void rotateContour (ArrayList<Point2d> pts, Point2d COM, float angle) {
  //rotates the snoog by the angle: orientationAngle 
  int nPoints = pts.size();

  float newX, newY; 
  for (int i=0; i<nPoints; i++) {
    
    Point2d pt = (Point2d) pts.get(i);
    //translate the point so that its center is on the origin
    pt.x = pt.x - COM.x;
    pt.y = pt.y - COM.y;
    //rotate the point
    newX = (pt.x * cos(angle)) - (pt.y * sin(angle));
    newY = (pt.x * sin(angle)) + (pt.y * cos(angle));
    //translate the point back
    pt.x = (int)round(newX + COM.x);
    pt.y = (int)round(newY + COM.y);
    
    //clobber the point in the vector with the new value
    //pts.setElementAt(pt, i);
  }
}


Rectangle getContourDimensions (ArrayList<Point2d> pts) {
  //assumes pts has been re-oriented so that the shoe is up-and-down
  int nPoints = pts.size();
  
  float mostRight  = -99999;
  float mostLeft   =  99999; 
  float mostTop    =  99999; 
  float mostBottom = -99999;

  Rectangle rec = new Rectangle(); 
  for (int i=0; i<nPoints; i++) {
    
    Point2d pt = (Point2d) pts.get(i);
    float px = pt.x; 
    float py = pt.y; 
    
    if (px < mostLeft){
      mostLeft = px;
    }
    if (px > mostRight){
      mostRight = px;
    }
    
    if (py < mostTop){
      mostTop = py;
    }
    if (py > mostBottom){
      mostBottom = py;
    }
  }
  
  rec.x = mostLeft;
  rec.y = mostTop; 
  rec.w = mostRight - mostLeft;
  rec.h = mostBottom - mostTop;
  
  return rec; 
}
