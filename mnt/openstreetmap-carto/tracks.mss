/* For tracks */

@track-width: 1.2;

@track-fill: white;
@track-casing: red;
@track-fill-noaccess: lighten(gray,40);
@tracks-bridge-casing-width:  0.5;
@tracks-tunnel-casing-width:  1;


#tracks {
    background/line-join: round;
    background/line-cap: round;
    background/line-color: @track-casing;
    background/line-opacity: 0.4;
    line/line-cap: round;
    line/line-join: round;
    line/line-clip:false; 
    line/line-opacity: 0.6;
    line/line-color: @track-fill;
    line/line-width: @track-width - 0.3;
    [access = 'no'] { line/line-color: @track-fill-noaccess; }

  [zoom = 14]{
    line/line-color: lighten( red, 10);
    [tracktype != 'grade4'][tracktype != 'grade5'][tracktype != null]{
      line/line-color: @track-fill;
      background/line-width: @track-width + 1.7;
      line/line-width: @track-width + 0.6;
    }
    [tracktype = 'grade5']{
      line/line-opacity: 0.3;
    }
  } 

  [zoom = 15] {
    background/line-width: @track-width + 2.4;
    line/line-width: @track-width + 0.65;
    [tracktype = 'grade4'],
    [tracktype = 'grade5'],
    [tracktype = null]{
      background/line-width: @track-width + 1.5; 
      line/line-width: @track-width + 0.8;
    }
  }    
  
  [zoom = 16]{ 
    background/line-width: @track-width + 3.2;
    line/line-width: @track-width + 1.4;
    [tracktype = 'grade4'],
    [tracktype = 'grade5'],
    [tracktype = null]{
      background/line-width: @track-width + 1.8;
      line/line-width: @track-width + 1.2;
    }
  }
  [zoom >= 17]{ 
    background/line-width: @track-width + 3.8; 
    line/line-width: @track-width + 2.0;
    [tracktype = 'grade4'],
    [tracktype = 'grade5'],
    [tracktype = null]{
      background/line-width: @track-width + 2.4; 
      line/line-width: @track-width + 1.8;
    }
  }

  [zoom >= 15][tracktype = 'grade5'] {
      background/line-opacity: 0.25;
      line/line-opacity: 0.4;
  }

  ::casing {
    #bridges {
        background/line-color: darken(@track-casing,20);
        background/line-dasharray: 6,2;
    }
    #tunnels {
        background/line-color: lighten(@track-casing,20);
        background/line-dasharray: 6,4;
    }
  } // casing

  ::bridges_and_tunnels_background {
    #bridges {
        line/line-dasharray: 6,2;
    }
    #tunnels {
        line/line-dasharray: 6,4;
    }
  } // bridges_and_tunnels_backgroun 
}

#paths-text-name {
  [highway = 'track'],
  [highway = 'construction'][construction = 'track'][zoom >= 16] {
    [zoom >= 15] {
      text-name: "[name]";
      text-fill: #222;
      text-size: 10;
      text-dy: 8;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-vertical-alignment: middle;
      text-repeat-distance: @major-highway-text-repeat-distance;
    }
    [zoom >= 16] {
      text-size: 11;
      text-dy: 9;
    }
  }
}

#roads-text-ref-minor {
  [highway = 'track'] {
    [zoom >= 15] {
      text-name: "[refs]";
      text-size: 10;
      text-dy: 8;

      [zoom >= 16] {
        text-size: 11;
        text-dy: 9;
      }

      text-clip: false;
      text-fill: #222;
      text-face-name: @oblique-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-margin: 10;
      text-placement: line;
      text-spacing: 760;
      text-repeat-distance: @major-highway-text-repeat-distance;
      text-vertical-alignment: middle;
    }
  }
}