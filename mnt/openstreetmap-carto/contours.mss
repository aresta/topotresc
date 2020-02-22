@contour: darken(gray, 35);
@contours-text: darken(gray, 10);

@contours-line-width: 0.6;
@contours-line-smooth: 0.1;   // A value from 0 to 1. 0=no smoothing

#hillshade {
  raster-scaling: bilinear;
  raster-comp-op: multiply;
  [zoom<=12] { raster-opacity: 0.80; }
  [zoom>=13][zoom<=15] { raster-opacity: 0.60; }
  [zoom>=16] { raster-opacity:0.48; }
}

 #color_relief[zoom<=13] {
  raster-scaling: bilinear;
  raster-comp-op: multiply;
  raster-opacity:0.50;
}

#contours[zoom=12][height100 = 0]{
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width * 1.1;
  line-opacity: 0.45;
}

#contours[zoom=13][height50 = 0]{
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width * 1.1;
  line-opacity: 0.45;
}

#contours[zoom>=14][height20 = 0]{
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width;
  line-opacity: 0.4;
}

#contours[zoom>=15][height10 = 0]{
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width;
  line-opacity: 0.4;
}

#contours[zoom>=14][height100 = 0],
#contours[zoom>=15][height50 = 0] {
      line-color: darken(@contour, 10);
      line-width: @contours-line-width * 1.5;
      line-opacity: 0.55;
      text-name: "[height]";
      text-face-name: @book-fonts;
      text-placement: line;
      text-fill: @contours-text;
      text-spacing: 800;
      text-size: 11;
      [height50 = 0][height100 != 0] { 
        line-width: @contours-line-width * 1.1; 
        text-size: 10;
      }
  }

#contours[zoom>=17][height10 != 0]{
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-width: @contours-line-width;
  line-opacity: 0.4;
}

