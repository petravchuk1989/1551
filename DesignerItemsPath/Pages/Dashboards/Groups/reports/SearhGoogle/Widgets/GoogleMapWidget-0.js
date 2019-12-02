(function () {
  return {
    title: 'Goole Maps',
    hint: '',
    formatTitle: function() {},
    googleMapConfig: {
        latitude: 50.431782,
        longitude: 30.516382,
        zoom: 12,
        type: 'roadmap',
        disableDefaultUI: true,
        zoomControl: false,
        mapTypeControl: false,
        scaleControl: false,
        streetViewControl: false,
        rotateControl: false,
        fullscreenControl: false
    },
    afterViewInit: function() {
       debugger;
    },
    load: function() {
        new google.maps.Marker({
            position: new google.maps.LatLng(50.431782, 30.516382),
            map: this.map,
            title: 'Super marker 1',
            label: 'L'
        });
        
        new google.maps.Marker({
            position: new google.maps.LatLng(50.431782, 30.546382),
            map: this.map,
            title: 'Super marker 2',
            label: 'L'
        });
    },
};
}());
