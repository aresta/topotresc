/* For mountain refuges */

#refuges {
  [tourism = 'alpine_hut'][zoom >= 11],
  [tourism = 'wilderness_hut'][zoom >= 13] {
//   [amenity = 'shelter'][zoom >= 16] {
    marker-file: url('symbols/amenity/shelter.svg');
    marker-fill: black;
    [tourism = 'wilderness_hut'] {
      marker-file: url('symbols/tourism/wilderness_hut.svg');
      marker-fill: darken( red, 15%);
      marker-width: 12;
      [zoom >= 14] { marker-width: 14; }
      [zoom >= 16] { marker-width: 22; }
    }
    [tourism = 'alpine_hut'] {
      marker-file: url('symbols/tourism/alpine_hut.svg');
      marker-fill: darken( red, 5%);
      marker-width: 14;
      [zoom >= 14] { marker-width: 17; }
      [zoom >= 16] { marker-width: 26; }
    }
    marker-placement: interior;
    marker-clip: false;
    marker-allow-overlap: true;
    [access != ''][access != 'permissive'][access != 'yes'] {
      marker-opacity: 0.33;
    }
  }

//   [amenity = 'shelter'][zoom >= 16],
  [tourism = 'alpine_hut'][zoom >= 13],
  [tourism = 'wilderness_hut'][zoom >= 14] {
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
    // [amenity = 'shelter'] {
    //   text-fill: @man-made-icon;
    // }
    [tourism = 'alpine_hut'],
    [tourism = 'wilderness_hut'] {
    // [amenity = 'shelter'] {
      [access != ''][access != 'permissive'][access != 'yes'] {
        text-opacity: 0.33;
        text-halo-radius: 0;
      }
    }
  }
}