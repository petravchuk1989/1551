(function () {
    return {
        title: ' ',
        hint: ' ',
        formatTitle: function () { },
        customConfig:
            `
            <style>
                #widgetTitle{
                    width: 37%;
                    font-weight: 600;
                    font-size: 20px;
                    margin: 0 auto;
                }
            </style>
            <div id='widgetTitle' ></div>
                `
        ,
        afterViewInit: function () {
            // document.getElementById('widgetTitle').innerText = 'ТОП-10 найпроблемніших сфер життєдіяльності міста за перiод: ' +this.dateFromViewValues+ ' по: '+this.dateToViewValues;
            document.getElementById('widgetTitle').innerText = 'ТОП-10 найпроблемніших сфер життєдіяльності міста за перiод: ';
        }
    };
}());
