(function () {
  return // {
//     placeholder: 'Район',
//     keyValue: 'Id',
//     displayValue: 'name',
//     baseQueryOptions: {
//         queryCode: 'DistricsSelect',
//         filterColumns: null,
//         limit: -1,
//         parameterValues: [{key:'@pageOffsetRows' , value:0},{key: '@pageLimitRows', value: 50}],
//         pageNumber: 1,
//         sortColumns: [
//             {
//             key: 'Id',
//             value: 0
//             }
//         ]
//     },
//     onItemSelect: function(item) {
//         this.yourFunctionName(item);
//     },
//     onClearFilter: function() {
//     },
//     yourFunctionName: function(item) {
//         let message = {
//             name: 'showDistrict',
//             package: {
//                 type: item.value
//             }
//         }
//         this.messageService.publish({name: message.name, value: item.value });
//     },
//     initValue: function(){
//     },
//     init: function(){
//         this.setDefaultValue("first");
//     },
//     destroy() {
//         console.log('Ми покинули даний дашбоард');
//     }
// }


{
    placeholder: 'Район',
    keyValue: 'Id',
    displayValue: 'Name',
    baseQueryOptions: {
        queryCode: 'DistricsSelect',
        limit: -1,
        filterColumns: [
            {
                key: 'Name',
                value: {
                    values: []
                }
            }
        ],
        parameterValues: [],
        pageNumber: 1,
        sortColumns: [
            {
            key: 'Name',
            value: 0
            }
        ]
    },
    onItemSelect: function(item) {
        this.yourFunctionName(item);
    },
    onClearFilter: function() {
    },
    yourFunctionName(item) {
                // var message = {
                //                 name: 'chance_filter_organization',
                //                 value: item.value
                //               };
                // this.messageService.publish(message);
        console.log('send - ',item.value);
    },
    
    initValue:function() {
        // this.setDefaultValue();  
        this.setDefaultValue("first");
    },
    init:function() {
    
    },
    destroy() {
    }
};
}());
