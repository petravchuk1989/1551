(function () {
  return {
        config: {
            query: {
                code: 'DevExtreme_DataGrid_RowChart_SelectRows',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: "ColPercent",
                    caption: "ColPercent %",
                    dataType: "number",
                    format: "percent",
                    alignment: "right",
                    allowGrouping: false,
                    cellTemplate: function(container, options) {
                        $("<div/>").dxBullet({
                            onIncidentOccurred: null,
                            size: {
                                width: 150,
                                height: 35
                            },
                            margin: {
                                top: 5,
                                bottom: 0,
                                left: 5
                            },
                            showTarget: false,
                            showZeroLevel: true,
                            value: options.value * 100,
                            startScaleValue: 0,
                            endScaleValue: 100,
                            tooltip: {
                                enabled: true,
                                font: {
                                    size: 18
                                },
                                paddingTopBottom: 2,
                                customizeTooltip: function() {
                                    return { text: options.text };
                                },
                                zIndex: 99999999999
                            }
                        }).appendTo(container);
                    },
                    cssClass: "bullet"
                },
                {
                    dataField: "Name",
                    dataType: "Name",
                },
                {
                    dataField: "Name",
                    dataType: "Name"
                }],
            
            paging: {
                pageSize: 10
            },
            pager: {
                showPageSizeSelector: true,
                allowedPageSizes: [10, 25, 50, 100]
            },
            remoteOperations: false,
            searchPanel: {
                visible: true,
                highlightCaseSensitive: true
            },
            groupPanel: { visible: true },
            grouping: {
                autoExpandAll: false
            },
            allowColumnReordering: true,
            rowAlternationEnabled: true,
            showBorders: true,
            keyExpr: 'Id'
        },
        init: function() {
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function() {
            this.render();
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            children.forEach(child => element.appendChild(child));
            return element;
        }
    };
}());
