/*
 * ImageInfo.java
 *
 * Version 1.7
 *
 * A Java class to determine image width, height and color depth for a number of image file formats.
 *
 * Written by Marco Schmidt 
 *
 * Contributed to the Domain.
 */

import java.io.DataInput;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Vector;

/**
 * Get file format, image resolution, number of bits per pixel and optionally 
 * number of images, comments and physical resolution from 
 * JPEG, GIF, BMP, PCX, PNG, IFF, RAS, PBM, PGM, PPM and PSD files (or input streams).
 * <p>
 * Use the class like this:
 * <pre>
 * ImageInfo ii = new ImageInfo();
 * ii.setInput(in); // in can be InputStream or RandomAccessFile
 * ii.setDetermineImageNumber(true); // default is false
 * ii.setCollectComments(true); // default is false
 * if (!ii.check()) {
 *   System.err.println("Not a supported image file format.");
 *   return;
 * }
 * System.out.println(ii.getFormatName() + ", " + ii.getMimeType() + 
 *   ", " + ii.getWidth() + " x " + ii.getHeight() + " pixels, " + 
 *   ii.getBitsPerPixel() + " bits per pixel, " + ii.getNumberOfImages() +
 *   " image(s), " + ii.getNumberOfComments() + " comment(s).");
 *  // there are other properties, check out the API documentation
 * </pre>
 * You can also use this class as a command line program.
 * Call it with a number of image file names and URLs as parameters:
 * <pre>
 *   java ImageInfo *.jpg *.png *.gif http://somesite.tld/image.jpg
 * </pre>
 * or call it without parameters and pipe data to it:
 * <pre>
 *   java ImageInfo &lt; image.jpg  
 * </pre>
 * <p>
 * Known limitations:
 * <ul>
 * <li>When the determination of the number of images is turned off, GIF bits 
 *  per pixel are only read from the global header.
 *  For some GIFs, local palettes change this to a typically larger
 *  value. To be certain to get the correct color depth, call
 *  setDetermineImageNumber(true) before calling check().
 *  The complete scan over the GIF file will take additional time.</li>
 * <li>Transparency information is not included in the bits per pixel count.
 *  Actually, it was my decision not to include those bits, so it's a feature! ;-)</li>
 * </ul>
 * <p>
 * Requirements:
 * <ul>
 * <li>Java 1.1 or higher</li>
 * </ul>
 * <p>
 * The latest version can be found at <a href="http://schmidt.devlib.org/image-info/">http://schmidt.devlib.org/image-info/</a>.
 * <p>
 * Written by Marco Schmidt.
 * <p>
 * This class is contributed to the Domain.
 * Use it at your own risk.
 * <p>
 * Last modification 2005-07-26.
 * <p>
 * <a name="history">History</a>:
 * <ul>
 * <li><strong>2001-08-24</strong> Initial version.</li>
 * <li><strong>2001-10-13</strong> Added support for the file formats BMP and PCX.</li>
 * <li><strong>2001-10-16</strong> Fixed bug in read(int[], int, int) that returned
 * <li><strong>2002-01-22</strong> Added support for file formats Amiga IFF and Sun Raster (RAS).</li>
 * <li><strong>2002-01-24</strong> Added support for file formats Portable Bitmap / Graymap / Pixmap (PBM, PGM, PPM) and Adobe Photoshop (PSD).
 *   Added new method getMimeType() to return the MIME type associated with a particular file format.</li>
 * <li><strong>2002-03-15</strong> Added support to recognize number of images in file. Only works with GIF.
 *   Use {@link #setDetermineImageNumber} with <code>true</code> as argument to identify animated GIFs
 *   ({@link #getNumberOfImages()} will return a value larger than <code>1</code>).</li>
 * <li><strong>2002-04-10</strong> Fixed a bug in the feature 'determine number of images in animated GIF' introduced with version 1.1.
 *   Thanks to Marcelo P. Lima for sending in the bug report. 
 *   Released as 1.1.1.</li>
 * <li><strong>2002-04-18</strong> Added {@link #setCollectComments(boolean)}. 
 *  That new method lets the user specify whether textual comments are to be  
 *  stored in an internal list when encountered in an input image file / stream.
 *  Added two methods to return the physical width and height of the image in dpi: 
 *   {@link #getPhysicalWidthDpi()} and {@link #getPhysicalHeightDpi()}.
 *  If the physical resolution could not be retrieved, these methods return <code>-1</code>.
 *  </li>
 * <li><strong>2002-04-23</strong> Added support for the new properties physical resolution and
 *   comments for some formats. Released as 1.2.</li>
 * <li><strong>2002-06-17</strong> Added support for SWF, sent in by Michael Aird.
 *  Changed checkJpeg() so that other APP markers than APP0 will not lead to a failure anymore.
 *  Released as 1.3.</li>
 * <li><strong>2003-07-28</strong> Bug fix - skip method now takes return values into consideration.
 *  Less bytes than necessary may have been skipped, leading to flaws in the retrieved information in some cases.
 *  Thanks to Bernard Bernstein for pointing that out.
 *  Released as 1.4.</li>
 * <li><strong>2004-02-29</strong> Added support for recognizing progressive JPEG and
 *  interlaced PNG and GIF. A new method {@link #isProgressive()} returns whether ImageInfo
 *  has found that the storage type is progressive (or interlaced). 
 *  Thanks to Joe Germuska for suggesting the feature.
 *  Bug fix: BMP physical resolution is now correctly determined.
 *  Released as 1.5.</li>
 * <li><strong>2004-11-30</strong> Bug fix: recognizing progressive GIFs 
 * (interlaced in GIF terminology) did not work (thanks to Franz Jeitler for 
 *   pointing this out). Now it should work, but only if the number of images is determined.
 *  This is because information on interlacing is stored in a local image header.
 *  In theory, different images could be stored interlaced and non-interlaced in one 
 *  file. However, I think  that's unlikely. Right now, the last image in the GIF file 
 *  that is examined by ImageInfo is used for the "progressive" status.</li>
 * <li><strong>2005-01-02</strong> Some code clean up (unused methods and variables
 *  commented out, missing javadoc comments, etc.). Thanks to George Sexton for a long list.
 *  Removed usage of Boolean.toString because
 *  it's a Java 1.4+ feature (thanks to Gregor Dupont).
 *  Changed delimiter character in compact output from semicolon to tabulator
 * (for better integration with cut(1) and other Unix tools).
 *  Added some points to the <a href="http://schmidt.devlib.org/image-info/index.html#knownissues">'Known
 *  issues' section of the website</a>. 
 *  Released as 1.6.</li>
 * <li><strong>2005-07-26</strong> Removed code to identify Flash (SWF) files.
 *  Has repeatedly led to problems and support requests, and I don't know the
 *  format and don't have the time and interest to fix it myself.
 *  I repeatedly included fixes by others which didn't work for some people.
 *  I give up on SWF. Please do not contact me about it anymore.
 *  Set package of ImageInfo class to org.devlib.schmidt.imageinfo (a package
 *  was repeatedly requested by some users).
 *  Released as 1.7.</li>
 * </ul>
 * @author Marco Schmidt
 */
 
class ImageInfo {
  /**
   * Return value of {@link #getFormat()} for JPEG streams.
   * ImageInfo can extract physical resolution and comments
   * from JPEGs (only from APP0 headers).
   * Only one image can be stored in a file.
   * It is determined whether the JPEG stream is progressive 
   * (see {@link #isProgressive()}).
   */
  final int FORMAT_JPEG = 0;

 
  /*  final int COLOR_TYPE_UNKNOWN = -1;
   final int COLOR_TYPE_TRUECOLOR_RGB = 0;
   final int COLOR_TYPE_PALETTED = 1;
   final int COLOR_TYPE_GRAYSCALE= 2;
   final int COLOR_TYPE_BLACK_AND_WHITE = 3;*/

  /**
   * The names of all supported file formats.
   * The FORMAT_xyz int constants can be used as index values for this array.
   */
  final String[] FORMAT_NAMES =
  {
    "JPEG"
  };

  /**
   * The names of the MIME types for all supported file formats.
   * The FORMAT_xyz int constants can be used as index values for this array.
   */
  final String[] MIME_TYPE_STRINGS =
  {
    "image/jpeg",
  };

  int iiwidth;
  int iiheight;
  int bitsPerPixel;
  //int colorType = COLOR_TYPE_UNKNOWN;
  boolean progressive;
  int format;
  InputStream in;
  DataInput din;
  boolean collectComments = true;
  Vector comments;
  boolean determineNumberOfImages;
  int numberOfImages;
  int physicalHeightDpi;
  int physicalWidthDpi;
  int bitBuf;
  int bitPos;

  void addComment(String s) {
    if (comments == null) {
      comments = new Vector();
    }
    comments.addElement(s);
  }

  /**
   * Call this method after you have provided an input stream or file
   * using {@link #setInput(InputStream)} or {@link #setInput(DataInput)}.
   * If true is returned, the file format was known and information
   * on the file's content can be retrieved using the various getXyz methods.
   * @return if information could be retrieved from input
   */
  boolean check() {
    format = -1;
    iiwidth = -1;
    iiheight = -1;
    bitsPerPixel = -1;
    numberOfImages = 1;
    physicalHeightDpi = -1;
    physicalWidthDpi = -1;
    comments = null;
    try {
      int b1 = read() & 0xff;
      int b2 = read() & 0xff;

      if (b1 == 0xff && b2 == 0xd8) {
            return checkJpeg();
      } else {
            return false;
      }
    } 
    catch (IOException ioe) {
      return false;
    }
  }



 

 

  boolean checkJpeg() throws IOException {
    byte[] data = new byte[12];
    while (true) {
      if (read(data, 0, 4) != 4) {
        return false;
      }
      int marker = getShortBigEndian(data, 0);
      int size = getShortBigEndian(data, 2);
      if ((marker & 0xff00) != 0xff00) {
        return false; // not a valid marker
      }
      if (marker == 0xffe0) { // APPx 
        if (size < 14) {
          return false; // APPx header must be >= 14 bytes
        }
        if (read(data, 0, 12) != 12) {
          return false;
        }
        final byte[] APP0_ID = {
          0x4a, 0x46, 0x49, 0x46, 0x00
        };
        if (equals(APP0_ID, 0, data, 0, 5)) {
          //System.out.println("data 7=" + data[7]);
          if (data[7] == 1) {
            setPhysicalWidthDpi(getShortBigEndian(data, 8));
            setPhysicalHeightDpi(getShortBigEndian(data, 10));
          }
          else
            if (data[7] == 2) {
              int x = getShortBigEndian(data, 8);
              int y = getShortBigEndian(data, 10);
              setPhysicalWidthDpi((int)(x * 2.54f));
              setPhysicalHeightDpi((int)(y * 2.54f));
            }
        }
        skip(size - 14);
      }
      else
        if (collectComments && size > 2 && marker == 0xfffe) { // comment
          size -= 2;
          byte[] chars = new byte[size];
          if (read(chars, 0, size) != size) {
            return false;
          }
          String comment = new String(chars, "iso-8859-1");
          comment = comment.trim();
          addComment(comment);
        }
        else
          if (marker >= 0xffc0 && marker <= 0xffcf && marker != 0xffc4 && marker != 0xffc8) {
            if (read(data, 0, 6) != 6) {
              return false;
            }
            format = FORMAT_JPEG;
            bitsPerPixel = (data[0] & 0xff) * (data[5] & 0xff);
            progressive = marker == 0xffc2 || marker == 0xffc6 ||
              marker == 0xffca || marker == 0xffce;
            iiwidth = getShortBigEndian(data, 3);
            iiheight = getShortBigEndian(data, 1);
            return true;
          } 
          else {
            skip(size - 2);
          }
    }
  }



  boolean equals(byte[] a1, int offs1, byte[] a2, int offs2, int num) {
    while (num-- > 0) {
      if (a1[offs1++] != a2[offs2++]) {
        return false;
      }
    }
    return true;
  }

  /** 
   * If {@link #check()} was successful, returns the image's number of bits per pixel.
   * Does not include transparency information like the alpha channel.
   * @return number of bits per image pixel
   */
  int getBitsPerPixel() {
    return bitsPerPixel;
  }

  /**
   * Returns the index'th comment retrieved from the file.
   * @param index int index of comment to return
   * @throws IllegalArgumentException if index is smaller than 0 or larger than or equal
   * to the number of comments retrieved
   * @see #getNumberOfComments
   */
  String getComment(int index) {
    if (comments == null || index < 0 || index >= comments.size()) {
      throw new IllegalArgumentException("Not a valid comment index: " + index);
    }
    return (String)comments.elementAt(index);
  }

  /**
   * If {@link #check()} was successful, returns the image format as one
   * of the FORMAT_xyz constants from this class.
   * Use {@link #getFormatName()} to get a textual description of the file format.
   * @return file format as a FORMAT_xyz constant
   */
  int getFormat() {
    return format;
  }

  /**
   * If {@link #check()} was successful, returns the image format's name.
   * Use {@link #getFormat()} to get a unique number.
   * @return file format name
   */
  String getFormatName() {
    if (format >= 0 && format < FORMAT_NAMES.length) {
      return FORMAT_NAMES[format];
    } 
    else {
      return "?";
    }
  }

  /** 
   * If {@link #check()} was successful, returns one the image's vertical resolution in pixels.
   * @return image height in pixels
   */
  int getHeight() {
    return height;
  }

  int getIntBigEndian(byte[] a, int offs) {
    return
      (a[offs] & 0xff) << 24 | 
      (a[offs + 1] & 0xff) << 16 | 
      (a[offs + 2] & 0xff) << 8 | 
      a[offs + 3] & 0xff;
  }

  int getIntLittleEndian(byte[] a, int offs) {
    return
      (a[offs + 3] & 0xff) << 24 | 
      (a[offs + 2] & 0xff) << 16 | 
      (a[offs + 1] & 0xff) << 8 | 
      a[offs] & 0xff;
  }

  /** 
   * If {@link #check()} was successful, returns a String with the MIME type of the format.
   * @return MIME type, e.g. <code>image/jpeg</code>
   */
  String getMimeType() {
    if (format >= 0 && format < MIME_TYPE_STRINGS.length) {
      if (format == FORMAT_JPEG && progressive)
      {
        return "image/pjpeg";
      }
      return MIME_TYPE_STRINGS[format];
    } 
    else {
      return null;
    }
  }

  /**
   * If {@link #check()} was successful and {@link #setCollectComments(boolean)} was called with
   * <code>true</code> as argument, returns the number of comments retrieved 
   * from the input image stream / file.
   * Any number &gt;= 0 and smaller than this number of comments is then a
   * valid argument for the {@link #getComment(int)} method.
   * @return number of comments retrieved from input image
   */
  int getNumberOfComments()
  {
    if (comments == null) {
      return 0;
    } 
    else {
      return comments.size();
    }
  }

  /**
   * Returns the number of images in the examined file.
   * Assumes that <code>setDetermineImageNumber(true);</code> was called before
   * a successful call to {@link #check()}.
   * This value can currently be only different from <code>1</code> for GIF images.
   * @return number of images in file
   */
  int getNumberOfImages()
  {
    return numberOfImages;
  }

  /**
   * Returns the physical height of this image in dots per inch (dpi).
   * Assumes that {@link #check()} was successful.
   * Returns <code>-1</code> on failure.
   * @return physical height (in dpi)
   * @see #getPhysicalWidthDpi()
   * @see #getPhysicalHeightInch()
   */
  int getPhysicalHeightDpi() {
    return physicalHeightDpi;
  }

  /**
   * If {@link #check()} was successful, returns the physical width of this image in dpi (dots per inch)
   * or -1 if no value could be found.
   * @return physical height (in dpi)
   * @see #getPhysicalHeightDpi()
   * @see #getPhysicalWidthDpi()
   * @see #getPhysicalWidthInch()
   */
  float getPhysicalHeightInch() {
    int h = getHeight();
    int ph = getPhysicalHeightDpi();
    if (h > 0 && ph > 0) {
      return ((float)h) / ((float)ph);
    } 
    else {
      return -1.0f;
    }
  }

  /**
   * If {@link #check()} was successful, returns the physical width of this image in dpi (dots per inch)
   * or -1 if no value could be found.
   * @return physical width (in dpi)
   * @see #getPhysicalHeightDpi()
   * @see #getPhysicalWidthInch()
   * @see #getPhysicalHeightInch()
   */
  int getPhysicalWidthDpi() {
    return physicalWidthDpi;
  }

  /**
   * Returns the physical width of an image in inches, or
   * <code>-1.0f</code> if width information is not available.
   * Assumes that {@link #check} has been called successfully.
   * @return physical width in inches or <code>-1.0f</code> on failure
   * @see #getPhysicalWidthDpi
   * @see #getPhysicalHeightInch
   */
  float getPhysicalWidthInch() {
    int w = getWidth();
    int pw = getPhysicalWidthDpi();
    if (w > 0 && pw > 0) {
      return ((float)w) / ((float)pw);
    } 
    else {
      return -1.0f;
    }
  }

  int getShortBigEndian(byte[] a, int offs) {
    return (a[offs] & 0xff) << 8 | (a[offs + 1] & 0xff);
  }

  int getShortLittleEndian(byte[] a, int offs) {
    return (a[offs] & 0xff) | (a[offs + 1] & 0xff) << 8;
  }

  /** 
   * If {@link #check()} was successful, returns one the image's horizontal resolution in pixels.
   * @return image width in pixels
   */
  int getWidth() {
    return iiwidth;
  }

  /**
   * Returns whether the image is stored in a progressive (also called: interlaced) way.
   * @return true for progressive/interlaced, false otherwise
   */
  boolean isProgressive() {
    return progressive;
  }

  /**
   * To use this class as a command line application, give it either 
   * some file names as parameters (information on them will be
   * printed to standard output, one line per file) or call
   * it with no parameters. It will then check data given to it via standard input.
   * @param args the program arguments which must be file names
   */
 

  void print(String sourceName, ImageInfo ii, boolean verbose) {
    if (verbose) {
      printVerbose(sourceName, ii);
    } 
    else {
      printCompact(sourceName, ii);
    }
  }

  void printCompact(String sourceName, ImageInfo imageInfo) {
    final String SEP = "\t";
    System.out.println(
    sourceName + SEP + 
      imageInfo.getFormatName() + SEP +
      imageInfo.getMimeType() + SEP +
      imageInfo.getWidth() + SEP +
      imageInfo.getHeight() + SEP +
      imageInfo.getBitsPerPixel() + SEP +
      imageInfo.getNumberOfImages() + SEP +
      imageInfo.getPhysicalWidthDpi() + SEP +
      imageInfo.getPhysicalHeightDpi() + SEP +
      imageInfo.getPhysicalWidthInch() + SEP +
      imageInfo.getPhysicalHeightInch() + SEP +
      imageInfo.isProgressive()
      );
  }

  void printLine(int indentLevels, String text, float value, float minValidValue) {
    if (value < minValidValue) {
      return;
    }
    printLine(indentLevels, text, Float.toString(value));
  }

  void printLine(int indentLevels, String text, int value, int minValidValue) {
    if (value >= minValidValue) {
      printLine(indentLevels, text, Integer.toString(value));
    }
  }

  void printLine(int indentLevels, String text, String value) {
    if (value == null || value.length() == 0) {
      return;
    }
    while (indentLevels-- > 0) {
      System.out.print("\t");
    }
    if (text != null && text.length() > 0) {
      System.out.print(text);
      System.out.print(" ");
    }
    System.out.println(value);
  }

  void printVerbose(String sourceName, ImageInfo ii) {
    printLine(0, null, sourceName);
    printLine(1, "File format: ", ii.getFormatName());
    printLine(1, "MIME type: ", ii.getMimeType());
    printLine(1, "Width (pixels): ", ii.getWidth(), 1);
    printLine(1, "Height (pixels): ", ii.getHeight(), 1);
    printLine(1, "Bits per pixel: ", ii.getBitsPerPixel(), 1);
    printLine(1, "Progressive: ", ii.isProgressive() ? "yes" : "no");
    printLine(1, "Number of images: ", ii.getNumberOfImages(), 1);
    printLine(1, "Physical width (dpi): ", ii.getPhysicalWidthDpi(), 1);
    printLine(1, "Physical height (dpi): ", ii.getPhysicalHeightDpi(), 1);
    printLine(1, "Physical width (inches): ", ii.getPhysicalWidthInch(), 1.0f);
    printLine(1, "Physical height (inches): ", ii.getPhysicalHeightInch(), 1.0f);
    int numComments = ii.getNumberOfComments();
    printLine(1, "Number of textual comments: ", numComments, 1);
    if (numComments > 0) {
      for (int i = 0; i < numComments; i++) {
        printLine(2, null, ii.getComment(i));
      }
    }
  }

  int read() throws IOException {
    if (in != null) {
      return in.read();
    } 
    else {
      return din.readByte();
    }
  }

  int read(byte[] a) throws IOException {
    if (in != null) {
      return in.read(a);
    } 
    else {
      din.readFully(a);
      return a.length;
    }
  }

  int read(byte[] a, int offset, int num) throws IOException {
    if (in != null) {
      return in.read(a, offset, num);
    } 
    else {
      din.readFully(a, offset, num);
      return num;
    }
  }

  String readLine() throws IOException {
    return readLine(new StringBuffer());
  }

  String readLine(StringBuffer sb) throws IOException {
    boolean finished;
    do {
      int value = read();
      finished = (value == -1 || value == 10);
      if (!finished) {
        sb.append((char)value);
      }
    } 
    while (!finished);
    return sb.toString();
  }

  long readUBits( int numBits ) throws IOException
  {
    if (numBits == 0) {
      return 0;
    }
    int bitsLeft = numBits;
    long result = 0;
    if (bitPos == 0) { //no value in the buffer - read a byte
      if (in != null) {
        bitBuf = in.read();
      } 
      else {
        bitBuf = din.readByte();
      }
      bitPos = 8;
    }

    while ( true )
    {
      int shift = bitsLeft - bitPos;
      if ( shift > 0 )
      {
        // Consume the entire buffer
        result |= bitBuf << shift;
        bitsLeft -= bitPos;

        // Get the next byte from the input stream
        if (in != null) {
          bitBuf = in.read();
        } 
        else {
          bitBuf = din.readByte();
        }
        bitPos = 8;
      }
      else
      {
        // Consume a portion of the buffer
        result |= bitBuf >> -shift;
        bitPos -= bitsLeft;
        bitBuf &= 0xff >> (8 - bitPos);  // mask off the consumed bits

          return result;
      }
    }
  }

  /**
   * Read a signed integer value from input.
   * @param numBits number of bits to read
   */
  int readSBits(int numBits) throws IOException
  {
    // Get the number as an unsigned value.
    long uBits = readUBits( numBits );

    // Is the number negative?
    if ( ( uBits & (1L << (numBits - 1))) != 0 )
    {
      // Yes. Extend the sign.
      uBits |= -1L << numBits;
    }

    return (int)uBits;
  }  

  

  void run(String sourceName, InputStream in, ImageInfo imageInfo, boolean verbose) {
    imageInfo.setInput(in);
    imageInfo.setDetermineImageNumber(true);
    imageInfo.setCollectComments(verbose);
    if (imageInfo.check()) {
      print(sourceName, imageInfo, verbose);
    }
  }

  /**
   * Specify whether textual comments are supposed to be extracted from input.
   * Default is <code>false</code>.
   * If enabled, comments will be added to an internal list.
   * @param newValue if <code>true</code>, this class will read comments
   * @see #getNumberOfComments
   * @see #getComment
   */
  void setCollectComments(boolean newValue)
  {
    collectComments = newValue;
  }

  /**
   * Specify whether the number of images in a file is to be
   * determined - default is <code>false</code>.
   * This is a special option because some file formats require running over
   * the entire file to find out the number of images, a rather time-consuming task.
   * Not all file formats support more than one image.
   * If this method is called with <code>true</code> as argument,
   * the actual number of images can be queried via 
   * {@link #getNumberOfImages()} after a successful call to {@link #check()}.
   * @param newValue will the number of images be determined?
   * @see #getNumberOfImages
   */
  void setDetermineImageNumber(boolean newValue)
  {
    determineNumberOfImages = newValue;
  }

  /**
   * Set the input stream to the argument stream (or file). 
   * Note that {@link java.io.RandomAccessFile} implements {@link java.io.DataInput}.
   * @param dataInput the input stream to read from
   */
  void setInput(DataInput dataInput) {
    din = dataInput;
    in = null;
  }

  /**
   * Set the input stream to the argument stream (or file).
   * @param inputStream the input stream to read from
   */
  void setInput(InputStream inputStream) {
    in = inputStream;
    din = null;
  }

  void setPhysicalHeightDpi(int newValue) {
    physicalWidthDpi = newValue;
  }

  void setPhysicalWidthDpi(int newValue) {
    physicalHeightDpi = newValue;
  }

  void skip(int num) throws IOException {
    while (num > 0) {
      long result;
      if (in != null) {
        result = in.skip(num);
      } 
      else {
        result = din.skipBytes(num);
      }
      if (result > 0) {
        num -= result;
      }
    }
  }
}

