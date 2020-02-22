/* For tracks */

@track-width: 1;
@track-width: 1;

@track-fill: white;
@track-fill-noaccess: lighten(gray,40);
@track-casing: red;
@track-width:                 1.4;
@tracks-background-width:     1;
@tracks-bridge-casing-width:  0.5;
@tracks-tunnel-casing-width:  1;


#tracks {
    [zoom = 14][tracktype != 'grade1'][tracktype != 'grade2'] {
        line/line-width: @track-width;
        line/line-color: lighten( red, 10);
        line/line-opacity: 0.5;
        line/line-clip:false;   
    } 

    [zoom = 14][tracktype = 'grade1'], 
    [zoom = 14][tracktype = 'grade2'], 
    [zoom >= 15] {
      background/line-width: @track-width + 1.2;
      background/line-opacity: 0.4;
      background/line-color: @track-casing;
      background/line-join: round;
      background/line-cap: round;
    }    

    [zoom = 14][tracktype = 'grade1'], 
    [zoom = 14][tracktype = 'grade2'], 
    [zoom >= 15][tracktype = 'grade5'] {
        background/line-width: @track-width + 1.6;
    }
    
    [zoom >= 14][tracktype = 'grade1'], [zoom >= 14][tracktype = 'grade2'] { background/line-width: @track-width + 2; }
    [zoom >= 15]{ background/line-width: @track-width + 3; }
    [zoom >= 16]{ background/line-width: @track-width + 4; }
    [zoom >= 17]{ background/line-width: @track-width + 4.8; }


    [zoom >= 14] {
        line/line-width: @track-width - 2;
        line/line-color: @track-fill;
        [access = 'no'] { line/line-color: @track-fill-noaccess; }
        line/line-cap: round;
        line/line-join: round;
        line/line-opacity: 0.5;
        line/line-clip:false;
    }
    
    [zoom >= 14][tracktype = 'grade1'], 
    [zoom >= 14][tracktype = 'grade2'], 
    [zoom >= 15][tracktype = 'grade5'] {
        line/line-width: @track-width;
    }
    [zoom >= 14][tracktype = 'grade1'], [zoom >= 14][tracktype = 'grade2'] { line/line-width: @track-width + 0.7; }
    [zoom >= 15]{ line/line-width: @track-width + 0.75; }
    [zoom >= 16]{ line/line-width: @track-width + 1.5; }
    [zoom >= 17]{ line/line-width: @track-width + 2.2; }

    [zoom >= 14][tracktype = 'grade1'], [zoom >= 14][tracktype = 'grade2'] {
        line/line-dasharray: 100,0;
    }
    [zoom >= 15][tracktype = 'grade5'] {
        line/line-dasharray: 6,2;
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
    } // bridges_and_tunnels_background
    
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