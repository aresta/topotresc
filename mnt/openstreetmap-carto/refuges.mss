/* For mountain refuges */

#refuges {
  [tourism = 'alpine_hut'][zoom >= 11],
  [tourism = 'wilderness_hut'][zoom >= 13],
  [amenity = 'shelter'][shelter_type = 'basic_hut'][zoom >= 13],
  [amenity = 'shelter'][shelter_type = 'rock_shelter'][zoom >= 15],
  [amenity = 'shelter'][shelter_type != 'basic_hut'][shelter_type != 'rock_shelter'][zoom >= 14] {
    marker-file: url('symbols/tourism/wilderness_hut.svg');
    marker-fill: darken( gray, 20%);
    marker-width: 11;
    [zoom >= 15] { marker-width: 14; }
    [zoom >= 16] { marker-width: 15; }
    [tourism = 'wilderness_hut'],
    [amenity = 'shelter'][shelter_type = 'basic_hut'] {
      marker-file: url('symbols/tourism/wilderness_hut.svg');
      marker-fill: darken( red, 18%);
      marker-width: 12;
      [zoom >= 14] { marker-width: 12; }
      [zoom >= 16] { marker-width: 16; }
    }
    [amenity = 'shelter'][shelter_type = 'rock_shelter'] { 
      marker-file: url('symbols/bunker.svg'); 
      marker-fill: darken( gray, 10%);
      marker-width: 13;
    }
    [tourism = 'alpine_hut'] {
      marker-file: url('symbols/tourism/alpine_hut.svg');
      marker-fill: darken( red, 5%);
      marker-width: 14;
      [zoom >= 13] { marker-width: 20; }
      [zoom >= 16] { marker-width: 26; }
    }
    marker-placement: interior;
    marker-clip: false;
    marker-allow-overlap: true;
    [access != ''][access != 'permissive'][access != 'yes'] {
      marker-opacity: 0.33;
    }
  }

  [tourism = 'alpine_hut'][zoom >= 13],
  [tourism = 'wilderness_hut'][zoom >= 14],
  [amenity = 'shelter'][zoom >= 15] {
    text-name: "[name]";
    text-size: @standard-font-size;
    text-wrap-width: @standard-wrap-width;
    text-line-spacing: @standard-line-spacing-size;
    text-fill: darken( red, 10%);
    text-dy: 14;
    text-face-name: @standard-font;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-placement: interior;
    [amenity = 'shelter'][shelter_type != 'basic_hut']{
      text-fill: darken( gray, 25%);
    }
    [tourism = 'alpine_hut'],
    [tourism = 'wilderness_hut'],
    [amenity = 'shelter'] {
      [access != ''][access != 'permissive'][access != 'yes'] {
        text-opacity: 0.33;
        text-halo-radius: 0;
      }
    }
  }
}