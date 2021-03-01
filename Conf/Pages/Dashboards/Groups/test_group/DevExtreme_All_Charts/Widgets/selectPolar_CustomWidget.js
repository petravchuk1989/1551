(function () {
    return {
        customConfig: `<div id="radarTypes"></div>`
        ,
        init: function() {
        },
        afterViewInit() {
            this.createSelect();
            this.createSelect();
            this.createSelect();
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            children.forEach(child => element.appendChild(child));
            return element;
        },
        createSelect() {
            const types = ["scatter", "line", "area", "bar", "stackedbar"];
            const container = document.getElementById('radarTypes');
            const instance = this.chart;
            const self = this;
            const that = this;
            $("<div/>").dxSelectBox({
                width: 200,
                dataSource: types,
                value: types[0],
                onValueChanged: function(e) {
                    this.option("commonSeriesSettings.type", e.value);        
                }
            }).appendTo(container);
        },

    };
}());