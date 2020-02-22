/* For hiking paths */

@footway-color: red; 
@footway-color-medium: darken(red, 20); 
@footway-color-difficult: black; 
@footway-color-noaccess: #663d00;
@footway-width: 1;

#paths[zoom >= 14] {
    [bicycle != 'designated'][horse != 'designated'] {
        [sac_scale = null]{
            line-color: @footway-color-medium;
            line-dasharray: 6,8;
            line-join: round;
            line-cap: round;
            line-width: @footway-width;
        }

        [sac_scale = 'easy'] {
            line-color: @footway-color;
            line-width: @footway-width; // looks a bit wider than the others
            [zoom = 14] { line-width: @footway-width * 0.65; }
            line-dasharray: 10,3;
            [trail_visibility = 'bad'] {
                line-dasharray: 3,5;
                line-width: @footway-width * 0.8;
            }   
        }

        [sac_scale = 'medium'][trail_visibility != 'bad'] { // good visibility or null
            line-color: @footway-color-medium;
            line-dasharray: 7,7;
            line-width: @footway-width * 0.8;
            [zoom = 14] { line-width: @footway-width * 0.6; }       
        }

        [sac_scale = 'medium'][trail_visibility = 'bad'][zoom >= 15] {
            line-color: @footway-color-medium;
            line-dasharray: 3,8;
            line-width: @footway-width * 0.8;
        }

        [sac_scale = 'difficult'][trail_visibility != 'bad'][zoom >= 15] {
            line-color: @footway-color-difficult;
            line-dasharray: 5,6;     
            line-width: @footway-width * 0.8;         
        }

        [sac_scale = 'difficult'][trail_visibility = 'bad'][zoom >= 16] {
            line-width: @footway-width * 1;
            line-dasharray: 3,8;
        }

        [access = 'no'][foot!='yes'] { line-color: @footway-color-noaccess; }

        [zoom >= 14][int_surface = 'paved'] {
            line-color: @footway-color;
            line-dasharray: 15,3;
            line-width: @footway-width * 1.1;
        }
    }
}

#paths-text-name {
  [highway = 'bridleway'],
  [highway = 'footway'],
  [highway = 'cycleway'],
  [highway = 'path'],
  [highway = 'steps'],
  [highway = 'construction'][construction = 'bridleway'],
  [highway = 'construction'][construction = 'footway'],
  [highway = 'construction'][construction = 'cycleway'],
  [highway = 'construction'][construction = 'path'],
  [highway = 'construction'][construction = 'steps'] {
    [zoom >= 16] {
      text-name: "[name]";
      text-fill: #222;
      text-size: 11;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-vertical-alignment: middle;
      text-dy: 9;
      text-repeat-distance: @major-highway-text-repeat-distance;
      [highway = 'steps'] { text-repeat-distance: @minor-highway-text-repeat-distance; }
    }
    [zoom >= 17] {
      text-size: 12;
      text-dy: 10;
    }
  }
}