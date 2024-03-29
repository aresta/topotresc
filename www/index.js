(function (window) {
    'use strict';
    const base_url = window.location.href.split('?')[0].split('#')[0];

    function toggle_hidden( elem){
        elem.classList.toggle("hidden");
    }

    function hide_all_panels()
    {
        for( var panel of document.getElementsByClassName("menu-panel")){
            panel.classList.add('hidden');
        }
    }

    function get_link_to_position(map){
        const center = map.getCenter();
        return base_url + '?' + center['lat'].toFixed(4) + '&' + center['lng'].toFixed(4) + '&' + map.getZoom();
    }

    function initMap() {
        var map, center, zoom, circle;
        var menu = document.getElementById('menu');
        var link_text = document.getElementById('link_text');
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
                console.log(document.title);
                hide_all_panels();
                // menu.classList.add("hidden");
                map.flyTo( JSON.parse( this.dataset.latlon), parseInt(this.dataset.zoom), {duration: 2});
            }
        }

        // Get lat, lon from URL params
        const url_params = window.location.href.split('?');
        if( url_params.length == 2){
            const latlonzoom = url_params[1].replace('#','').split('&'); // sometimes '#' get's appended to the url
            if( latlonzoom.length > 1){
                center = [latlonzoom[0],latlonzoom[1]];
                zoom = latlonzoom[2] || 14;
            }
        }
        // Get last position from localStorage
        if( !center){
            center = JSON.parse(localStorage.getItem('latlon')) || [42.116, 1.633];
            zoom = localStorage.getItem('zoom') || 14;
        }
        if(zoom > 16) zoom = 16;

        var attribution = 'Map data &copy; <a href="http://openstreetmap.org" target="_blank">OpenStreetMap</a> contributors' + 
        ', <a href="http://www.icgc.cat" target="_blank">ICGC</a>' + 
        ', <a href="https://www.cnig.es" target="_blank">CNIG</a>. ' + 
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/" target="_blank">CC-BY-SA</a>';

        ////// map layers //////
        var topotresc_layer = L.tileLayer(window.location.protocol + '//' + window.location.host + '/api/{z}/{x}/{y}.png', {
        // var topotresc_layer = L.tileLayer( 'https://api.topotresc.com/tiles/{z}/{x}/{y}.png', {
        // var topotresc_layer = L.tileLayer( 'http://127.0.0.1:3000/tilezip/{z}/{x}/{y}.png', {
        // var topotresc_layer = L.tileLayer( ' https://p8bkcty6z7.execute-api.eu-west-3.amazonaws.com/Prod/tiles/{z}/{x}/{y}.png', {
            minZoom: 7, maxZoom: 17,
            attribution: attribution
        });
        var osm_layer = L.tileLayer( 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { 
            minZoom: 7, maxZoom: 18,
            attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'
        });
        var icc_layer = L.tileLayer( 'http://geoserveis.icgc.cat/icc_mapesmultibase/noutm/wmts/topo/GRID3857/{z}/{x}/{y}.jpeg', { 
            minZoom: 7, maxZoom: 18,
            attribution: '<a href="http://www.icgc.cat" target="_blank">ICGC</a>'
        });
        var ign_layer = L.tileLayer( 'https://www.ign.es/wmts/mapa-raster?request=getTile&layer=MTN&TileMatrixSet=GoogleMapsCompatible&TileMatrix={z}&TileCol={x}&TileRow={y}&format=image/jpeg', { 
            minZoom: 7, maxZoom: 18,
            attribution: '<a href="http://www.icgc.cat" target="_blank">ICGC</a>'
        });
        var google_sat = L.tileLayer( 'https://{s}.google.com/vt/lyrs=s&z={z}&x={x}&y={y}', { 
            minZoom: 7, maxZoom: 18,
            attribution: '&copy; Google',
            subdomains:['mt0','mt1','mt2','mt3']
        });
        var google_maps = L.tileLayer( 'https://{s}.google.com/vt/lyrs=m&z={z}&x={x}&y={y}', { 
            minZoom: 7, maxZoom: 18,
            attribution: '&copy; Google',
            subdomains:['mt0','mt1','mt2','mt3']
        });

        map = L.map('map', {
            layers: [topotresc_layer]
        }).setView(center, zoom);

        link_text.value = get_link_to_position(map);

        L.control.layers({
            "Topotresc":    topotresc_layer,
            "OpenStreetMap":osm_layer,
            "ICC CAT":      icc_layer,
            "IGN ES":       ign_layer,
            "Google sat":   google_sat,
            "Google maps":  google_maps,
        }).addTo(map);
        
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
            link_text.value = get_link_to_position(map);
            window.history.replaceState({}, document.title, "/"); // remove latlonzoom parameters in URL
        })
        map.on('zoomend', function(){ 
            localStorage.setItem('zoom', map.getZoom());
            link_text.value = get_link_to_position(map);
        })

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