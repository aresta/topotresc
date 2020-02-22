(function (window) {
    'use strict';


    function toggle_hidden( elem){
        elem.classList.toggle("hidden");
    }

    function hide_all_panels()
    {
        for( var panel of document.getElementsByClassName("menu-panel")){
            panel.classList.add('hidden');
        }
    }

    function initMap() {
        var map, center, zoom, circle;
        var menu = document.getElementById('menu');
        var menu_items = menu.children;

        // Menu & panels   
        for( var item of menu_items){
            if( !item.dataset.panel) continue;
            item.onclick = function(e){
                var panel = document.getElementById( this.dataset.panel);
                var is_hidden = panel.classList.contains('hidden');
                hide_all_panels();
                if( is_hidden) toggle_hidden(panel);
                e.stopPropagation();
            }
        }
        document.getElementById('track').onclick = function(e){
            document.querySelector('input[type="file"]').click();  // dirty solution to fire the load track action
            e.stopPropagation();
        }

        document.getElementById('map').onclick = function(){
            hide_all_panels();
            menu.classList.add("hidden");
        }

        // Panel Dreceres
        var dreceres = document.getElementById('dreceres').children;
        for( var drec of dreceres){
            drec.onclick = function(){
                hide_all_panels();
                // menu.classList.add("hidden");
                map.flyTo( JSON.parse( this.dataset.latlon), parseInt(this.dataset.zoom));
            }
        }

        // Get last position from localStorage 
        center = JSON.parse(localStorage.getItem('latlon')) || [43.18, -4.840];
        zoom = localStorage.getItem('zoom') || 14;
        if(zoom > 16) zoom = 16;
        map = L.map('map').setView(center, zoom);

        L.control.scale({imperial:false, maxWidth:150, position:'bottomright'}).addTo(map);

        var track_button = L.Control.fileLayerLoad({
            layerOptions: {
                style: {
                    color: 'magenta',
                    opacity: 0.6,
                    fillOpacity: 0.6,
                    weight: 2,
                    clickable: true
                },
            },
            layer: L.geoJson,
            addToMap: true,
            fileSizeLimit: 1024,
            formats: [
                '.geojson',
                '.kml',
                '.gpx'
            ]
        });
        track_button.addTo(map);
        document.querySelector('.leaflet-control-filelayer').style.display = 'none'; // dirty solution to remove the button


        // Geolocation button
        var geoloc_button = L.easyButton({
            states: [{
                    stateName: 'ready',
                    icon:      'far fa-compass pos-icon',
                    title:     'Geolocalització GPS',
                    onClick: function(btn, map) {
                        if( circle) circle.remove();
                        map.findAccuratePosition({
                            maxWait: 10000,
                            desiredAccuracy: 30
                        });
                        btn.state('working');    
                        btn.disable();
                    }
                }, {
                    stateName: 'working',
                    icon:      'far fa-compass fa-spin pos-icon',
                    title:     'Esperi (10s)',
            }]
        });
        geoloc_button.addTo(map);
        
        L.easyButton('fas fa-bars pos-icon', function(){
                hide_all_panels()
                toggle_hidden(menu);
            }, 
            { position: 'topright' }
        ).addTo( map );

        map.on('moveend', function(){ 
            localStorage.setItem('latlon', JSON.stringify( map.getCenter()));
        })
        map.on('zoomend', function(){ 
            localStorage.setItem('zoom', map.getZoom());
        })

        L.tileLayer(window.location.protocol + '//' + window.location.host + '/{id}/{z}/{x}/{y}.png', {
            minZoom: 7,
            maxZoom: 17,
            attribution: 'Map data &copy; <a href="http://openstreetmap.org" target="_blank">OpenStreetMap</a> contributors' + 
                ', <a href="http://www.icgc.cat" target="_blank">ICGC</a>' + 
                ', <a href="https://www.cnig.es" target="_blank">CNIG</a>. ' + 
                '<a href="http://creativecommons.org/licenses/by-sa/2.0/" target="_blank">CC-BY-SA</a>',
            id: 'osm_tiles'
        }).addTo(map );

        ///////// Accureate position
		function onAccuratePositionError(e) {
            // addStatus('error:' + e.message);
            // console.log(e);
            switch( e.code){
                case 0:
                    alert("Geolocalització no disponible.");
                    break;
                case 1:
                        alert("Sense permís per accedir a la geolocalització. Ajusta els permisos del navegador.");
                    break;
                case 2:
                    alert("Posicionament no disponible en aquest moment.");
                    break;
                case 3:
                    alert("Temps d'espera esgotat.");
                    break;
            } 
            geoloc_button.state('ready');
            geoloc_button.enable();
        }
        
        function onAccuratePositionProgress(e) {
			// addStatus( Math.round( e.accuracy) );
        }
        
		function onAccuratePositionFound(e) {
            // addStatus('done:' + Math.round( e.accuracy));
            if( e.accuracy < 100){
                var zoom = map.getZoom();
                map.flyTo(e.latlng, Math.max( zoom, 16));
                var radius = e.accuracy;
                circle = L.circle(e.latlng, radius);
                circle.addTo(map);
            }
            geoloc_button.state('ready');
            geoloc_button.enable();
		}
		// function addStatus(message) {
		// 	var span = document.getElementById('status');
		// 	span.innerHTML += message + ' ';
		// }
		map.on('accuratepositionprogress', onAccuratePositionProgress);
		map.on('accuratepositionfound', onAccuratePositionFound);
		map.on('accuratepositionerror', onAccuratePositionError);
    }

    window.addEventListener('load', function () {
        initMap();
    });
}(window));