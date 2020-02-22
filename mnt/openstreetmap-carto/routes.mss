/* For hiking & bicycle routes: GR, PR... */

#routes[zoom >= 8][zoom <= 13] {
    [network='nwn'][zoom <= 11][ref =~ "^GR[\s-][\d]{1,3}$"],  // only main GR and HRP
    [network='nwn'][zoom <= 11][ref = "HRP"],
    [network='nwn'][zoom >= 12],
    [network='rwn'][zoom >= 12],
    [network='lwn'][zoom >= 13] {
        route/line-offset: -1.2;
        route/line-opacity: 1;
        route/line-dasharray: 5,12;
        
        route2/line-offset: 1.2;
        route2/line-opacity: 1;
        route2/line-dasharray: 5,12;
       
        [network='lwn'][zoom >= 13]{ 
            route/line-color: green; 
            route2/line-color: white; 
        }
        [network='rwn'][zoom >= 12]{ 
            route/line-color: darken( yellow, 8);
            route2/line-color: white;
        }
        [network='nwn'] { 
            // route/line-width: 2.4;
            route/line-color: red; 
            route/line-dasharray: 6,18;
            route/line-opacity: 1;
            route/line-offset: -1.2;
            // route2/line-width: 2.4;
            route2/line-color: white; 
            route2/line-dasharray: 6,18;
            route2/line-opacity: 1;
            route2/line-offset: 1.2;
        }
        [zoom = 8]{   route/line-width: 0.7; route2/line-width: 0.7; }
        [zoom = 9]{   route/line-width: 1.2; route2/line-width: 1.2; }
        [zoom = 10]{  route/line-width: 1.5; route2/line-width: 1.5; }
        [zoom >= 11]{ route/line-width: 2.2; route2/line-width: 2.2; }
    }
}


#routes[zoom >= 14] {
    text-name: "[name]";
    text-fill: darken(red,30 );
    text-size: 10;
    text-dy: 12;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-spacing: 450;
    text-clip: false;
    text-placement: line;
    text-face-name: @book-fonts;
    text-vertical-alignment: middle;
    text-repeat-distance: 450;

    [zoom >= 15] {
      text-size: 11;
    }
    [zoom >= 17] {
      text-size: 12;
    }

    [network='lwn'],
    [network='rwn'],
    [network='nwn']{
        route/line-color: orange; 
        route/line-opacity: 0.25;
        route/line-width: 3.5;
        route/line-offset: 4.3;
    }
    [network='lwn']{ 
        route/line-dasharray: 5,6;
    }
    [network='rwn']{ 
        route/line-dasharray: 6,5;
    }
    [network='nwn'] { 
        route/line-dasharray: 10,0;
    }
}

#routes_shields[zoom >= 8][zoom <= 13] {
    [network='nwn'][zoom <= 11][ref =~ "^GR[\s-][\d]{1,3}$"],  // only main GR and HRP
    [network='nwn'][zoom <= 11][ref = "HRP"],
    [network='nwn'][zoom >= 12],
    [network='rwn'][zoom >= 12],
    [network='lwn'][zoom >= 13] {
        shield-name: "[ref]";
        shield-size: 8;
        shield-fill: #620728;
        shield-placement: line;
        shield-repeat-distance: 450;
        shield-spacing: 450;
        shield-margin: 25;
        shield-face-name: @shield-font;
        shield-clip: false;
        shield-file: url("symbols/shields/XR.svg");
        shield-allow-overlap: false;

        [network='nwn']{ 
            shield-file: url("symbols/shields/GR.svg");
        }
        [network='rwn'][zoom >= 12]{ 
            shield-file: url("symbols/shields/PR.svg");
        }
        [network='lwn'][zoom >= 13]{ 
            shield-file: url("symbols/shields/LR.svg");
        }
    }
}

#routes_shields[zoom >= 14] {
    shield-name: "[ref]";
    shield-size: 8;
    shield-fill: #620728;
    shield-placement: line;
    shield-repeat-distance: 450;
    shield-spacing: 450;
    shield-margin: 20;
    shield-face-name: @shield-font;
    shield-clip: false;
    shield-file: url("symbols/shields/XR.svg");
    shield-allow-overlap: false;

    [network='nwn'] {
        shield-file: url("symbols/shields/GR.svg");
    }
    [network='rwn'] {
        shield-file: url("symbols/shields/PR.svg");
    }
    [network='lwn'] {
        shield-file: url("symbols/shields/LR.svg");
    }  
}